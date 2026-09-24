import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_locale_controller.g.dart';

/// Languages the user can pick for the interface.
///
/// The language menu renders these in order; the controller owns which one is
/// active. Keeping the options here leaves the menu with rendering only.
enum AppLanguage {
  system(null),
  spanish(Locale('es')),
  english(Locale('en'));

  const AppLanguage(this.locale);

  /// Locale this option applies, or null to follow the system language.
  final Locale? locale;
}

/// Interface language selected by the user.
@Riverpod(keepAlive: true)
class AppLocaleController extends _$AppLocaleController {
  @override
  AppLanguage build() => AppLanguage.system;

  void select(AppLanguage language) => state = language;
}
