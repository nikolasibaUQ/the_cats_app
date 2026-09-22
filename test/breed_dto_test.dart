import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/features/breeds/data/breed_dto.dart';

void main() {
  test('parses an API breed and normalizes optional values', () {
    final breed = BreedDto.fromJson({
      'id': 'abys',
      'name': 'Abyssinian',
      'description': '  Playful cat  ',
      'weight': {'metric': '3 - 5'},
      'image': {'url': 'https://example.com/cat.jpg'},
      'energy_level': 5,
      'grooming': 9,
    }).toDomain();

    expect(breed.id, 'abys');
    expect(breed.description, 'Playful cat');
    expect(breed.weightMetric, '3 - 5');
    expect(breed.energyLevel, 5);
    expect(breed.grooming, isNull);
  });

  test('rejects a breed without usable identity', () {
    expect(
      () => BreedDto.fromJson({'id': '', 'name': 'Cat'}).toDomain(),
      throwsFormatException,
    );
  });
}
