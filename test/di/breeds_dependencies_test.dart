import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/data/repositories/breeds_repository_impl.dart';
import 'package:the_cats_app/di/breeds_dependencies.dart';

void main() {
  test('provides the repository behind the domain contract', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final repository = container.read(breedsRepositoryProvider);

    expect(repository, isA<BreedsRepositoryImpl>());
  });
}
