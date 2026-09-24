import 'dart:ui' show Locale;

import '../domain/entities/breed.dart';

/// Weight range to show for [breed], and the measurement system it belongs to.
///
/// The API states weight in both systems, so the app follows the reading system
/// of the active language: English reads pounds, the remaining languages read
/// kilograms.
({String range, bool imperial})? breedWeight(Breed breed, Locale locale) =>
    _measurement(
      locale,
      metric: breed.weightMetric,
      imperial: breed.weightImperial,
    );

/// Height range to show for [breed], following the same rule as the weight.
({String range, bool imperial})? breedHeight(Breed breed, Locale locale) =>
    _measurement(
      locale,
      metric: breed.heightMetric,
      imperial: breed.heightImperial,
    );

/// Wikipedia search for the breed name.
///
/// The free-plan response never supplies `wikipedia_url`, so the article
/// action always opens a search. The search resolves directly to the article
/// and never points at an unrelated page.
String breedArticleSearchUrl(Breed breed) =>
    'https://en.wikipedia.org/w/index.php'
    '?search=${Uri.encodeQueryComponent('${breed.name} cat')}';

/// Picks the range that matches the active language.
///
/// When the preferred range is missing, the other one is shown with its own
/// unit instead of being mislabelled. A breed without either range returns
/// null, so the caller can omit the value.
({String range, bool imperial})? _measurement(
  Locale locale, {
  required String? metric,
  required String? imperial,
}) {
  final prefersImperial = locale.languageCode == 'en';
  final preferred = prefersImperial ? imperial : metric;
  if (preferred != null) return (range: preferred, imperial: prefersImperial);
  final fallback = prefersImperial ? metric : imperial;
  if (fallback != null) return (range: fallback, imperial: !prefersImperial);
  return null;
}
