import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/breed.dart';
import 'package:the_cats_app/domain/breed_search.dart';

void main() {
  const breeds = <Breed>[
    Breed(id: 'abys', name: 'Abyssinian', origin: 'Egypt'),
    Breed(id: 'beng', name: 'Bengal', origin: 'United States'),
    Breed(id: 'birm', name: 'Birman', origin: 'Burma'),
  ];

  test('matches a breed name ignoring case and surrounding spaces', () {
    expect(searchBreeds(breeds, '  BENG ').single.id, 'beng');
  });

  test('matches the API-provided origin', () {
    expect(searchBreeds(breeds, 'egy').single.id, 'abys');
  });

  test('keeps the full list when the query is blank', () {
    expect(searchBreeds(breeds, '   '), breeds);
  });

  test('returns no breeds when nothing matches', () {
    expect(searchBreeds(breeds, 'zzz'), isEmpty);
  });

  test('matches breeds without an origin by name only', () {
    const withoutOrigin = <Breed>[Breed(id: 'x', name: 'Cornish Rex')];
    expect(searchBreeds(withoutOrigin, 'rex'), hasLength(1));
    expect(searchBreeds(withoutOrigin, 'egy'), isEmpty);
  });
}
