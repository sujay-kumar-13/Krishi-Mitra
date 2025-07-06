import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_maps.dart';

// To save a string
Future<void> saveData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// To retrieve the string later
Future<String?> getData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

/// Convert `"Black Pepper"` → `"blackPepper"`
String _camelKey(String name) {
  final parts = name.split(RegExp(r'[^A-Za-z0-9]+'));
  if (parts.isEmpty) return name;
  final first = parts.first.toLowerCase();
  final rest  = parts.skip(1).map((s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}');
  return [first, ...rest].join();
}

final Map<String, Map<String, String>> allLanguageTranslations = {
  'English': engToEnglish,
  'हिंदी': engToHindi,
  'தமிழ்': engToTamil,
  'తెలుగు': engToTelugu,
  'বাংলা': engToBengali,
  'ગુજરાતી': engToGujarati,
  'मराठी': engToMarathi,
  'ਪੰਜਾਬੀ': engToPunjabi,
  'اردو': engToUrdu,
  'ಕನ್ನಡ': engToKannada,
  'മലയാളം': engToMalayalam,
  'ଓଡ଼ିଆ': engToOdia,
};

String? getTranslatedValue(String value, String languageName) {
  // Get the specific language map from the master collection
  final Map<String, String>? languageMap = allLanguageTranslations[languageName];

  // Convert the value to a camel-case key
  final String key = _camelKey(value);

  if (languageMap != null) {
    // If the language map exists, return the value for the given key
    return languageMap[key];
  } else {
    // If the language map does not exist, or key is not in the map, return null
    return engToEnglish[key];
  }
}

String translateMonthYear(String monthYear, String language) {
  if (monthYear.trim().isEmpty) return monthYear;

  // Split by whitespace – supports multi‑word months if any.
  final parts = monthYear.trim().split(RegExp(r'\s+'));
  if (parts.length < 2) {
    // Not the expected "Month Year" format – fallback to normal translation.
    return getTranslatedValue(monthYear, language) ?? monthYear;
  }

  // The year is the last token, everything before it is the month.
  final year = parts.last;
  final month = parts.sublist(0, parts.length - 1).join(' ');

  // Translate the month name only.
  final translatedMonth = getTranslatedValue(month, language) ?? month;

  return '$translatedMonth $year';
}
