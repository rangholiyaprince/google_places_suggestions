import 'dart:convert';

import 'package:http/http.dart' as http;

class PlaceService {
  static Future<List<String>> getSuggestions(
    String input,
    String googleMapKey,
    String sessionToken,
  ) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$googleMapKey&sessiontoken=$sessionToken';
    final response =
        await http.get(Uri.parse(request)).timeout(const Duration(seconds: 20));
    final data = jsonDecode(response.body);

    if (data['status'] == 'OK') {
      return List<String>.from(
        data['predictions'].map((prediction) => prediction['description']),
      );
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }
}
