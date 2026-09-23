import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../domain/entities/breed_reference.dart';
import '../dtos/breed_reference_dto.dart';

/// Reads the breed attributes bundled with the application.
///
/// The live API stopped returning the 1-to-5 ratings, the binary traits, and
/// the article link on the free plan, so `assets/breed_reference.json` keeps a
/// captured dataset of those fields. It is read once per application run, and
/// the loader is injectable so parsing is testable without Flutter bindings.
class BreedReferenceSource {
  BreedReferenceSource({Future<String> Function(String key)? loadAsset})
    : _loadAsset = loadAsset ?? rootBundle.loadString;

  static const String assetKey = 'assets/breed_reference.json';

  final Future<String> Function(String key) _loadAsset;
  Future<Map<String, BreedReference>>? _cached;

  /// Attributes per breed ID, read once per run. Entries that are not objects
  /// are skipped, so a malformed entry cannot drop the whole dataset.
  Future<Map<String, BreedReference>> load() => _cached ??= _read();

  Future<Map<String, BreedReference>> _read() async {
    final raw = await _loadAsset(assetKey);
    final document = jsonDecode(raw);
    if (document is! Map<String, dynamic>) {
      throw const FormatException('Reference dataset is not an object');
    }
    final entries = document['breeds'];
    if (entries is! Map<String, dynamic>) {
      throw const FormatException('Reference dataset has no breeds');
    }
    final references = <String, BreedReference>{};
    entries.forEach((breedId, entry) {
      if (entry is! Map<String, dynamic>) return;
      references[breedId] = BreedReferenceDto.fromJson(entry).toDomain();
    });
    return references;
  }
}
