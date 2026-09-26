import '../entities/entities.dart';

abstract interface class BreedsRepository {
  Future<List<Breed>> getBreeds();

  Future<List<BreedPhoto>> getBreedPhotos(String breedId, {int limit = 8});

  /// Traits of every breed the bundled reference dataset covers.
  ///
  /// The dataset is read once per run, so this resolves from a cache after the
  /// first call.
  Future<Map<String, BreedReference>> getBreedReferences();
}
