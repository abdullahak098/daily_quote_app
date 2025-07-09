import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class QuoteService {
  static const String _keySavedQuotes = 'savedQuotes';
  static const String _keyUserQuotes = 'userQuotes';

  static List<String> defaultQuotes = [
    "Believe in yourself.",
    "Push yourself, no one else will do it.",
    "Stay positive. Work hard.",
    "Dream big. Work bigger.",
    "You are your only limit."
  ];

  /// Adds a custom user-created quote to local storage
  static Future<void> addUserQuote(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    final userQuotes = prefs.getStringList(_keyUserQuotes) ?? [];

    if (!userQuotes.contains(quote)) {
      userQuotes.add(quote);
      await prefs.setStringList(_keyUserQuotes, userQuotes);
    }
  }

  /// Returns all user-added quotes
  static Future<List<String>> getUserQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyUserQuotes) ?? [];
  }

  /// Returns a random quote from both default and user-added quotes
  static Future<String> getRandomQuote() async {
    final userQuotes = await getUserQuotes();
    final allQuotes = [...defaultQuotes, ...userQuotes];

    if (allQuotes.isEmpty) return "No quotes available.";
    return allQuotes[Random().nextInt(allQuotes.length)];
  }

  /// Saves a quote to favorites if it's not already saved
  static Future<void> saveQuote(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuotes = prefs.getStringList(_keySavedQuotes) ?? [];

    if (!savedQuotes.contains(quote)) {
      savedQuotes.add(quote);
      await prefs.setStringList(_keySavedQuotes, savedQuotes);
    }
  }

  /// Returns all saved (favorited) quotes
  static Future<List<String>> getSavedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keySavedQuotes) ?? [];
  }

  /// Removes a quote from saved (favorited) list
  static Future<void> removeQuote(String quote) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuotes = prefs.getStringList(_keySavedQuotes) ?? [];

    savedQuotes.remove(quote);
    await prefs.setStringList(_keySavedQuotes, savedQuotes);
  }
}
