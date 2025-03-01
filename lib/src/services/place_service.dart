import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class PlaceService {
  static Future<List<String>> getSuggestions(
    String input,
    String googleMapKey,
    String sessionToken,
  ) async {
    try {
      final request =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleMapKey&sessiontoken=$sessionToken';

      final response = await http
          .get(Uri.parse(request))
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] != 'OK') {
          return Future.error(_getErrorMessage(data['status']));
        }

        return List<String>.from(
          data['predictions'].map((prediction) => prediction['description']),
        );
      } else {
        return Future.error('Unable to fetch suggestions. Please try again.');
      }
    } on SocketException {
      return Future.error('No internet. Please check your connection.');
    } on TimeoutException {
      return Future.error('Request timed out. Try again.');
    } on FormatException {
      return Future.error('Unexpected response. Try later.');
    } catch (e) {
      return Future.error('Something went wrong. Please try again.');
    }
  }

  // Map API errors to user-friendly messages
  static String _getErrorMessage(String status) {
    switch (status) {
      case 'ZERO_RESULTS':
        return 'No results found. Try a different search.';
      case 'OVER_QUERY_LIMIT':
        return 'Too many requests. Try again later.';
      case 'REQUEST_DENIED':
        return 'Request denied. Check API key permissions.';
      case 'INVALID_REQUEST':
        return 'Invalid request. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
