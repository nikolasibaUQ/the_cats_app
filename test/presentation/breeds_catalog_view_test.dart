import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/di/breeds_dependencies.dart';
import 'package:the_cats_app/domain/breed.dart';
import 'package:the_cats_app/domain/breed_photo.dart';
import 'package:the_cats_app/domain/breeds_repository.dart';
import 'package:the_cats_app/presentation/breeds_providers.dart';
import 'package:the_cats_app/presentation/catalog/breeds_catalog_controller.dart';
import 'package:the_cats_app/presentation/catalog/breeds_catalog_view.dart';

const int _breedCount = 12;

class _CatalogRepository implements BreedsRepository {
  @override
  Future<List<Breed>> getBreeds() async => List<Breed>.generate(
    _breedCount,
    (index) => Breed(
      id: 'breed-$index',
      name: 'Breed ${index + 1}',
      origin: index == 0 ? 'Egypt' : null,
    ),
  );

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async => const <BreedPhoto>[];
}

void main() {
  late ProviderContainer container;
  late BreedsCatalogController controller;

  setUp(() async {
    container = ProviderContainer(
      overrides: [
        breedsRepositoryProvider.overrideWithValue(_CatalogRepository()),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      breedsCatalogViewProvider,
      (previous, next) {},
    );
    addTearDown(subscription.close);
    controller = container.read(breedsCatalogControllerProvider.notifier);
    await container.read(breedsProvider.future);
  });

  BreedsCatalogView view() =>
      container.read(breedsCatalogViewProvider).requireValue;

  test('reveals eight matches at a time and reports the matched total', () {
    expect(view().visibleBreeds, hasLength(BreedsCatalogController.pageSize));
    expect(view().matchedCount, _breedCount);
    expect(view().hasLoadedBreeds, isTrue);

    controller.showMore();

    expect(view().visibleBreeds, hasLength(_breedCount));
  });

  test('keeps a one-character query unfiltered and hints the minimum', () {
    controller.search('b');

    final state = container.read(breedsCatalogControllerProvider);
    expect(state.query, isEmpty);
    expect(state.showMinimumHint, isTrue);
    expect(view().matchedCount, _breedCount);
  });

  test(
    'applies a two-letter query after the debounce and matches origin',
    () async {
      controller.search('egy');
      expect(view().matchedCount, _breedCount);

      await Future<void>.delayed(BreedsCatalogController.searchDelay);

      expect(view().matchedCount, 1);
      expect(view().visibleBreeds.single.id, 'breed-0');
    },
  );

  test('clearing the query restores the full list immediately', () async {
    controller.search('egy');
    await Future<void>.delayed(BreedsCatalogController.searchDelay);
    expect(view().matchedCount, 1);

    controller.search('');

    expect(view().matchedCount, _breedCount);
    expect(
      container.read(breedsCatalogControllerProvider).showMinimumHint,
      isFalse,
    );
  });
}
