import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/app/app_router.dart';
import 'package:the_cats_app/app/cats_app.dart';
import 'package:the_cats_app/features/breeds/domain/breed.dart';
import 'package:the_cats_app/features/breeds/domain/breeds_repository.dart';
import 'package:the_cats_app/features/breeds/presentation/breed_image.dart';
import 'package:the_cats_app/features/breeds/presentation/breeds_providers.dart';

class _FakeBreedsRepository implements BreedsRepository {
  @override
  Future<List<Breed>> getBreeds() async => const [
    Breed(id: 'abys', name: 'Abyssinian', origin: 'Egypt'),
    Breed(id: 'beng', name: 'Bengal', origin: 'United States'),
  ];
}

void main() {
  testWidgets('search filters breeds and a card opens detail', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          breedsRepositoryProvider.overrideWithValue(_FakeBreedsRepository()),
        ],
        child: const CatsApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Bengal'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), '  beng  ');
    await tester.pump();
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
