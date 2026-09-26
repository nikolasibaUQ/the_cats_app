import 'package:flutter/material.dart';

/// Central visual identity of the application.
///
/// Tokens follow the official Pragma design system palette: vivid purple leads
/// navigation and actions, fuchsia tints playful accents, and amber marks the
/// few places that deserve a flash of color. Widgets read colors exclusively
/// through `Theme.of`, so the whole palette stays in this one file.
abstract final class AppTheme {
  // Pragma primary palette (purples).
  static const Color _purple50 = Color(0xFFF7DDF8);
  static const Color _purple500 = Color(0xFF6429CD);
  static const Color _purple700 = Color(0xFF330072);
  static const Color _purple900 = Color(0xFF1F0D3F);

  // Pragma secondary palette (fuchsias).
  static const Color _fuchsia50 = Color(0xFFFDF9FF);
  static const Color _fuchsia700 = Color(0xFFDD52DD);
  static const Color _fuchsia900 = Color(0xFF7500A0);

  // Pragma tertiary accent (ambers).
  static const Color _amber50 = Color(0xFFFDECD0);
  static const Color _amber500 = Color(0xFFF8A53C);
  static const Color _amber700 = Color(0xFFC77C07);

  // Pragma neutral grays.
  static const Color _gray50 = Color(0xFFF6F7FC);
  static const Color _gray100 = Color(0xFFE8E8ED);
  static const Color _gray200 = Color(0xFFD2D2D6);
  static const Color _gray400 = Color(0xFF9D9DA1);
  static const Color _gray600 = Color(0xFF666669);
  static const Color _gray900 = Color(0xFF0C0C0D);

  static const Color _paper = Color(0xFFFFFFFF);
  static const Color _error = Color(0xFFED0039);

  /// Brand gradient painted behind the catalog and compact-detail app bars.
  static const LinearGradient appBarGradient = LinearGradient(
    colors: <Color>[_purple700, _purple500],
  );

  static final ThemeData light = _buildLight();

  static ThemeData _buildLight() {
    // These assignments intentionally mirror the Pragma palette instead of
    // leaving secondary and container tones to seed-color derivation.
    final colors =
        ColorScheme.fromSeed(
          seedColor: _purple500,
          brightness: Brightness.light,
        ).copyWith(
          primary: _purple500,
          onPrimary: _paper,
          primaryContainer: _purple50,
          onPrimaryContainer: _purple900,
          secondary: _fuchsia700,
          onSecondary: _paper,
          secondaryContainer: _fuchsia50,
          onSecondaryContainer: _fuchsia900,
          tertiary: _amber500,
          onTertiary: _gray900,
          tertiaryContainer: _amber50,
          onTertiaryContainer: _amber700,
          error: _error,
          onError: _paper,
          surface: _gray50,
          surfaceTint: _purple500,
          surfaceContainer: _paper,
          surfaceContainerHighest: _gray100,
          onSurface: _gray900,
          onSurfaceVariant: _gray600,
          outline: _gray400,
          outlineVariant: _gray200,
        );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _gray200),
    );
    final focusedInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _purple500, width: 2),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: _gray50,
      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: _gray900,
        displayColor: _gray900,
      ),
      // The purple bar is the recognizable brand home; screens paint the
      // `appBarGradient` over it through their flexible space, and this solid
      // tone remains the fallback while the bar settles.
      appBarTheme: const AppBarTheme(
        backgroundColor: _purple700,
        foregroundColor: _paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _paper,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: _paper),
        actionsIconTheme: IconThemeData(color: _paper),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _paper,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: focusedInputBorder,
        prefixIconColor: _gray600,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
