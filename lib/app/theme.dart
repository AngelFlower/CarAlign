import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness) => ThemeData(
      colorSchemeSeed: Colors.teal,
      brightness: brightness,
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
