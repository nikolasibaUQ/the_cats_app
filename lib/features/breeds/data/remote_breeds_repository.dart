import 'package:dio/dio.dart';

import '../domain/breed.dart';
import '../domain/breeds_repository.dart';
import 'breed_dto.dart';

class RemoteBreedsRepository implements BreedsRepository {
  RemoteBreedsRepository({Dio? dio}) : _dio = dio ?? _createDio();

  final Dio _dio;

  @override
  Future<List<Breed>> getBreeds() async {
    final response = await _dio.get<List<dynamic>>('/breeds');
    final data = response.data;
    if (data == null) throw const FormatException('Missing breeds response');
    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid breed entry');
      }
      return BreedDto.fromJson(item).toDomain();
    }).toList();
  }

  void close() => _dio.close();
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
