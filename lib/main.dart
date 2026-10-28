import 'package:flutter/material.dart';

import 'ui/home_page.dart';

void main() => runApp(const CarAlignApp());

class CarAlignApp extends StatelessWidget {
  const CarAlignApp({super.key});

  ThemeData _theme(Brightness b) => ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: b,
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CarAlign',
      themeMode: ThemeMode.system,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const HomePage(),
    );
  }
}
