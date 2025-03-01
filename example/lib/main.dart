library;

import 'package:flutter/material.dart';
import 'package:google_places_suggestions/google_places_suggestions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Search'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // Implementation of GooglePlacesSuggestions widget
              GooglePlacesSuggestions(
                // Required parameters
                googleMapKey: 'YOUR_GOOGLE_MAPS_API_KEY',
                onPlaceSelected: (String place) {
                  // Handle selected place
                  print('Selected place: $place');
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
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                underlineDecoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
