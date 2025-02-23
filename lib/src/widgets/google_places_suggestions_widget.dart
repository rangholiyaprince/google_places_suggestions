// Import necessary Flutter and Get packages for UI and state management
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import custom Google Places suggestions implementation
import '../../google_places_suggestions.dart';

// StatelessWidget that provides a search interface for Google Places API
class GooglePlacesSuggestions extends StatelessWidget {
  // Constructor with required and optional parameters for customization
  const GooglePlacesSuggestions({
    super.key,
    required this.googleMapKey, // API key for Google Places
    required this.onPlaceSelected, // Callback when a place is selected

    this.hint, // Placeholder text for search field
    this.textStyle, // Custom text style for input
    this.decoration, // Custom input decoration
    this.debounceTime, // Delay before triggering search
    this.accentColor, // Custom accent color
    this.enableRecentSearches = true, // Toggle recent searches feature
    this.maxRecentSearches = 5, // Maximum number of recent searches to store
    this.onError, // Error handling callback
    this.noResultsWidget, // Custom widget for no results state
    this.enableVoiceInput = true, // Toggle voice input feature
    this.enableLocationButton = true, // Toggle location button
    this.clearAllStyle, // Text style for clear all button
    this.clearAllText, // Custom text for clear all button
    this.emptyState, // Custom widget for empty state
    this.itemTextStyle, // Text style for suggestion items
    this.recentTextStyle, // Text style for recent searches
    this.recentText, // Custom text for recent searches header
    this.placeSuggestionIconDecoration, // Decoration for place suggestion icon
    this.placeSuggestionTextStyle, // Text style for suggestion text
    this.underlineDecoration, // Decoration for the underline separator
  });

  // Define all class properties with their types and purposes
  final String googleMapKey; // Google Maps API key
  final Function(String) onPlaceSelected; // Callback for place selection
  final String? hint; // Search field placeholder
  final TextStyle? textStyle; // Input field text style
  final InputDecoration? decoration; // Input field decoration
  final Duration? debounceTime; // Search delay duration
  final Color? accentColor; // Theme accent color
  final bool enableRecentSearches; // Recent searches toggle
  final int maxRecentSearches; // Recent searches limit
  final Function(String)? onError; // Error handler
  final Widget? noResultsWidget; // No results custom widget
  final bool enableVoiceInput; // Voice input toggle
  final bool enableLocationButton; // Location button toggle

  // Additional customization properties
  final TextStyle? clearAllStyle; // Clear all button style
  final String? clearAllText; // Clear all button text
  final Widget? emptyState; // Empty state widget
  final TextStyle? itemTextStyle; // Suggestion item style
  final TextStyle? recentTextStyle; // Recent searches style
  final String? recentText; // Recent searches header
  final BoxDecoration?
      placeSuggestionIconDecoration; // Place suggestion icon decoration
  final TextStyle? placeSuggestionTextStyle; // place Suggestion text style
  final BoxDecoration? underlineDecoration; // Underline separator decoration

  @override
  Widget build(BuildContext context) {
    // Initialize the controller using Get dependency injection
    final controller = Get.put(GooglePlacesController(
      googleMapKey: googleMapKey,
      onPlaceSelect: onPlaceSelected,
      enableRecentSearches: enableRecentSearches,
      maxRecentSearches: maxRecentSearches,
      onError: onError,
    ));

    // Get accent color from theme if not provided
    final color = accentColor ?? Theme.of(context).primaryColor;

    // Build the main widget structure
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field wrapped in Obx for reactive updates
        Obx(
          () => PlaceSearchField(
            controller: controller.controller,
            focusNode: controller.focusNode,
            isLoading: controller.isLoading,
            isClearIconShow: controller.isClearIconShow,
            onClear: controller.clearSearch,
            onVoiceInput: enableVoiceInput ? controller.startVoiceInput : null,
            accentColor: color,
            hint: hint,
            decoration: decoration,
            enableVoiceInput: enableVoiceInput,
            textStyle: textStyle ?? TextStyle(fontSize: 16),
            isListening: controller.isListening,
          ),
        ),
        // Suggestions list with animation, wrapped in Obx
        Obx(() {
          // Hide if not expanded
          if (!controller.isExpanded) return const SizedBox.shrink();

          // Show suggestions with fade animation
          return FadeTransition(
            opacity: controller.fadeAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              // Style the suggestions container
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show appropriate widget based on state
                  if (controller.showError)
                    _buildNoResults()
                  else if (controller.suggestions.isNotEmpty)
                    PlaceSuggestionList(
                      controller: controller,
                      accentColor: color,
                      placeSuggestionIconDecoration:
                          placeSuggestionIconDecoration ??
                              BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                      placeSuggestionTextStyle: placeSuggestionTextStyle ??
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      underlineDecoration: underlineDecoration ??
                          BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(1),
                          ),
                    )
                  else if (controller.controller.text.isEmpty &&
                      enableRecentSearches &&
                      controller.recentSearches.isNotEmpty)
                    _buildRecentSearches(controller),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // Build widget for no results state
  Widget _buildNoResults() {
    return noResultsWidget ??
        Container(
          padding: const EdgeInsets.all(16),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No results found',
                  style: TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        );
  }

  // Build widget for recent searches
  Widget _buildRecentSearches(GooglePlacesController controller) {
    // Return empty widget if recent searches are disabled or empty
    if (!enableRecentSearches || controller.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    // Return recent searches list widget
    return RecentSearchesList(
      recentSearches: controller.recentSearches,
      onPlaceSelected: (value) => controller.onPlaceSelected(value),
      isRecentSearchHide: (isHide) {},
      onClearAll: controller.clearRecentSearches,
      onSearchRemoved: controller.removeRecentSearch,
      accentColor: accentColor,
      clearAllStyle: clearAllStyle,
      clearAllText: clearAllText ?? 'Clear All',
      emptyState: emptyState,
      itemTextStyle: itemTextStyle,
      recentTextStyle: recentTextStyle,
      recentText: recentText ?? 'Recent Searches',
    );
  }
}
