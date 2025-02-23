import 'package:flutter/material.dart';

// Widget to display a single place suggestion item
class PlaceSuggestionItem extends StatelessWidget {
  // Constructor with required and optional parameters, including styles and decorations
  const PlaceSuggestionItem({
    super.key,
    required this.suggestion, // Text of the suggestion
    required this.onTap, // Callback when the item is tapped
    required this.placeSuggestionIconDecoration, // Icon container decoration
    required this.underlineDecoration, // Underline decoration
    required this.placeSuggestionTextStyle, // Default text style
    this.accentColor, // Optional accent color
  });

  final String suggestion; // Suggestion text
  final VoidCallback onTap; // Tap event callback
  final Color? accentColor; // Optional accent color
  final TextStyle placeSuggestionTextStyle; // Text style for suggestion
  final BoxDecoration
      placeSuggestionIconDecoration; // Decoration for icon container
  final BoxDecoration underlineDecoration; // Decoration for underline

  @override
  Widget build(BuildContext context) {
    final color = accentColor ??
        Theme.of(context)
            .primaryColor; // Use provided accent color or theme primary color

    return Material(
      color: Colors.transparent, // Transparent background
      child: InkWell(
        borderRadius: BorderRadius.circular(8), // Rounded corners on tap effect
        onTap: onTap, // Call onTap when tapped
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0), // Padding inside the item
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.all(8), // Padding inside icon container
                decoration:
                    placeSuggestionIconDecoration, // Icon container decoration with default fallback

                child: Icon(
                  Icons.location_on_outlined, // Location icon
                  color: color, // Icon color
                  size: 20, // Icon size
                ),
              ),
              const SizedBox(width: 12), // Space between icon and text
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the start
                  children: [
                    Text(
                      suggestion, // Display suggestion text
                      style:
                          placeSuggestionTextStyle, // Apply provided or default text style
                      maxLines: 2, // Limit to 2 lines
                      overflow: TextOverflow
                          .ellipsis, // Truncate with ellipsis if too long
                    ),
                    const SizedBox(
                        height: 4), // Space between text and underline
                    Container(
                        height: 2, // Underline height
                        width: 40, // Underline width
                        decoration: underlineDecoration),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
