import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/app/app_router.dart';
import 'package:the_cats_app/app/cats_app.dart';
import 'package:the_cats_app/features/breeds/domain/breed.dart';
import 'package:the_cats_app/features/breeds/domain/breeds_repository.dart';
import 'package:the_cats_app/features/breeds/presentation/breeds_providers.dart';
import 'package:the_cats_app/features/breeds/presentation/widgets/breed_image.dart';

class _FakeBreedsRepository implements BreedsRepository {
  @override
  Future<List<Breed>> getBreeds() async => const [
    Breed(id: 'abys', name: 'Abyssinian', origin: 'Egypt'),
    Breed(id: 'beng', name: 'Bengal', origin: 'United States'),
  ];
}

class _ManyBreedsRepository implements BreedsRepository {
  int requests = 0;

  @override
  Future<List<Breed>> getBreeds() async {
    requests++;
    return List<Breed>.generate(
      10,
      (index) => Breed(id: 'breed-$index', name: 'Breed ${index + 1}'),
    );
  }
}

void main() {
  testWidgets('search filters breeds and a card opens detail', (tester) async {
    appRouter.go('/');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breedsRepositoryProvider.overrideWithValue(_FakeBreedsRepository()),
        ],
        child: const CatsApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Bengal'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '  beng  ');
    await tester.pump(const Duration(milliseconds: 349));
    expect(find.text('Abyssinian'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Abyssinian'), findsNothing);
    expect(find.text('Bengal'), findsOneWidget);

    await tester.tap(find.text('Bengal'));
    await tester.pumpAndSettle();
    expect(find.text('From United States'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('Origen: United States'), findsOneWidget);
    expect(find.byTooltip('Volver a las razas'), findsOneWidget);
  });

  testWidgets('search waits for two letters and can match origin', (
    tester,
  ) async {
    appRouter.go('/breeds');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breedsRepositoryProvider.overrideWithValue(_FakeBreedsRepository()),
        ],
        child: const CatsApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'e');
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Type at least 2 letters to search.'), findsOneWidget);
    expect(find.text('Bengal'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'egy');
    await tester.pump(const Duration(milliseconds: 349));
    expect(find.text('Bengal'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Bengal'), findsNothing);

    await tester.enterText(find.byType(EditableText), '');
    await tester.pump();
    expect(find.text('Bengal'), findsOneWidget);
  });

  testWidgets('show more reveals the remaining breeds without refetching', (
    tester,
  ) async {
    final repository = _ManyBreedsRepository();
    appRouter.go('/breeds');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [breedsRepositoryProvider.overrideWithValue(repository)],
        child: const CatsApp(),
      ),
    );
    await tester.pumpAndSettle();

    SliverGrid grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    expect(grid.delegate.estimatedChildCount, 8);
    expect(find.text('Showing 8 of 10'), findsOneWidget);

    final showMore = find.byKey(const Key('show-more-breeds'));
    // The search field owns an internal horizontal Scrollable, so the vertical
    // one that scrolls the breed grid has to be selected explicitly.
    final listScrollable = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    await tester.scrollUntilVisible(showMore, 400, scrollable: listScrollable);
    await tester.tap(showMore);
    await tester.pumpAndSettle();

    grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    expect(grid.delegate.estimatedChildCount, 10);
    expect(repository.requests, 1);

    // The counter lives in the header sliver, which is outside the cache extent
    // once the button is on screen, so scroll back to it before asserting.
    await tester.scrollUntilVisible(
      find.text('Showing 10 of 10'),
      -400,
      scrollable: listScrollable,
    );
    expect(find.text('Showing 10 of 10'), findsOneWidget);
  });

  testWidgets('list grid adapts to phone, tablet, and desktop widths', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 568));
    appRouter.go('/breeds');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breedsRepositoryProvider.overrideWithValue(_FakeBreedsRepository()),
        ],
        child: const CatsApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final (width, columns) in [(320.0, 1), (600.0, 2), (1440.0, 4)]) {
      await tester.binding.setSurfaceSize(Size(width, 900));
      await tester.pumpAndSettle();
      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, columns);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('direct detail route stacks on mobile and splits on desktop', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(320, 568));
    appRouter.go('/breeds/beng');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breedsRepositoryProvider.overrideWithValue(_FakeBreedsRepository()),
        ],
        child: const CatsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('From United States'), findsOneWidget);
    final imageInsideRow = find.ancestor(
      of: find.byType(BreedImage),
      matching: find.byType(Row),
    );
    expect(imageInsideRow, findsNothing);

    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpAndSettle();
    expect(imageInsideRow, findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
