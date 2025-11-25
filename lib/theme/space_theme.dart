import 'package:flutter/material.dart';

class SpaceTheme {
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: const Color(0xFF0A0E21),
    scaffoldBackgroundColor: const Color(0xFF0A0E21),
    colorScheme: const ColorScheme.dark(
      primary: Colors.cyan,
      secondary: Colors.amber,
      surface: Color(0xFF1D1E33),
      background: Color(0xFF0A0E21),
    ),
    cardTheme: CardThemeData(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: const Color(0xFF1D1E33),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0E21),
      elevation: 0,
      centerTitle: true,
    ),
  );
}
