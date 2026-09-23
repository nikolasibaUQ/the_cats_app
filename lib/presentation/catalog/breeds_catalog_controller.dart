import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'breeds_catalog_controller.g.dart';

/// Search and reveal state of the breed catalog.
///
/// The controller owns input behavior only: the debounce, the minimum query
/// length, and how many matches are revealed. Which breeds match a query is a
/// domain rule, and the ready-to-render result is derived in
/// `breedsCatalogViewProvider`.
typedef BreedsCatalogState = ({
  String query,
  int visibleCount,
  bool showMinimumHint,
});

@riverpod
class BreedsCatalogController extends _$BreedsCatalogController {
  static const int pageSize = 8;
  static const int minimumQueryLength = 2;
  static const Duration searchDelay = Duration(milliseconds: 350);

  Timer? _searchTimer;

  @override
  BreedsCatalogState build() {
    ref.onDispose(() => _searchTimer?.cancel());
    return (query: '', visibleCount: pageSize, showMinimumHint: false);
  }

  void search(String value) {
    _searchTimer?.cancel();
    final normalized = value.trim().toLowerCase();
    if (normalized.length < minimumQueryLength) {
      state = (
        query: '',
        visibleCount: pageSize,
        showMinimumHint: normalized.isNotEmpty,
      );
      return;
    }

    state = (
      query: state.query,
      visibleCount: state.visibleCount,
      showMinimumHint: false,
    );
    _searchTimer = Timer(searchDelay, () {
      state = (
        query: normalized,
        visibleCount: pageSize,
        showMinimumHint: false,
      );
    });
  }

  void showMore() {
    state = (
      query: state.query,
      visibleCount: state.visibleCount + pageSize,
      showMinimumHint: state.showMinimumHint,
    );
  }
}
