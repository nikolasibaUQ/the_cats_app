import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/features/breeds/data/remote_breeds_repository.dart';

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

    final breeds = await RemoteBreedsRepository(dio: dio).getBreeds();

    expect(breeds, hasLength(1));
    expect(breeds.single.name, 'Abyssinian');
    expect(breeds.single.weightMetric, '3 - 5');
    expect(breeds.single.imageUrl, 'https://example.com/cat.jpg');
  });
}
