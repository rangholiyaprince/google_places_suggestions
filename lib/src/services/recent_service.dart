import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchesService {
  static const String _key = 'recent_searches';
  final SharedPreferences _prefs;

  RecentSearchesService(this._prefs);

  Future<List<String>> getRecentSearches() async {
    try {
      final String? jsonString = _prefs.getString(_key);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.cast<String>();
    } catch (e) {
      print('Error loading recent searches: $e');
      return [];
    }
  }

  Future<bool> saveRecentSearches(List<String> searches) async {
    try {
      final String jsonString = json.encode(searches);
      return await _prefs.setString(_key, jsonString);
    } catch (e) {
      print('Error saving recent searches: $e');
      return false;
    }
  }

  Future<bool> removeRecentSearch(String search) async {
    try {
      final searches = await getRecentSearches();
      searches.remove(search);
      return await saveRecentSearches(searches);
    } catch (e) {
      print('Error removing recent search: $e');
      return false;
    }
  }

  Future<bool> clearRecentSearches() async {
    try {
      return await _prefs.remove(_key);
    } catch (e) {
      print('Error clearing recent searches: $e');
      return false;
    }
  }
}
