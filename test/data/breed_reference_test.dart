import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/dtos/breed_reference_dto.dart';
import 'package:the_cats_app/data/sources/breed_reference_source.dart';
import 'package:the_cats_app/domain/entities/breed.dart';
import 'package:the_cats_app/domain/entities/breed_flag.dart';
import 'package:the_cats_app/domain/entities/breed_reference.dart';

void main() {
  test('parses a reference entry with its ratings and traits', () {
    final reference = BreedReferenceDto.fromJson({
      'adaptability': 5,
      'intelligence': 5,
      'shedding_level': 3,
      'health_issues': 7,
      'traits': ['hypoallergenic', 'not_a_trait', 'rex'],
      'wikipedia_url': 'https://en.wikipedia.org/wiki/Bengal_(cat)',
    }).toDomain();

    expect(reference.adaptability, 5);
    expect(reference.intelligence, 5);
    expect(reference.sheddingLevel, 3);
    expect(reference.healthIssues, isNull);
    expect(reference.flags, {BreedFlag.hypoallergenic, BreedFlag.rex});
    expect(
      reference.wikipediaUrl,
      'https://en.wikipedia.org/wiki/Bengal_(cat)',
    );
  });

  test('keeps the values the live API already supplied', () {
    const breed = Breed(
      id: 'beng',
      name: 'Bengal',
      origin: 'United States',
      intelligence: 2,
      flags: {BreedFlag.indoor},
    );
    const reference = BreedReference(
      adaptability: 5,
      intelligence: 5,
      flags: {BreedFlag.hypoallergenic},
      wikipediaUrl: 'https://en.wikipedia.org/wiki/Bengal_(cat)',
    );

    final merged = breed.fillFrom(reference);

    expect(merged.intelligence, 2, reason: 'the API value wins');
    expect(merged.adaptability, 5, reason: 'the reference fills the gap');
    expect(merged.origin, 'United States');
    expect(merged.flags, {
      BreedFlag.indoor,
    }, reason: 'a payload with its own traits keeps them');
    expect(merged.wikipediaUrl, 'https://en.wikipedia.org/wiki/Bengal_(cat)');
  });

  test('returns the breed untouched without a reference', () {
    const breed = Breed(id: 'beng', name: 'Bengal');
    expect(breed.fillFrom(null), same(breed));
  });

  test('reads the bundled dataset that ships with the application', () async {
    final source = BreedReferenceSource(
      loadAsset: (key) async {
        expect(key, BreedReferenceSource.assetKey);
        return File(BreedReferenceSource.assetKey).readAsString();
      },
    );

    final references = await source.load();

    expect(references.length, greaterThan(60));
    final beng = references['beng'];
    expect(beng, isNotNull);
    expect(beng!.adaptability, 5);
    expect(beng.intelligence, 5);
    expect(beng.sheddingLevel, 3);
    expect(beng.flags, contains(BreedFlag.hypoallergenic));
    expect(beng.wikipediaUrl, 'https://en.wikipedia.org/wiki/Bengal_(cat)');
  });

  test(
    'ignores entries that are not objects and reports a broken document',
    () async {
      final tolerant = BreedReferenceSource(
        loadAsset: (key) async => '{"breeds": {"beng": "nonsense"}}',
      );
      expect(await tolerant.load(), isEmpty);

      final broken = BreedReferenceSource(loadAsset: (key) async => '[]');
      expect(broken.load(), throwsFormatException);

      final withoutBreeds = BreedReferenceSource(
        loadAsset: (key) async => '{"note": "no breeds"}',
      );
      expect(withoutBreeds.load(), throwsFormatException);
    },
  );
}
