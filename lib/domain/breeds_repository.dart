import 'breed.dart';
import 'breed_photo.dart';

abstract interface class BreedsRepository {
  Future<List<Breed>> getBreeds();

  Future<List<BreedPhoto>> getBreedPhotos(String breedId, {int limit = 8});
}
