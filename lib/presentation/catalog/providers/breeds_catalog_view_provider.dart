import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/entities/breed.dart';
import '../../../domain/policies/breed_search.dart';
import '../../breeds_providers.dart';
import '../controllers/breeds_catalog_controller.dart';

part 'breeds_catalog_view_provider.g.dart';

/// Ready-to-render catalog results.
///
/// Search, the reveal count, and the loaded list are already resolved here, so
/// the screen renders values instead of computing them. [hasLoadedBreeds]
/// separates an empty API response from a query without matches.
typedef BreedsCatalogView = ({
  List<Breed> visibleBreeds,
  int matchedCount,
  bool hasLoadedBreeds,
});

/// Derives the visible catalog results from the loaded breeds and the state of
/// the catalog controller, keeping the derivation out of the widget tree.
@riverpod
AsyncValue<BreedsCatalogView> breedsCatalogView(Ref ref) {
  final catalog = ref.watch(breedsCatalogControllerProvider);
  return ref.watch(breedsProvider).whenData((breeds) {
    final matched = searchBreeds(breeds, catalog.query);
    return (
      visibleBreeds: matched.take(catalog.visibleCount).toList(),
      matchedCount: matched.length,
      hasLoadedBreeds: breeds.isNotEmpty,
    );
  });
}
