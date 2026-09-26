import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/di/breeds_dependencies.dart';
import 'package:the_cats_app/domain/entities/breed.dart';
import 'package:the_cats_app/domain/entities/breed_photo.dart';
import 'package:the_cats_app/domain/entities/breed_reference.dart';
import 'package:the_cats_app/domain/policies/breed_gallery.dart';
import 'package:the_cats_app/domain/repositories/breeds_repository.dart';
import 'package:the_cats_app/presentation/catalog/providers/breeds_providers.dart';
import 'package:the_cats_app/presentation/detail/providers/breed_detail_providers.dart';

const String _primaryImage = 'https://example.com/beng.jpg';

const BreedReference _bengReference = BreedReference(
  energyLevel: 5,
  affectionLevel: 4,
  intelligence: 5,
  grooming: 1,
  socialNeeds: 3,
  hypoallergenic: false,
  rare: false,
  lap: true,
);

class _FailingPhotosRepository implements BreedsRepository {
  @override
  Future<List<Breed>> getBreeds() async => const [
    Breed(
      id: 'beng',
      name: 'Bengal',
      imageUrl: _primaryImage,
      imageWidth: 1600,
      imageHeight: 1000,
    ),
  ];

  @override
  Future<List<BreedPhoto>> getBreedPhotos(String breedId, {int limit = 8}) =>
      Future<List<BreedPhoto>>.error(Exception('Gallery unavailable'));

  @override
  Future<Map<String, BreedReference>> getBreedReferences() async => const {
    'beng': _bengReference,
  };
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        breedsRepositoryProvider.overrideWithValue(_FailingPhotosRepository()),
      ],
    );
    addTearDown(container.dispose);
  });

  test(
    'keeps the primary photo available when the photo request fails',
    () async {
      // Keeps the gallery chain alive, so the states below are the same
      // elements the screen would observe.
      final subscription = container.listen(
        breedGalleryPhotosProvider('beng'),
        (previous, next) {},
      );
      addTearDown(subscription.close);

      await container.read(breedByIdProvider('beng').future);
      // Let the failing photo request settle before reading its state.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(container.read(breedPhotosProvider('beng')).hasError, isTrue);
      // The size travels with the photo: the detail area adopts its shape.
      expect(container.read(breedGalleryPhotosProvider('beng')), <GalleryPhoto>[
        (url: _primaryImage, width: 1600, height: 1000),
      ]);
    },
  );

  test('resolves the breed traits from the bundled dataset', () async {
    await container.read(breedReferencesProvider.future);

    expect(container.read(breedReferenceProvider('beng')), _bengReference);
    expect(container.read(breedReferenceProvider('missing')), isNull);
  });
}
