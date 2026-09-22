import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Viewport measurements and bounded visual scaling shared by app screens.
/// Layout decisions still use their own available constraints.
class Responsive {
  const Responsive.fromSize(this._viewport);

  factory Responsive(BuildContext context) =>
      Responsive.fromSize(MediaQuery.sizeOf(context));

  factory Responsive.of(BuildContext context) => Responsive(context);

  final Size _viewport;

  double get width => _viewport.width;
  double get height => _viewport.height;
  double get diagonal => math.sqrt(width * width + height * height);
  bool get isTablet => _viewport.shortestSide >= 600;
  bool get isDesktop => width >= 1024;
  bool get isLandscape => width > height;

  double wp(double percent) => width * percent / 100;
  double hp(double percent) => height * percent / 100;
  double dp(double percent) => diagonal * percent / 100;

  double get _spacingScale {
    if (width < 360) return 0.90;
    if (width < 400) return 0.95;
    if (isDesktop) return 1.10;
    if (isTablet) return 1.05;
    return 1;
  }

  double size(num value) => value * _spacingScale;
  double spacing(num value) => size(value);
  double radius(num value) => size(value);
  double icon(num value) => size(value);
  double get pagePadding => spacing(isDesktop ? 32 : 20);

  EdgeInsets insets({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => EdgeInsets.fromLTRB(
    spacing(left),
    spacing(top),
    spacing(right),
    spacing(bottom),
  );

  EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(
        horizontal: spacing(horizontal),
        vertical: spacing(vertical),
      );

  // Keep the original diagonal helpers for designs that need proportional
  // dimensions. Bounds prevent extreme sizes on tall or ultrawide viewports.
  double fp(int designFontSize) =>
      designFontSize * (diagonal / _mobileDesignDiagonal).clamp(0.90, 1.15);

  double fpw(int designFontSize) =>
      designFontSize * (diagonal / _webDesignDiagonal).clamp(0.90, 1.15);

  static final double _mobileDesignDiagonal = math.sqrt(400 * 400 + 853 * 853);
  static final double _webDesignDiagonal = math.sqrt(1046 * 1046 + 1366 * 1366);
}
