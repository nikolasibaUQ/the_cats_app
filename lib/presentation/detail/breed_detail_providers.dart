import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../di/breeds_dependencies.dart';
import '../../domain/entities/breed.dart';
import '../../domain/entities/breed_photo.dart';
import '../../domain/policies/breed_gallery.dart';
import '../breeds_providers.dart';

part 'breed_detail_providers.g.dart';

/// Breed selected by the route ID, resolved from the cached list so a direct
/// route or a browser refresh still finds it.
@riverpod
Future<Breed?> breedById(Ref ref, String breedId) async {
  final breeds = await ref.watch(breedsProvider.future);
  for (final breed in breeds) {
    if (breed.id == breedId) return breed;
  }
  return null;
}

/// Additional photos requested for the selected breed.
@riverpod
Future<List<BreedPhoto>> breedPhotos(Ref ref, String breedId) =>
    ref.watch(breedsRepositoryProvider).getBreedPhotos(breedId);

/// Other breeds offered under the selected one, in the API's own order.
///
/// Detail only renders once the breed is resolved, so reading the cached list
/// here cannot start a second request.
@riverpod
List<Breed> relatedBreeds(Ref ref, String breedId) {
  final breeds = ref.watch(breedsProvider).value ?? const <Breed>[];
  return [
    for (final breed in breeds)
      if (breed.id != breedId) breed,
  ];
}

/// Photos the detail gallery shows: the breed's primary photo followed by every
/// photo already loaded.
///
/// Merging and deduplication are domain rules, and resolving them here leaves
/// the gallery with rendering only.
@riverpod
List<GalleryPhoto> breedGalleryPhotos(Ref ref, String breedId) {
  final breed = ref.watch(breedByIdProvider(breedId)).value;
  final photos = ref.watch(breedPhotosProvider(breedId));
  final imageUrl = breed?.imageUrl;
  final merged = mergeGalleryPhotos(
    primary: breed == null || imageUrl == null
        ? null
        : (url: imageUrl, width: breed.imageWidth, height: breed.imageHeight),
    photos: photos.value ?? const <BreedPhoto>[],
  );
  return merged;
}
