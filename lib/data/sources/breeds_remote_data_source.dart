import 'package:dio/dio.dart';

import '../dtos/dtos.dart';

abstract interface class BreedsRemoteDataSource {
  Future<List<BreedDto>> getBreeds();

  Future<List<BreedPhotoDto>> getBreedPhotos(String breedId, {int limit = 8});
}

class DioBreedsRemoteDataSource implements BreedsRemoteDataSource {
  DioBreedsRemoteDataSource({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  @override
  Future<List<BreedDto>> getBreeds() async {
    final response = await _dio.get<List<dynamic>>('/breeds');
    return _parseList(response.data, BreedDto.fromJson, 'breeds');
  }

  @override
  Future<List<BreedPhotoDto>> getBreedPhotos(
    String breedId, {
    int limit = 10,
  }) async {
    final normalizedId = breedId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(breedId, 'breedId', 'Cannot be empty');
    }
    if (limit < 1 || limit > 25) {
      throw RangeError.range(limit, 1, 25, 'limit');
    }

    final response = await _dio.get<List<dynamic>>(
      '/images/search',
      queryParameters: <String, Object>{
        'breed_ids': normalizedId,
        'limit': limit,
        'size': 'med',
        'mime_types': 'jpg,png',
        'order': 'ASC',
      },
    );
    return _parseList(response.data, BreedPhotoDto.fromJson, 'breed photos');
  }

  void close() => _dio.close();
}

List<T> _parseList<T>(
  List<dynamic>? data,
  T Function(Map<String, dynamic>) fromJson,
  String responseName,
) {
  if (data == null) throw FormatException('Missing $responseName response');
  return data.map((item) {
    if (item is! Map<String, dynamic>) {
      throw FormatException('Invalid $responseName entry');
    }
    return fromJson(item);
  }).toList();
}

Dio _createDio() {
  const apiKey = String.fromEnvironment('CAT_API_KEY');
  return Dio(
    BaseOptions(
      baseUrl: 'https://api.thecatapi.com/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {if (apiKey.isNotEmpty) 'x-api-key': apiKey},
    ),
  );
}
