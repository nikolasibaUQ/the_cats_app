import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/breed_dto.dart';
import 'package:the_cats_app/data/breed_photo_dto.dart';
import 'package:the_cats_app/domain/breed_flag.dart';

void main() {
  test('parses an API breed and normalizes optional values', () {
    final breed = BreedDto.fromJson({
      'id': 'abys',
      'name': 'Abyssinian',
      'description': '  Playful cat  ',
      'weight': {'metric': '3 - 5'},
      'image': {'url': 'https://example.com/cat.jpg'},
      'energy_level': 5,
      'adaptability': 4,
      'grooming': 9,
    }).toDomain();

    expect(breed.id, 'abys');
    expect(breed.description, 'Playful cat');
    expect(breed.weightMetric, '3 - 5');
    expect(breed.energyLevel, 5);
    expect(breed.adaptability, 4);
    expect(breed.grooming, isNull);
  });

  test('maps the ratings, traits, and weight ranges of a full payload', () {
    final breed = BreedDto.fromJson({
      'id': 'beng',
      'name': 'Bengal',
      'alt_names': 'Bengal Cat',
      'origin': 'United States',
      'weight': {'metric': '4 - 7', 'imperial': '8 - 15'},
      'height': {'metric': '33-41', 'imperial': '13-16'},
      'breed_group': 'Short-haired',
      'history': 'Developed by crossing domestic cats.',
      'wikipedia_url': 'https://en.wikipedia.org/wiki/Bengal_cat',
      'adaptability': 4,
      'child_friendly': 5,
      'dog_friendly': 5,
      'stranger_friendly': 3,
      'social_needs': 4,
      'shedding_level': 2,
      'health_issues': 1,
      'vocalisation': 5,
      'hypoallergenic': 1,
      'indoor': 0,
      'rare': true,
      'short_legs': '0',
      'suppressed_tail': 1,
    }).toDomain();

    expect(breed.altNames, 'Bengal Cat');
    expect(breed.weightMetric, '4 - 7');
    expect(breed.weightImperial, '8 - 15');
    expect(breed.heightMetric, '33-41');
    expect(breed.heightImperial, '13-16');
    expect(breed.breedGroup, 'Short-haired');
    expect(breed.history, 'Developed by crossing domestic cats.');
    expect(breed.wikipediaUrl, 'https://en.wikipedia.org/wiki/Bengal_cat');
    expect(breed.childFriendly, 5);
    expect(breed.sheddingLevel, 2);
    expect(breed.vocalisation, 5);
    expect(breed.flags, {
      BreedFlag.hypoallergenic,
      BreedFlag.rare,
      BreedFlag.suppressedTail,
    });
  });

  test('treats unusable links and unknown traits as absent', () {
    final breed = BreedDto.fromJson({
      'id': 'beng',
      'name': 'Bengal',
      'wikipedia_url': '/wiki/Bengal_cat',
      'short_legs': 7,
      'hairless': 'yes',
    }).toDomain();

    expect(breed.wikipediaUrl, isNull);
    expect(breed.flags, isEmpty);
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
