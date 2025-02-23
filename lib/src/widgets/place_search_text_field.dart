import 'package:flutter/material.dart';

// Widget to display a search field with customizable options
class PlaceSearchField extends StatelessWidget {
  // Constructor with required and optional parameters
  const PlaceSearchField({
    super.key,
    required this.controller, // Text field controller
    required this.focusNode, // Focus node to control focus state
    required this.textStyle,
    this.hint, // Placeholder text
    this.decoration, // Custom input decoration
    this.accentColor, // Optional accent color
    required this.isLoading, // Loading indicator visibility
    this.isListening = false, // Voice input listening state
    required this.onClear, // Callback to clear the input
    this.onVoiceInput, // Callback for voice input
    this.enableVoiceInput = true, // Enable or disable voice input
    required this.isClearIconShow, // Clear icon visibility
  });

  final TextEditingController controller; // Controller for text input
  final FocusNode focusNode; // Focus node
  final String? hint; // Placeholder text
  final TextStyle textStyle; // Text style
  final InputDecoration? decoration; // Input decoration
  final Color? accentColor; // Accent color
  final bool isLoading; // Loading indicator state
  final bool isListening; // Voice listening state
  final bool isClearIconShow; // Clear icon visibility
  final VoidCallback onClear; // Callback to clear text
  final VoidCallback? onVoiceInput; // Callback for voice input
  final bool enableVoiceInput; // Enable or disable voice input

  @override
  Widget build(BuildContext context) {
    final color = accentColor ??
        Theme.of(context)
            .primaryColor; // Use provided accent color or theme primary color

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.05), // Shadow color with transparency
            blurRadius: 10, // Shadow blur radius
            spreadRadius: 0, // No spread
          ),
        ],
      ),
      child: TextField(
        controller: controller, // Assign controller
        focusNode: focusNode, // Assign focus node
        style: textStyle, // Apply text style
        decoration: decoration ?? // Use provided or default decoration
            InputDecoration(
              hintText: isListening
                  ? 'Listening...'
                  : (hint ?? 'Search location...'), // Placeholder text
              filled: true, // Background filled
              fillColor: Colors.white, // Background color
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // Rounded border
                borderSide: BorderSide.none, // No border line
              ),
              prefixIcon: Icon(Icons.search, color: color), // Search icon
              suffixIcon:
                  _buildSuffixIcon(color), // Suffix icon (loading, clear, mic)
            ),
      ),
    );
  }

  Widget _buildSuffixIcon(Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Wrap icons in a small row
      children: [
        if (isLoading) // Show loading indicator if loading
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20, // Loading spinner width
              height: 20, // Loading spinner height
              child: CircularProgressIndicator(
                strokeWidth: 2, // Spinner stroke width
                valueColor: AlwaysStoppedAnimation(color), // Spinner color
              ),
            ),
          )
        else if (isClearIconShow) // Show clear icon if input is not empty
          IconButton(
            icon: Icon(Icons.clear, color: color), // Clear icon
            onPressed: onClear, // Clear input when pressed
          ),
        if (enableVoiceInput &&
            onVoiceInput != null) // Show mic icon if voice input is enabled
          IconButton(
            icon: Icon(
              isListening
                  ? Icons.mic
                  : Icons.mic_none, // Mic icon changes when listening
              color:
                  isListening ? Colors.red : color, // Red color when listening
            ),
            onPressed: onVoiceInput, // Trigger voice input when pressed
          ),
      ],
    );
  }
}
