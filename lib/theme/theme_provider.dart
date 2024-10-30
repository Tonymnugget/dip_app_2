import 'package:dip_app_2/theme/dark_mode.dart';
import 'package:dip_app_2/theme/light_mode.dart';
import 'package:flutter/material.dart';

/*

to change the app from dark & light mode


self note: provider is needed here, state management tool
*/

class ThemeProvider with ChangeNotifier {
  // initially, set it as light mode
  ThemeData _themeData = lightMode;

  // get the current them
  ThemeData get themeData => _themeData;

  // is it dark mode currently?
  bool get isDarkMode => _themeData == darkMode;

  // set the theme
  set themeData(ThemeData themeData) {
    _themeData = themeData;

    // update UI
    notifyListeners();
  }

  // toggle between dark & light modeS
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
