import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    surfaceDim: Colors.grey.shade900,
    inverseSurface: Colors.grey.shade900,
    primary: Colors.grey.shade900,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade800,
    onSecondary: Colors.black,
    secondaryFixed: const Color.fromARGB(255, 53, 51, 51),
    secondaryFixedDim: Colors.grey.shade400,
    onSecondaryContainer: Colors.white,
    tertiary: Colors.grey.shade100,
    tertiaryContainer: Colors.grey.shade700,
    tertiaryFixed: Colors.grey.shade700,
    inversePrimary: Colors.grey.shade700,
  ),
);
