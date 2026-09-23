import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/breed_gallery.dart';
import 'package:the_cats_app/domain/breed_photo.dart';

void main() {
  const photos = <BreedPhoto>[
    BreedPhoto(
      id: 'photo-1',
      url: 'https://example.com/photo-1.jpg',
      width: 1200,
      height: 800,
    ),
    BreedPhoto(id: 'photo-2', url: 'https://example.com/photo-2.jpg'),
  ];

  test('keeps the primary image first and deduplicates it', () {
    expect(
      breedGalleryImageUrls(
        primaryUrl: 'https://example.com/photo-1.jpg',
        photos: photos,
      ),
      ['https://example.com/photo-1.jpg', 'https://example.com/photo-2.jpg'],
    );
  });

  test('keeps the search photos when the breed has no usable image', () {
    expect(breedGalleryImageUrls(primaryUrl: '  ', photos: photos), [
      'https://example.com/photo-1.jpg',
      'https://example.com/photo-2.jpg',
    ]);
    expect(
      breedGalleryImageUrls(primaryUrl: null, photos: photos),
      hasLength(2),
    );
  });

  test('returns no images when the breed and the search have none', () {
    expect(breedGalleryImageUrls(primaryUrl: null, photos: const []), isEmpty);
  });
}
