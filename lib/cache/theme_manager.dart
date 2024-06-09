import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _themeManager = ThemeManager._internal();
  ThemeManager._internal();
  static ThemeManager get instance{
    if(!temaCarregado) {
      _themeManager._loadTheme();
    }

    return _themeManager;
  }
  static bool temaCarregado = false;

  ThemeData _themeData = ThemeData.light();

  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _themeData;

  // Chave para armazenar a preferência de tema no SharedPreferences
  static const _themePrefKey = 'theme_pref';

  ThemeManager() {
    _loadTheme();
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themePrefKey) ?? false;
    _updateTheme();
    temaCarregado = true;
  }

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    _updateTheme();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themePrefKey, _isDarkMode);
  }

  void _updateTheme() {
    _themeData = _isDarkMode ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }
}
