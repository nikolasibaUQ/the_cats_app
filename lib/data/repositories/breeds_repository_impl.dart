import '../../domain/entities/entities.dart';
import '../../domain/repositories/breeds_repository.dart';
import '../sources/breed_reference_source.dart';
import '../sources/breeds_remote_data_source.dart';

class BreedsRepositoryImpl implements BreedsRepository {
  BreedsRepositoryImpl({
    required BreedsRemoteDataSource remoteDataSource,
    required BreedReferenceSource referenceSource,
  }) : _remoteDataSource = remoteDataSource,
       _referenceSource = referenceSource;

  final BreedsRemoteDataSource _remoteDataSource;
  final BreedReferenceSource _referenceSource;

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

  @override
  Future<Map<String, BreedReference>> getBreedReferences() =>
      _referenceSource.load();
}
