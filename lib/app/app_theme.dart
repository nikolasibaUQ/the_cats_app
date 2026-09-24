import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color _terracotta = Color(0xFFD9A08A);
  static const Color _cream = Color(0xFFFAF8F5);
  static const Color _paper = Color(0xFFFFFFFF);
  static const Color _charcoal = Color(0xFF252525);
  static const Color _warmGray = Color(0xFF6F6B67);
  static const Color _placeholder = Color(0xFFF3EDE5);
  static const Color _border = Color(0xFFE8DDD2);

  static final ThemeData light = _buildLight();

  static ThemeData _buildLight() {
    // These assignments intentionally mirror the approved palette instead of
    // leaving secondary and container tones to seed-color derivation.
    final colors =
        ColorScheme.fromSeed(
          seedColor: _terracotta,
          brightness: Brightness.light,
        ).copyWith(
          primary: _terracotta,
          onPrimary: _charcoal,
          primaryContainer: _placeholder,
          onPrimaryContainer: _charcoal,
          secondary: _warmGray,
          onSecondary: _paper,
          secondaryContainer: _placeholder,
          onSecondaryContainer: _charcoal,
          surface: _cream,
          surfaceTint: _terracotta,
          surfaceContainer: _paper,
          surfaceContainerHighest: _placeholder,
          onSurface: _charcoal,
          onSurfaceVariant: _warmGray,
          outline: _border,
          outlineVariant: _border,
        );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _border),
    );
    final focusedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _terracotta, width: 1.5),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: _cream,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: _charcoal,
        displayColor: _charcoal,
      ),
      // A persistent terracotta bar gives navigation a recognizable home while
      // the content surfaces remain quiet enough for the photos to lead.
      appBarTheme: const AppBarTheme(
        backgroundColor: _terracotta,
        foregroundColor: _charcoal,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _charcoal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: _charcoal),
        actionsIconTheme: IconThemeData(color: _charcoal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _paper,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: focusedInputBorder,
        prefixIconColor: _warmGray,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
