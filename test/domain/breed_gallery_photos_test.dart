import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/entities/breed_photo.dart';
import 'package:the_cats_app/domain/policies/breed_gallery.dart';

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

  test('keeps the primary photo first and deduplicates it', () {
    expect(
      mergeGalleryPhotos(
        primary: (
          url: 'https://example.com/photo-1.jpg',
          width: 1600,
          height: 1000,
        ),
        photos: photos,
      ),
      <GalleryPhoto>[
        // The breed entry wins over the search entry with the same URL, and it
        // keeps the size the breeds response states for it.
        (url: 'https://example.com/photo-1.jpg', width: 1600, height: 1000),
        (url: 'https://example.com/photo-2.jpg', width: null, height: null),
      ],
    );
  });

  test('keeps the search photos when the breed has no usable photo', () {
    expect(
      mergeGalleryPhotos(
        primary: (url: '  ', width: null, height: null),
        photos: photos,
      ),
      <GalleryPhoto>[
        (url: 'https://example.com/photo-1.jpg', width: 1200, height: 800),
        (url: 'https://example.com/photo-2.jpg', width: null, height: null),
      ],
    );
    expect(mergeGalleryPhotos(primary: null, photos: photos), hasLength(2));
  });

  test('returns no photos when the breed and the search have none', () {
    expect(mergeGalleryPhotos(primary: null, photos: const []), isEmpty);
  });
}
