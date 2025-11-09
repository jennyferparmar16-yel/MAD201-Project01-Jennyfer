/*
  Course code: MAD201
  Project 1
  Student Name: Jennyfer Parmar
  ID: A00201240
  Description: prefsService.dart
  Simple wrapper around SharedPreferences to persist app settings such
 as theme mode (dark/light) and currency selection.
 */

import 'package:shared_preferences/shared_preferences.dart';

class PrefsKeys {
  static const themeDark = 'theme_dark';
  static const currency = 'currency';
}

class PrefsService {
  Future<bool> getThemeDark() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(PrefsKeys.themeDark) ?? false;
    // inline: default to light theme when not set
  }

  Future<void> setThemeDark(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(PrefsKeys.themeDark, v);
  }

  Future<String> getCurrency() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(PrefsKeys.currency) ?? 'USD';
  }

  Future<void> setCurrency(String v) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(PrefsKeys.currency, v);
  }
}