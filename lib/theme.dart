import 'package:flutter/material.dart';

const navy = Color(0xFF14315A);
const accent = Color(0xFF0E7C86);
const bg = Color(0xFFF4F6F9);
const border = Color(0xFFDDE3EC);
const ink = Color(0xFF1B2433);
const muted = Color(0xFF667085);
const positive = Color(0xFF1A7F5A);
const negative = Color(0xFFB42318);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: navy, primary: navy, secondary: accent, surface: Colors.white);
  OutlineInputBorder ob(Color c) => OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    textTheme: Typography.blackMountainView.apply(bodyColor: ink, displayColor: ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white, foregroundColor: ink, elevation: 0, scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: border)),
      titleTextStyle: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    ),
    cardTheme: CardThemeData(
      color: Colors.white, elevation: 0, margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: border)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      border: ob(border), enabledBorder: ob(border), focusedBorder: ob(navy), errorBorder: ob(negative),
      focusedErrorBorder: ob(negative),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: navy, foregroundColor: Colors.white, minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.3),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white, indicatorColor: const Color(0xFFE3EAF4), elevation: 0,
      labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    ),
    dividerTheme: const DividerThemeData(color: border, space: 1),
  );
}

String initials(String n) => n.trim().isEmpty ? '?' : n.trim().split(' ').map((p) => p[0]).take(2).join().toUpperCase();
