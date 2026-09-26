import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/dtos/breed_reference_dto.dart';
import 'package:the_cats_app/data/sources/breed_reference_source.dart';

void main() {
  test('parses a reference entry with its ratings and traits', () {
    final reference = BreedReferenceDto.fromJson({
      'energy_level': 5,
      'affection_level': 4,
      'intelligence': 5,
      'grooming': 1,
      'social_needs': 3,
      'hypoallergenic': false,
      'rare': false,
      'lap': true,
    }).toDomain();

    expect(reference.energyLevel, 5);
    expect(reference.affectionLevel, 4);
    expect(reference.intelligence, 5);
    expect(reference.grooming, 1);
    expect(reference.socialNeeds, 3);
    expect(reference.hypoallergenic, isFalse);
    expect(reference.rare, isFalse);
    expect(reference.lap, isTrue);
  });

  test('keeps an out-of-range rating on the 1-to-5 scale', () {
    final reference = BreedReferenceDto.fromJson({
      'energy_level': 9,
      'affection_level': 0,
      'intelligence': 3,
      'grooming': 1,
      'social_needs': 2,
      'hypoallergenic': false,
      'rare': false,
      'lap': true,
    }).toDomain();

    expect(reference.energyLevel, 5);
    expect(reference.affectionLevel, 1);
  });

  test('reads entries and skips the ones that are not objects', () async {
    final source = BreedReferenceSource(
      loadAsset: (_) async => jsonEncode({
        'breeds': {
          'abys': {
            'energy_level': 5,
            'affection_level': 5,
            'intelligence': 5,
            'grooming': 1,
            'social_needs': 5,
            'hypoallergenic': false,
            'rare': false,
            'lap': true,
          },
          'broken': 'not an object',
        },
      }),
    );

    final references = await source.load();

    expect(references, hasLength(1));
    expect(references['abys']!.intelligence, 5);
  });

  test('rejects a document that is not an object', () async {
    final source = BreedReferenceSource(loadAsset: (_) async => '[]');

    expect(source.load(), throwsA(isA<FormatException>()));
  });

  test('rejects a document without the breeds map', () async {
    final source = BreedReferenceSource(loadAsset: (_) async => '{}');

    expect(source.load(), throwsA(isA<FormatException>()));
  });

  test('the bundled dataset covers the live list with valid values', () async {
    final source = BreedReferenceSource(
      loadAsset: (key) async {
        expect(key, BreedReferenceSource.assetKey);
        return File(BreedReferenceSource.assetKey).readAsString();
      },
    );

    final references = await source.load();

    // The live API lists more than 100 breeds, and the trial dataset keeps an
    // entry per breed ID.
    expect(references.length, greaterThan(100));
    for (final entry in references.values) {
      for (final rating in <int>[
        entry.energyLevel,
        entry.affectionLevel,
        entry.intelligence,
        entry.grooming,
        entry.socialNeeds,
      ]) {
        expect(rating, inInclusiveRange(1, 5));
      }
    }
    // Both binary states exist, so the UI renders true and false rows.
    final values = references.values;
    expect(values.any((entry) => entry.lap), isTrue);
    expect(values.any((entry) => !entry.lap), isTrue);
    expect(values.any((entry) => entry.hypoallergenic), isTrue);
    expect(values.any((entry) => !entry.hypoallergenic), isTrue);
    expect(values.any((entry) => entry.rare), isTrue);
    expect(values.any((entry) => !entry.rare), isTrue);
  });
}
