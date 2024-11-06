import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeProvider() : _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void useSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }

  // Automatically set theme mode based on system brightness
  void setInitialThemeMode() {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    _themeMode =
        brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }
}
