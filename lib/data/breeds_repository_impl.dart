import '../domain/breed.dart';
import '../domain/breed_photo.dart';
import '../domain/breeds_repository.dart';
import 'breeds_remote_data_source.dart';

class BreedsRepositoryImpl implements BreedsRepository {
  const BreedsRepositoryImpl({required BreedsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final BreedsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Breed>> getBreeds() async {
    final dtos = await _remoteDataSource.getBreeds();
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async {
    final dtos = await _remoteDataSource.getBreedPhotos(breedId, limit: limit);
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
