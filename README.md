# GooglePlacesSuggestions

**Platform Support**
Android ✅ | iOS ✅ | MacOS ✅ | Web ✅

**GooglePlacesSuggestions** is a Flutter package that delivers real-time location suggestions using the Google Places API. It enhances user experience by providing instant search results as users type.

![GooglePlacesSuggestions Demo](https://github.com/rangholiyaprince/google_places_suggestions/blob/main/example/assets/google_palce_suggestions.gif)

## Features
- Real-time place suggestions using Google Places API
- Easy integration with Flutter
- Customizable search input and results display
- Recent searches and voice input support

## Installation

Add this package to your `pubspec.yaml` file:

```yaml
dependencies:
  google_places_suggestions: latest_version
```

Run the command to install dependencies:

```bash
flutter pub get
```

## Usage

```dart
import 'package:google_places_suggestions/google_places_suggestions.dart';
import 'package:flutter/material.dart';

GooglePlacesSuggestions(
  // Required parameters
  googleMapKey: 'YOUR_GOOGLE_MAPS_API_KEY',
  onPlaceSelected: (String place) {
    // Handle selected place
    print('Selected place : $place');
  },

  // Optional customization
  hint: 'Search for a location...',
  accentColor: Theme.of(context).primaryColor,
  debounceTime: const Duration(milliseconds: 300),

  // Customize text styles
  textStyle: const TextStyle(
    fontSize: 16,
    color: Colors.black87,
  ),
  placeSuggestionTextStyle: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  ),

  // Customize decorations
  placeSuggestionIconDecoration: BoxDecoration(
    color: Theme.of(context).primaryColor.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8),
  ),
  underlineDecoration: BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      ),
    ),
  ),

  // Recent searches configuration
  enableRecentSearches: true,
  maxRecentSearches: 5,
  recentText: 'Recent Locations',
  recentTextStyle: const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  ),

  // Error handling
  onError: (String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  },

  // Custom empty state
  noResultsWidget: const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.search_off, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'No locations found',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  ),
)
```

## Configuration

Ensure you have enabled **Places API** in your Google Cloud Console and added the API key in your Flutter app.

## Example App

Check out the [example](https://github.com/rangholiyaprince/google_places_suggestions/tree/main/example) directory for a complete sample application demonstrating how to implement GooglePlacesSuggestions in your Flutter project.

## License

This project is licensed under the MIT License.
