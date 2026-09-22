import 'breed.dart';

abstract interface class BreedsRepository {
  Future<List<Breed>> getBreeds();
}
