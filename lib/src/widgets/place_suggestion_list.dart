import 'package:flutter/material.dart';
import 'package:google_places_suggestions/google_places_suggestions.dart';

// Widget to display a list of place suggestions
class PlaceSuggestionList extends StatelessWidget {
  // Constructor with required and optional parameters
  const PlaceSuggestionList({
    super.key,
    required this.controller, // Controller for managing suggestions and selection
    required this.accentColor, // Accent color for UI elements
    required this.placeSuggestionIconDecoration, // Decoration for place suggestion icon
    required this.placeSuggestionTextStyle, // Text style for suggestion text
    required this.underlineDecoration, // Decoration for the underline separator
  });

  final GooglePlacesController controller; // Controller to provide suggestions
  final Color accentColor; // Accent color used for styling
  final BoxDecoration placeSuggestionIconDecoration; // Decoration for the icon
  final TextStyle placeSuggestionTextStyle; // Text style for suggestion text
  final BoxDecoration underlineDecoration; // Decoration for underline separator

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8), // Padding around the entire list
      shrinkWrap: true, // List wraps its content (no extra space)
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      itemCount: controller.suggestions.length, // Number of items in the list
      separatorBuilder: (context, index) => Container(
          height: 1, decoration: underlineDecoration), // Customizable separator
      itemBuilder: (context, index) {
        return PlaceSuggestionItem(
          suggestion:
              controller.suggestions[index], // Suggestion for the current item
          onTap: () => controller.onPlaceSelected(
              controller.suggestions[index]), // Callback when tapped
          accentColor: accentColor, // Apply accent color
          placeSuggestionIconDecoration:
              placeSuggestionIconDecoration, // Icon decoration
          placeSuggestionTextStyle: placeSuggestionTextStyle, // Text style
          underlineDecoration: underlineDecoration,
        );
      },
    );
  }
}
