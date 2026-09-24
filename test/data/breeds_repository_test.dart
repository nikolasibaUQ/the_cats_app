import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/repositories/breeds_repository_impl.dart';
import 'package:the_cats_app/data/sources/breeds_remote_data_source.dart';

Dio dioReturning(List<Map<String, Object?>> data) {
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
  test('maps the breeds response into domain data', () async {
    final dio = dioReturning([
      {
        'id': 'abys',
        'name': 'Abyssinian',
        'image': {'url': 'https://example.com/cat.jpg'},
        'weight': {'metric': '3 - 5'},
      },
    ]);

    final breeds = await BreedsRepositoryImpl(
      remoteDataSource: DioBreedsRemoteDataSource(dio: dio),
    ).getBreeds();

    expect(breeds, hasLength(1));
    expect(breeds.single.name, 'Abyssinian');
    expect(breeds.single.weightMetric, '3 - 5');
    expect(breeds.single.imageUrl, 'https://example.com/cat.jpg');
  });

  test('maps the size the API states for the primary photo', () async {
    final dio = dioReturning([
      {
        'id': 'abys',
        'name': 'Abyssinian',
        'image': {
          'url': 'https://cdn2.thecatapi.com/images/abys.jpg',
          'width': 3114,
          'height': 2609,
        },
      },
      {
        'id': 'amer',
        'name': 'American Ringtail',
        'image': {
          'url': 'https://cdn2.thecatapi.com/images/amer.jpg',
          'width': 0,
          'height': 0,
        },
      },
    ]);

    final breeds = await BreedsRepositoryImpl(
      remoteDataSource: DioBreedsRemoteDataSource(dio: dio),
    ).getBreeds();

    // The detail photo area frames the photo with this proportion.
    expect(breeds.first.imageWidth, 3114);
    expect(breeds.first.imageHeight, 2609);
    // A size that cannot be one stays unknown instead of shaping the area.
    expect(breeds.last.imageWidth, isNull);
    expect(breeds.last.imageHeight, isNull);
  });

  test('keeps optional facts absent when the API omits them', () async {
    final dio = dioReturning([
      {
        'id': 'beng',
        'name': 'Bengal',
        'origin': 'United States',
        'image': {
          'url': 'https://cdn2.thecatapi.com/images/beng.jpg',
          'width': 1600,
          'height': 1000,
        },
      },
    ]);
    final breeds = await BreedsRepositoryImpl(
      remoteDataSource: DioBreedsRemoteDataSource(dio: dio),
    ).getBreeds();

    expect(breeds.single.breedGroup, isNull);
    expect(breeds.single.history, isNull);
    expect(breeds.single.origin, 'United States');
    expect(
      breeds.single.imageUrl,
      'https://cdn2.thecatapi.com/images/beng.jpg',
    );
    expect(breeds.single.imageWidth, 1600);
    expect(breeds.single.imageHeight, 1000);
  });

  test('requests and maps photos for one breed', () async {
    final dio = Dio();
    RequestOptions? capturedRequest;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          capturedRequest = options;
          handler.resolve(
            Response<List<dynamic>>(
              requestOptions: options,
              data: [
                {
                  'id': 'photo-1',
                  'url': 'https://cdn2.thecatapi.com/images/photo-1.jpg',
                  'width': 1200,
                  'height': 800,
                },
              ],
            ),
          );
        },
      ),
    );

    final photos = await BreedsRepositoryImpl(
      remoteDataSource: DioBreedsRemoteDataSource(dio: dio),
    ).getBreedPhotos('beng', limit: 6);

    expect(capturedRequest?.path, '/images/search');
    expect(capturedRequest?.queryParameters['breed_ids'], 'beng');
    expect(capturedRequest?.queryParameters['limit'], 6);
    expect(photos.single.id, 'photo-1');
  });
}
