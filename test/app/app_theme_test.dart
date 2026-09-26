import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/app/app_theme.dart';

void main() {
  test('preserves the Pragma palette in the color scheme', () {
    final theme = AppTheme.light;
    final colors = theme.colorScheme;

    expect(colors.primary, const Color(0xFF6429CD));
    expect(colors.onPrimary, const Color(0xFFFFFFFF));
    expect(colors.secondary, const Color(0xFFDD52DD));
    expect(colors.tertiary, const Color(0xFFF8A53C));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF6F7FC));
    expect(colors.surfaceContainer, const Color(0xFFFFFFFF));
    expect(colors.onSurface, const Color(0xFF0C0C0D));
    expect(colors.onSurfaceVariant, const Color(0xFF666669));
    expect(colors.surfaceContainerHighest, const Color(0xFFE8E8ED));
    expect(theme.appBarTheme.backgroundColor, const Color(0xFF330072));
    expect(theme.appBarTheme.foregroundColor, const Color(0xFFFFFFFF));
    expect(
      (theme.inputDecorationTheme.focusedBorder as OutlineInputBorder)
          .borderSide
          .color,
      const Color(0xFF6429CD),
    );
    expect(AppTheme.appBarGradient.colors, const <Color>[
      Color(0xFF330072),
      Color(0xFF6429CD),
    ]);
  });
}
