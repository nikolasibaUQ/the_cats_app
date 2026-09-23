import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/entities/breed.dart';
import 'package:the_cats_app/presentation/breed_formatting.dart';

void main() {
  const breed = Breed(
    id: 'beng',
    name: 'Bengal',
    weightMetric: '4 - 7',
    weightImperial: '8 - 15',
  );

  test('reads kilograms in a language that uses the metric system', () {
    expect(breedWeight(breed, const Locale('es')), (
      range: '4 - 7',
      imperial: false,
    ));
  });

  test('reads pounds in English', () {
    expect(breedWeight(breed, const Locale('en')), (
      range: '8 - 15',
      imperial: true,
    ));
  });

  test('falls back to the other system together with its own unit', () {
    const metricOnly = Breed(
      id: 'abys',
      name: 'Abyssinian',
      weightMetric: '3 - 5',
    );
    expect(breedWeight(metricOnly, const Locale('en')), (
      range: '3 - 5',
      imperial: false,
    ));
  });

  test('reports no weight when the API provides none', () {
    expect(
      breedWeight(
        const Breed(id: 'abys', name: 'Abyssinian'),
        const Locale('es'),
      ),
      isNull,
    );
  });

  test('reads height in the same system as the weight', () {
    const sized = Breed(
      id: 'beng',
      name: 'Bengal',
      heightMetric: '33-41',
      heightImperial: '13-16',
    );
    expect(breedHeight(sized, const Locale('es')), (
      range: '33-41',
      imperial: false,
    ));
    expect(breedHeight(sized, const Locale('en')), (
      range: '13-16',
      imperial: true,
    ));
  });

  test('prefers the article the API supplies', () {
    expect(
      breedArticleUrl(
        const Breed(
          id: 'beng',
          name: 'Bengal',
          wikipediaUrl: 'https://en.wikipedia.org/wiki/Bengal_cat',
        ),
      ),
      'https://en.wikipedia.org/wiki/Bengal_cat',
    );
  });

  test('searches Wikipedia by name when the API supplies no article', () {
    expect(
      breedArticleUrl(const Breed(id: 'abys', name: 'Abyssinian')),
      'https://en.wikipedia.org/w/index.php?search=Abyssinian+cat',
    );
  });
}
