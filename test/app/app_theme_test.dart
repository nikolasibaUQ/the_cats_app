import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/app/app_theme.dart';

void main() {
  test('preserves the approved warm palette in the color scheme', () {
    final theme = AppTheme.light;
    final colors = theme.colorScheme;

    expect(colors.primary, const Color(0xFFD9A08A));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFFAF8F5));
    expect(colors.surfaceContainer, const Color(0xFFFFFFFF));
    expect(colors.onSurface, const Color(0xFF252525));
    expect(colors.onSurfaceVariant, const Color(0xFF6F6B67));
    expect(colors.surfaceContainerHighest, const Color(0xFFF3EDE5));
    expect(theme.appBarTheme.backgroundColor, const Color(0xFFD9A08A));
    expect(theme.appBarTheme.foregroundColor, const Color(0xFF252525));
    expect(
      (theme.inputDecorationTheme.focusedBorder as OutlineInputBorder)
          .borderSide
          .color,
      const Color(0xFFD9A08A),
    );
  });
}
