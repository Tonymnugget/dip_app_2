import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.white,
    surfaceDim: Color.fromARGB(100, 202, 216, 220),
    inverseSurface: const Color.fromARGB(255, 190, 199, 217),
    primary: const Color.fromARGB(255, 26, 76, 99),
    onPrimary: Colors.white,
    secondary: const Color.fromARGB(255, 202, 216, 218),
    onSecondary: Colors.black,
    secondaryFixed: Colors.white,
    secondaryFixedDim: Colors.grey.shade600,
    tertiary: Colors.white,
    inversePrimary: const Color.fromARGB(255, 221, 226, 227),
  ),
);
