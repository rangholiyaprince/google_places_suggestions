import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../google_places_suggestions.dart';

class GooglePlacesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final String googleMapKey;
  final Function(String) onPlaceSelect;
  final bool enableRecentSearches;
  final int maxRecentSearches;
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
  final _suggestions = <String>[].obs;
  final _recentSearches = <String>[].obs;
  final _isLoading = false.obs;
  final _isExpanded = false.obs;
  final _showError = false.obs;
  final _errorMessage = ''.obs;
  final _isListening = false.obs;
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

  // Getters
  TextEditingController get controller => _controller;
  FocusNode get focusNode => _focusNode;
  List<String> get suggestions => _suggestions;
  List<String> get recentSearches => _recentSearches;
  bool get isLoading => _isLoading.value;
  bool get isExpanded => _isExpanded.value;
  bool get showError => _showError.value;
  String get errorMessage => _errorMessage.value;
  bool get isListening => _isListening.value;
  bool get isClearIconShow => _isClearIconShow.value;

  @override
  void onInit()async {
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

  Future<void> _initializeServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearchesService = RecentSearchesService(prefs);
      await _loadRecentSearches();
    } catch (e) {
      handleError('Error initializing services: $e');
    }
  }

  Future<void> _loadRecentSearches() async {
    if (!enableRecentSearches) return;

    try {
      final searches = await _recentSearchesService.getRecentSearches();
      _recentSearches.value = searches.take(maxRecentSearches).toList();
    } catch (e) {
      handleError('Error loading recent searches: $e');
    }
  }

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

  Future<void> removeRecentSearch(String search) async {
    try {
      await _recentSearchesService.removeRecentSearch(search);
      _recentSearches.remove(search);

      // If this was the last item and we're showing recent searches,
      // we need to update the expanded state
      if (_recentSearches.isEmpty && _controller.text.isEmpty) {
        _isExpanded.value = false;
        animationController.reverse();
      }
    } catch (e) {
      handleError('Error removing recent search: $e');
    }
  }

  Future<void> clearRecentSearches() async {
    try {
      await _recentSearchesService.clearRecentSearches();
      _recentSearches.clear();
    } catch (e) {
      handleError('Error clearing recent searches: $e');
    }
  }

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

    bool get shouldShowNoResults =>
      !isLoading &&
      controller.text.isNotEmpty &&
      suggestions.isEmpty &&
      !showError;

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

      // Make sure the expanded state is correct
      _isExpanded.value = suggestions.isNotEmpty ||
          (enableRecentSearches && _recentSearches.isNotEmpty) ||
          controller.text.isNotEmpty; // Keep expanded even with no results
    } catch (e) {
      handleError('Network error occurred');
    }
  }

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

  void handleError(String message) {
    _suggestions.clear();
    _isLoading.value = false;
    _showError.value = true;
    _errorMessage.value = message;

    if (onError != null) {
      onError!(message);
    }
  }

  void _refreshSessionToken() {
    _sessionToken = _uuid.v4();
  }

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

  void _onSpeechStatus(String status) {
    if (status == 'notListening') {
      _isListening.value = false;
    }
  }

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
