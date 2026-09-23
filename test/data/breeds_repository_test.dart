import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/repositories/breeds_repository_impl.dart';
import 'package:the_cats_app/data/sources/breed_reference_source.dart';
import 'package:the_cats_app/data/sources/breeds_remote_data_source.dart';

/// Reference source backed by a document in the test, so no asset is needed.
BreedReferenceSource referenceSource(String document) =>
    BreedReferenceSource(loadAsset: (key) async => document);

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
      referenceSource: referenceSource('{"breeds": {}}'),
    ).getBreeds();

    expect(breeds, hasLength(1));
    expect(breeds.single.name, 'Abyssinian');
    expect(breeds.single.weightMetric, '3 - 5');
    expect(breeds.single.imageUrl, 'https://example.com/cat.jpg');
  });

  test('fills the attributes the live response no longer carries', () async {
    final dio = dioReturning([
      {'id': 'beng', 'name': 'Bengal', 'origin': 'United States'},
    ]);
    final references = referenceSource(
      '{"breeds": {"beng": {"adaptability": 5, "intelligence": 5,'
      ' "traits": ["hypoallergenic"],'
      ' "wikipedia_url": "https://en.wikipedia.org/wiki/Bengal_(cat)"}}}',
    );

    final breeds = await BreedsRepositoryImpl(
      remoteDataSource: DioBreedsRemoteDataSource(dio: dio),
      referenceSource: references,
    ).getBreeds();

    expect(breeds.single.adaptability, 5);
    expect(breeds.single.intelligence, 5);
    expect(
      breeds.single.wikipediaUrl,
      'https://en.wikipedia.org/wiki/Bengal_(cat)',
    );
    expect(breeds.single.origin, 'United States');
  });

  test('keeps the API data when the bundled dataset cannot be read', () async {
    final dio = dioReturning([
      {'id': 'beng', 'name': 'Bengal', 'life_span': '12-16'},
    ]);

    final breeds = await BreedsRepositoryImpl(
      remoteDataSource: DioBreedsRemoteDataSource(dio: dio),
      referenceSource: BreedReferenceSource(
        loadAsset: (key) async => throw StateError('missing asset'),
      ),
    ).getBreeds();

    expect(breeds.single.name, 'Bengal');
    expect(breeds.single.lifeSpan, '12-16');
    expect(breeds.single.intelligence, isNull);
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
      referenceSource: referenceSource('{"breeds": {}}'),
    ).getBreedPhotos('beng', limit: 6);

    expect(capturedRequest?.path, '/images/search');
    expect(capturedRequest?.queryParameters['breed_ids'], 'beng');
    expect(capturedRequest?.queryParameters['limit'], 6);
    expect(photos.single.id, 'photo-1');
  });
}
