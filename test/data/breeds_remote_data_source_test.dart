import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/sources/breeds_remote_data_source.dart';

Dio _dioResponding(List<dynamic>? data) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) => handler.resolve(
        Response<List<dynamic>>(requestOptions: options, data: data),
      ),
    ),
  );
  return dio;
}

void main() {
  test('rejects a photo request without a breed identifier', () async {
    final source = DioBreedsRemoteDataSource(dio: Dio());
    addTearDown(source.close);

    await expectLater(
      source.getBreedPhotos('  '),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('rejects a photo limit outside the API bounds', () async {
    final source = DioBreedsRemoteDataSource(dio: Dio());
    addTearDown(source.close);

    await expectLater(
      source.getBreedPhotos('abys', limit: 0),
      throwsA(isA<RangeError>()),
    );
    await expectLater(
      source.getBreedPhotos('abys', limit: 26),
      throwsA(isA<RangeError>()),
    );
  });

  test('rejects a missing list response', () async {
    final source = DioBreedsRemoteDataSource(dio: _dioResponding(null));
    addTearDown(source.close);

    await expectLater(source.getBreeds(), throwsA(isA<FormatException>()));
  });

  test('rejects a response whose entries are not JSON objects', () async {
    final source = DioBreedsRemoteDataSource(
      dio: _dioResponding(<dynamic>['not a breed photo']),
    );
    addTearDown(source.close);

    await expectLater(
      source.getBreedPhotos('abys'),
      throwsA(isA<FormatException>()),
    );
  });
}
