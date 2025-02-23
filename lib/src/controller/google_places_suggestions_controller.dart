import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../google_places_suggestions.dart';

/// A controller class that manages Google Places autocomplete functionality with recent searches
/// and voice input capabilities.
///
/// This controller handles:
/// * Google Places API integration for location suggestions
/// * Recent searches management with local storage
/// * Voice input for location search
/// * UI state management for the search experience
class GooglePlacesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// API key for Google Maps Services
  final String googleMapKey;

  /// Callback function triggered when a place is selected
  final Function(String) onPlaceSelect;

  /// Flag to enable/disable recent searches functionality
  final bool enableRecentSearches;

  /// Maximum number of recent searches to store
  final int maxRecentSearches;

  /// Optional callback for error handling
  final Function(String)? onError;

  late final RecentSearchesService _recentSearchesService;

  GooglePlacesController({
    required this.googleMapKey,
    required this.onPlaceSelect,
    this.enableRecentSearches = true,
    this.maxRecentSearches = 5,
    this.onError,
  });

  // Observable variables
  /// List of current place suggestions from Google Places API
  final _suggestions = <String>[].obs;

  /// List of recent searches stored locally
  final _recentSearches = <String>[].obs;

  /// Loading state indicator
  final _isLoading = false.obs;

  /// Expanded state of the suggestions list
  final _isExpanded = false.obs;

  /// Error state indicator
  final _showError = false.obs;

  /// Current error message
  final _errorMessage = ''.obs;

  /// Voice input listening state
  final _isListening = false.obs;

  /// Clear icon visibility state
  final _isClearIconShow = false.obs;

  // Non-reactive variables
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _uuid = const Uuid();
  late String _sessionToken;
  Timer? _debounce;
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  final stt.SpeechToText _speech = stt.SpeechToText();

  /// Returns the text editing controller for the search input
  TextEditingController get controller => _controller;

  /// Returns the focus node for the search input
  FocusNode get focusNode => _focusNode;

  /// Returns the current list of place suggestions
  List<String> get suggestions => _suggestions;

  /// Returns the list of recent searches
  List<String> get recentSearches => _recentSearches;

  /// Returns true if the controller is in a loading state
  bool get isLoading => _isLoading.value;

  /// Returns true if the suggestions list is expanded
  bool get isExpanded => _isExpanded.value;

  /// Returns true if an error state is active
  bool get showError => _showError.value;

  /// Returns the current error message
  String get errorMessage => _errorMessage.value;

  /// Returns true if voice input is currently listening
  bool get isListening => _isListening.value;

  /// Returns true if the clear icon should be shown
  bool get isClearIconShow => _isClearIconShow.value;

  @override
  void onInit() async {
    super.onInit();
    _sessionToken = _uuid.v4();
    _controller.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
    await _initializeServices();
    _initSpeech();

    // Initialize animation controller
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }

  /// Initializes required services including SharedPreferences
  Future<void> _initializeServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearchesService = RecentSearchesService(prefs);
      await _loadRecentSearches();
    } catch (e) {
      handleError('Error initializing services: $e');
    }
  }

  /// Loads previously saved recent searches from local storage
  Future<void> _loadRecentSearches() async {
    if (!enableRecentSearches) return;

    try {
      final searches = await _recentSearchesService.getRecentSearches();
      _recentSearches.value = searches.take(maxRecentSearches).toList();
    } catch (e) {
      handleError('Error loading recent searches: $e');
    }
  }

  /// Saves a new place to recent searches
  Future<void> _saveRecentSearch(String place) async {
    if (!enableRecentSearches || _recentSearches.contains(place)) return;

    try {
      _recentSearches.insert(0, place);
      if (_recentSearches.length > maxRecentSearches) {
        _recentSearches.removeLast();
      }
      await _recentSearchesService.saveRecentSearches(_recentSearches);
    } catch (e) {
      handleError('Error saving recent search: $e');
    }
  }

  /// Removes a specific search from recent searches
  ///
  /// [search] The search term to remove
  Future<void> removeRecentSearch(String search) async {
    try {
      await _recentSearchesService.removeRecentSearch(search);
      _recentSearches.remove(search);

      if (_recentSearches.isEmpty && _controller.text.isEmpty) {
        _isExpanded.value = false;
        animationController.reverse();
      }
    } catch (e) {
      handleError('Error removing recent search: $e');
    }
  }

  /// Clears all recent searches from storage
  Future<void> clearRecentSearches() async {
    try {
      await _recentSearchesService.clearRecentSearches();
      _recentSearches.clear();
    } catch (e) {
      handleError('Error clearing recent searches: $e');
    }
  }

  /// Handles focus changes for the search input
  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.isEmpty) {
      _isExpanded.value = enableRecentSearches && _recentSearches.isNotEmpty;
      _suggestions.clear();
      if (_isExpanded.value) {
        animationController.forward();
      }
    } else if (!_focusNode.hasFocus) {
      _isExpanded.value = false;
      _suggestions.clear();
      animationController.reverse();
    }
  }

  /// Handles changes in the search input text
  void _onSearchChanged() {
    if (_controller.text.isEmpty) {
      _suggestions.clear();
      _isExpanded.value = enableRecentSearches && _recentSearches.isNotEmpty;
      _isClearIconShow.value = false;
      _showError.value = false;

      if (_isExpanded.value) {
        animationController.forward();
      } else {
        animationController.reverse();
      }
      return;
    }

    _isExpanded.value = true;
    _isClearIconShow.value = true;
    _showError.value = false;
    animationController.forward();

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 800),
      () => _getSuggestions(_controller.text),
    );
  }

  /// Handles the selection of a place from suggestions or recent searches
  ///
  /// [place] The selected place string
  void onPlaceSelected(String place) {
    _controller.text = place;
    _focusNode.unfocus();
    _suggestions.clear();
    _isExpanded.value = false;
    _showError.value = false;
    _saveRecentSearch(place);
    animationController.reverse();
    onPlaceSelect(place);
    _refreshSessionToken();
  }

  /// Returns true if no results should be shown
  bool get shouldShowNoResults =>
      !isLoading &&
      controller.text.isNotEmpty &&
      suggestions.isEmpty &&
      !showError;

  /// Fetches place suggestions from Google Places API
  Future<void> _getSuggestions(String input) async {
    if (input.isEmpty) {
      _suggestions.clear();
      _isLoading.value = false;
      return;
    }

    _isLoading.value = true;

    try {
      final suggestions = await PlaceService.getSuggestions(
        input,
        googleMapKey,
        _sessionToken,
      );

      _suggestions.value = suggestions;
      _isLoading.value = false;
      _showError.value = false;

      _isExpanded.value = suggestions.isNotEmpty ||
          (enableRecentSearches && _recentSearches.isNotEmpty) ||
          controller.text.isNotEmpty;
    } catch (e) {
      handleError('Network error occurred');
    }
  }

  /// Clears the current search input and resets related states
  void clearSearch() {
    _controller.clear();
    _suggestions.clear();
    _isExpanded.value = enableRecentSearches && _recentSearches.isNotEmpty;
    _showError.value = false;

    if (_isExpanded.value) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  /// Handles errors and triggers error callback if provided
  ///
  /// [message] The error message to display
  void handleError(String message) {
    _suggestions.clear();
    _isLoading.value = false;
    _showError.value = true;
    _errorMessage.value = message;

    if (onError != null) {
      onError!(message);
    }
  }

  /// Refreshes the session token for Google Places API
  void _refreshSessionToken() {
    _sessionToken = _uuid.v4();
  }

  /// Initializes the speech recognition service
  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (error) {
          _suggestions.clear();
          _isLoading.value = false;
          _showError.value = true;
        },
      );
      if (!available) {
        handleError('Speech recognition not available on this device');
      }
    } catch (e) {
      handleError('Error initializing speech recognition');
    }
  }

  /// Handles speech recognition status changes
  void _onSpeechStatus(String status) {
    if (status == 'notListening') {
      _isListening.value = false;
    }
  }

  /// Starts or stops voice input for location search
  Future<void> startVoiceInput() async {
    if (!_speech.isAvailable) {
      handleError('Speech recognition not available');
      return;
    }

    if (_isListening.value) {
      await _speech.stop();
      _isListening.value = false;
      return;
    }

    try {
      _isListening.value = true;
      _isLoading.value = true;

      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            _controller.text = result.recognizedWords;
            _isListening.value = false;
            _isLoading.value = false;
            _onSearchChanged();
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 6),
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: true,
          partialResults: false,
          listenMode: stt.ListenMode.search,
        ),
      );
    } catch (e) {
      _isListening.value = false;
      _isLoading.value = false;
      handleError('Error starting voice recognition');
    }
  }

  @override
  void onClose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    animationController.dispose();
    _speech.cancel();
    super.onClose();
  }
}
