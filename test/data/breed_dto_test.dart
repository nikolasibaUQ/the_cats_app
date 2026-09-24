import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/dtos/breed_dto.dart';
import 'package:the_cats_app/data/dtos/breed_photo_dto.dart';

void main() {
  test('parses an API breed and normalizes optional values', () {
    final breed = BreedDto.fromJson({
      'id': 'abys',
      'name': 'Abyssinian',
      'description': '  Playful cat  ',
      'weight': {'metric': '3 - 5'},
      'image': {'url': 'https://example.com/cat.jpg'},
    }).toDomain();

    expect(breed.id, 'abys');
    expect(breed.description, 'Playful cat');
    expect(breed.weightMetric, '3 - 5');
  });

  test('maps the factual fields of the free-plan payload', () {
    final breed = BreedDto.fromJson({
      'id': 'beng',
      'name': 'Bengal',
      'origin': 'United States',
      'weight': {'metric': '4 - 7', 'imperial': '8 - 15'},
      'height': {'metric': '33-41', 'imperial': '13-16'},
      'breed_group': 'Short-haired',
      'history': 'Developed by crossing domestic cats.',
    }).toDomain();

    expect(breed.origin, 'United States');
    expect(breed.weightMetric, '4 - 7');
    expect(breed.weightImperial, '8 - 15');
    expect(breed.heightMetric, '33-41');
    expect(breed.heightImperial, '13-16');
    expect(breed.breedGroup, 'Short-haired');
    expect(breed.history, 'Developed by crossing domestic cats.');
  });

  test('rejects a breed without usable identity', () {
    expect(
      () => BreedDto.fromJson({'id': '', 'name': 'Cat'}).toDomain(),
      throwsFormatException,
    );
  });

  test('parses a gallery photo and rejects an invalid URL', () {
    final photo = BreedPhotoDto.fromJson({
      'id': 'cat-1',
      'url': 'https://cdn2.thecatapi.com/images/cat-1.jpg',
      'width': 1200,
      'height': 800,
    }).toDomain();

    expect(photo.id, 'cat-1');
    expect(photo.width, 1200);
    expect(
      () => BreedPhotoDto.fromJson({
        'id': 'cat-2',
        'url': '/relative.jpg',
      }).toDomain(),
      throwsFormatException,
    );
  });
}
