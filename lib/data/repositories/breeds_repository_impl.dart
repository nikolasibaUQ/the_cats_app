import 'package:flutter/foundation.dart' show debugPrint;

import '../../domain/entities/breed.dart';
import '../../domain/entities/breed_photo.dart';
import '../../domain/entities/breed_reference.dart';
import '../../domain/repositories/breeds_repository.dart';
import '../sources/breed_reference_source.dart';
import '../sources/breeds_remote_data_source.dart';

class BreedsRepositoryImpl implements BreedsRepository {
  BreedsRepositoryImpl({
    required BreedsRemoteDataSource remoteDataSource,
    BreedReferenceSource? referenceSource,
  }) : _remoteDataSource = remoteDataSource,
       _referenceSource = referenceSource ?? BreedReferenceSource();

  final BreedsRemoteDataSource _remoteDataSource;
  final BreedReferenceSource _referenceSource;

  @override
  Future<List<Breed>> getBreeds() async {
    final dtos = await _remoteDataSource.getBreeds();
    final references = await _references();
    return [
      for (final dto in dtos) dto.toDomain().fillFrom(references[dto.id]),
    ];
  }

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async {
    final dtos = await _remoteDataSource.getBreedPhotos(breedId, limit: limit);
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  /// Reference attributes are optional: when the bundled dataset cannot be
  /// read, the API data stays as it arrived instead of failing the catalog.
  Future<Map<String, BreedReference>> _references() async {
    try {
      return await _referenceSource.load();
    } on Object catch (error) {
      debugPrint('Bundled breed reference unavailable: $error');
      return const <String, BreedReference>{};
    }
  }
}
