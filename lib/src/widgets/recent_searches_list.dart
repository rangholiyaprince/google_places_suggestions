import 'package:flutter/material.dart';

// Widget to display recent search items with customizable options
class RecentSearchesList extends StatelessWidget {
  // List of recent search items
  final List<String> recentSearches;
  // Callback when a search item is selected
  final Function(String) onPlaceSelected;
  // Callback to hide recent search section
  final Function(bool) isRecentSearchHide;
  // Callback when a search item is removed
  final Function(String)? onSearchRemoved;
  // Callback to clear all search items
  final VoidCallback? onClearAll;
  // Optional accent color for icons and text
  final Color? accentColor;

  // Customizable text options
  final String recentText; // Title of the section
  final String clearAllText; // Text for the clear all button
  final Widget? emptyState; // Widget to show when there are no search items

  // Text styles
  final TextStyle? recentTextStyle; // Style for the title
  final TextStyle? clearAllStyle; // Style for the clear all button
  final TextStyle? itemTextStyle; // Style for each search item

  // Maximum number of items before scrolling is enabled
  static const int _maxNonScrollingItems = 5;

  // Constructor with named parameters
  const RecentSearchesList({
    super.key,
    required this.recentSearches,
    required this.onPlaceSelected,
    required this.isRecentSearchHide,
    required this.recentText, // Default title
    required this.clearAllText, // Default clear all button text
    this.onSearchRemoved,
    this.onClearAll,
    this.accentColor,
    this.emptyState, // Default to no widget
    this.recentTextStyle,
    this.clearAllStyle,
    this.itemTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    // Show empty state if no recent searches are available
    if (recentSearches.isEmpty) return emptyState ?? const SizedBox();

    // Main column containing title, divider, and list of items
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Align children to the start
      mainAxisSize: MainAxisSize.min, // Only take the space needed
      children: [
        // Title and clear all button row
        Padding(
          padding:
              const EdgeInsets.fromLTRB(20, 8, 20, 0), // Padding around the row
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Space between title and button
            children: [
              Text(
                recentText, // Display the title text
                style:
                    recentTextStyle ?? // Use custom style if provided, else fallback to default
                        Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
              ),
              if (onClearAll !=
                  null) // Show clear all button if callback is provided
                TextButton(
                  onPressed:
                      onClearAll, // Call onClearAll when button is pressed
                  child: Text(
                    clearAllText, // Display clear all text
                    style: clearAllStyle ??
                        TextStyle(
                            color: accentColor), // Custom or default style
                  ),
                ),
            ],
          ),
        ),

        const Divider(height: 1), // Divider line below title row

        // Display either a non-scrolling or scrolling list based on item count
        if (recentSearches.length <= _maxNonScrollingItems)
          _buildNonScrollingList(context)
        else
          _buildScrollingList(context),
      ],
    );
  }

  // Build list when items fit within non-scrolling limit
  Widget _buildNonScrollingList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true, // Fit the list within its content
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      padding: EdgeInsets.zero, // No padding inside the list
      itemCount: recentSearches.length, // Number of items to display
      itemBuilder: (context, index) =>
          _buildListItem(context, index), // Build each list item
    );
  }

  // Build list when scrolling is required
  Widget _buildScrollingList(BuildContext context) {
    final ScrollController scrollController =
        ScrollController(); // Controller for scrollbar

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: _calculateMaxHeight(context), // Limit the height of the list
      ),
      child: Scrollbar(
        controller: scrollController, // Attach scrollbar to controller
        thickness: 2.0, // Width of the scrollbar
        radius: const Radius.circular(3.0), // Rounded corners for scrollbar
        thumbVisibility: true, // Make scrollbar always visible
        child: ListView.builder(
          controller: scrollController, // Scroll using this controller
          padding: EdgeInsets.zero, // No internal padding
          shrinkWrap: false, // Allow list to scroll
          physics:
              const AlwaysScrollableScrollPhysics(), // Always allow scrolling
          itemCount: recentSearches.length, // Number of items
          itemBuilder: (context, index) =>
              _buildListItem(context, index), // Build each item
        ),
      ),
    );
  }

  // Calculate max height based on item height and limit
  double _calculateMaxHeight(BuildContext context) {
    const itemHeight = 70.0; // Height for each item
    return itemHeight * _maxNonScrollingItems +
        8; // Total height for max items plus padding
  }

  // Build each search item in the list
  Widget _buildListItem(BuildContext context, int index) {
    final color = accentColor ??
        Theme.of(context).primaryColor; // Use accent color or fallback

    return Material(
      color: Colors.transparent, // Transparent background
      child: InkWell(
        borderRadius:
            BorderRadius.circular(8), // Rounded corners for tap effect
        onTap: () => onPlaceSelected(
            recentSearches[index]), // Callback when item is tapped
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0, vertical: 12.0), // Padding inside each item
          child: Row(
            children: [
              // Icon on the left
              Container(
                padding: const EdgeInsets.all(8), // Padding around the icon
                decoration: BoxDecoration(
                  color: color.withValues(
                      alpha: 0.1), // Background with slight opacity
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                child: Icon(
                  Icons.history, // History icon
                  color: color, // Use accent color
                  size: 20, // Icon size
                ),
              ),
              const SizedBox(width: 12), // Space between icon and text

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the left
                  children: [
                    Text(
                      recentSearches[index], // Display search text
                      style:
                          itemTextStyle ?? // Use custom or default text style
                              const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                      maxLines: 2, // Limit to 2 lines
                      overflow:
                          TextOverflow.ellipsis, // Ellipsis if text is too long
                    ),
                    const SizedBox(
                        height: 4), // Space between text and underline
                    Container(
                      height: 2, // Thin underline
                      width: 40, // Width of underline
                      decoration: BoxDecoration(
                        color: color.withValues(
                            alpha: 0.2), // Underline color with opacity
                        borderRadius:
                            BorderRadius.circular(1), // Rounded underline
                      ),
                    ),
                  ],
                ),
              ),

              // Close button to remove item
              if (onSearchRemoved != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20), // Close icon
                  onPressed: () => onSearchRemoved!(
                      recentSearches[index]), // Callback on press
                ),
            ],
          ),
        ),
      ),
    );
  }
}
