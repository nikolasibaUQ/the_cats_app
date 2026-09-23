import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/breeds_remote_data_source.dart';
import 'package:the_cats_app/data/breeds_repository_impl.dart';

void main() {
  test('maps the breeds response into domain data', () async {
    final dio = Dio();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.resolve(
          Response<List<dynamic>>(
            requestOptions: options,
            data: [
              {
                'id': 'abys',
                'name': 'Abyssinian',
                'image': {'url': 'https://example.com/cat.jpg'},
                'weight': {'metric': '3 - 5'},
              },
            ],
          ),
        ),
      ),
    );

    final breeds = await BreedsRepositoryImpl(
      remoteDataSource: DioBreedsRemoteDataSource(dio: dio),
    ).getBreeds();

    expect(breeds, hasLength(1));
    expect(breeds.single.name, 'Abyssinian');
    expect(breeds.single.weightMetric, '3 - 5');
    expect(breeds.single.imageUrl, 'https://example.com/cat.jpg');
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
