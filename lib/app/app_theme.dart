import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color _terracotta = Color(0xFFB96E52);
  static const Color _cream = Color(0xFFFAF8F5);
  static const Color _paper = Color(0xFFFFFFFF);
  static const Color _charcoal = Color(0xFF252525);
  static const Color _warmGray = Color(0xFF6F6B67);
  static const Color _placeholder = Color(0xFFF3EDE5);
  static const Color _border = Color(0xFFE8DDD2);

  static final ThemeData light = _buildLight();

  static ThemeData _buildLight() {
    final colors = ColorScheme.fromSeed(seedColor: _terracotta).copyWith(
      primary: _terracotta,
      surface: _cream,
      surfaceContainer: _paper,
      surfaceContainerHighest: _placeholder,
      onSurface: _charcoal,
      onSurfaceVariant: _warmGray,
      outlineVariant: _border,
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: _cream,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: _charcoal,
        displayColor: _charcoal,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _cream,
        foregroundColor: _charcoal,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _paper,
        border: inputBorder,
        enabledBorder: inputBorder,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
