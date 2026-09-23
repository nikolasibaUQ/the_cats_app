import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/app/app_router.dart';
import 'package:the_cats_app/app/cats_app.dart';
import 'package:the_cats_app/di/breeds_dependencies.dart';
import 'package:the_cats_app/domain/breed.dart';
import 'package:the_cats_app/domain/breed_flag.dart';
import 'package:the_cats_app/domain/breed_photo.dart';
import 'package:the_cats_app/domain/breeds_repository.dart';
import 'package:the_cats_app/presentation/detail/widgets/breed_gallery.dart';
import 'package:the_cats_app/shared/widgets/app_remote_image.dart';

class _FakeBreedsRepository implements BreedsRepository {
  int requests = 0;

  @override
  Future<List<Breed>> getBreeds() async {
    requests++;
    return const [
      Breed(id: 'abys', name: 'Abyssinian', origin: 'Egypt'),
      Breed(
        id: 'beng',
        name: 'Bengal',
        altNames: 'Bengal Cat',
        origin: 'United States',
        description:
            'An active and curious cat with a distinctive spotted coat and a '
            'playful temperament.',
        lifeSpan: '12 - 15',
        weightMetric: '4 - 7',
        weightImperial: '8 - 15',
        heightMetric: '33-41',
        heightImperial: '13-16',
        breedGroup: 'Short-haired',
        history:
            'Developed by crossing domestic cats with the Asian leopard cat.',
        wikipediaUrl: 'https://en.wikipedia.org/wiki/Bengal_cat',
        temperament: 'Alert, Agile, Energetic',
        adaptability: 4,
        affectionLevel: 4,
        childFriendly: 5,
        energyLevel: 5,
        intelligence: 5,
        sheddingLevel: 3,
        flags: {BreedFlag.indoor, BreedFlag.hypoallergenic},
      ),
    ];
  }

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async => const [];
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

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async => const [];
}

/// Breeds shaped like the current live response: facts but no ratings, traits,
/// or article link.
class _LiveShapeRepository implements BreedsRepository {
  @override
  Future<List<Breed>> getBreeds() async => const [
    Breed(
      id: 'abys',
      name: 'Abyssinian',
      description: 'A short-haired cat with a ticked coat.',
      origin: 'Egypt',
      temperament: 'Active, Energetic, Independent',
      lifeSpan: '14-17',
      weightMetric: '3.6-5.4',
      weightImperial: '8-12',
      heightMetric: '33-41',
      heightImperial: '13-16',
      breedGroup: 'Natural',
      history: 'The breed descends from cats of the Indian Ocean coast.',
    ),
  ];

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async => const [];
}

class _GalleryFailureRepository extends _FakeBreedsRepository {
  @override
  Future<List<BreedPhoto>> getBreedPhotos(String breedId, {int limit = 8}) =>
      Future<List<BreedPhoto>>.error(Exception('Gallery unavailable'));
}

/// Pumps the app with a stub repository and an isolated router per test.
Future<void> pumpApp(
  WidgetTester tester, {
  required BreedsRepository repository,
  String location = '/breeds',
}) async {
  final container = ProviderContainer(
    overrides: [breedsRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  container.read(appRouterProvider).go(location);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const CatsApp()),
  );
}

/// Vertical scrollable of the detail information area.
Finder detailScrollable() => find.byWidgetPredicate(
  (widget) =>
      widget is Scrollable && widget.axisDirection == AxisDirection.down,
);

void main() {
  testWidgets('search filters breeds and a card opens detail', (tester) async {
    await pumpApp(tester, repository: _FakeBreedsRepository(), location: '/');
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Bengal'), findsOneWidget);
    // The catalog card reports intelligence, as the approved mock shows.
    expect(find.byIcon(Icons.circle), findsNWidgets(5));

    await tester.enterText(find.byType(EditableText), '  beng  ');
    await tester.pump(const Duration(milliseconds: 349));
    expect(find.text('Abyssinian'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Abyssinian'), findsNothing);
    expect(find.text('Bengal'), findsOneWidget);

    await tester.tap(find.text('Bengal'));
    await tester.pumpAndSettle();
    expect(
      find.text('United States • Lifespan: 12 - 15 years'),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(
      find.text('United States • Esperanza de vida: 12 - 15 años'),
      findsOneWidget,
    );
    // Spanish reads kilograms, as the approved mock shows: headline and card.
    expect(find.text('4 - 7 kg'), findsNWidgets(2));
    expect(find.byTooltip('Volver a las razas'), findsOneWidget);
  });

  testWidgets('returning from detail restores the catalog without refetching', (
    tester,
  ) async {
    final repository = _FakeBreedsRepository();
    await pumpApp(tester, repository: repository, location: '/');
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'beng');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Abyssinian'), findsNothing);

    await tester.tap(find.text('Bengal'));
    await tester.pumpAndSettle();
    expect(
      find.text('United States • Lifespan: 12 - 15 years'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('detail-back')));
    await tester.pumpAndSettle();

    expect(
      tester.widget<EditableText>(find.byType(EditableText)).controller.text,
      'beng',
    );
    expect(find.text('Abyssinian'), findsNothing);
    expect(find.text('Bengal'), findsOneWidget);
    expect(repository.requests, 1);
  });

  testWidgets('a direct detail visit returns to the catalog', (tester) async {
    await pumpApp(
      tester,
      repository: _FakeBreedsRepository(),
      location: '/breeds/beng',
    );
    await tester.pumpAndSettle();
    expect(
      find.text('United States • Lifespan: 12 - 15 years'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('detail-back')));
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsOneWidget);
    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Bengal'), findsOneWidget);
  });

  testWidgets('detail shows the breed data the API provides', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(480, 900));
    await pumpApp(
      tester,
      repository: _FakeBreedsRepository(),
      location: '/breeds/beng',
    );
    await tester.pumpAndSettle();

    // English reads pounds and inches: the headline chip and the cards.
    expect(find.text('8 - 15 lb'), findsNWidgets(2));
    expect(find.text('Also known as Bengal Cat'), findsOneWidget);
    expect(find.text('BENG'), findsOneWidget);

    for (final label in const [
      'Breed group',
      'Short-haired',
      'Height',
      '13-16 in',
      'HISTORY',
      'Developed by crossing domestic cats with the Asian leopard cat.',
      'Intelligence',
      'Adaptability',
      'Child friendly',
      'Shedding',
      'TRAITS',
      'Indoor',
      'Hypoallergenic',
      'TEMPERAMENT',
      'Alert',
      'EXPLORE OTHER BREEDS',
      'Read all article on Wikipedia',
      'Back to all breeds',
    ]) {
      await tester.scrollUntilVisible(
        find.text(label),
        300,
        scrollable: detailScrollable(),
      );
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('a related breed opens its own detail', (tester) async {
    await pumpApp(
      tester,
      repository: _ManyBreedsRepository(),
      location: '/breeds/breed-0',
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('EXPLORE OTHER BREEDS'),
      300,
      scrollable: detailScrollable(),
    );
    expect(find.text('3 more'), findsOneWidget);

    await tester.tap(find.text('Breed 2'));
    await tester.pumpAndSettle();

    // The photo badge identifies the breed the route resolved.
    expect(find.text('Breed 2'), findsOneWidget);
    expect(find.text('BREED-1'), findsOneWidget);
    expect(find.text('BREED-0'), findsNothing);
  });

  testWidgets('the remaining breeds action opens the catalog', (tester) async {
    await pumpApp(
      tester,
      repository: _ManyBreedsRepository(),
      location: '/breeds/breed-0',
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('EXPLORE OTHER BREEDS'),
      300,
      scrollable: detailScrollable(),
    );
    await tester.tap(find.text('3 more'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Showing 8 of 10'), findsOneWidget);
  });

  testWidgets('search waits for two letters and can match origin', (
    tester,
  ) async {
    await pumpApp(tester, repository: _FakeBreedsRepository());
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
    await pumpApp(tester, repository: repository);
    await tester.pumpAndSettle();

    SliverGrid grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
    expect(grid.delegate.estimatedChildCount, 8);
    expect(find.text('Showing 8 of 10'), findsOneWidget);

    final showMore = find.byKey(const Key('show-more-breeds'));
    final searchTopBefore = tester.getTopLeft(find.byType(TextField)).dy;
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
    expect(tester.getTopLeft(find.byType(TextField)).dy, searchTopBefore);

    // The counter belongs to the independently scrolling results area.
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
    await pumpApp(tester, repository: _FakeBreedsRepository());
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
    await pumpApp(
      tester,
      repository: _FakeBreedsRepository(),
      location: '/breeds/beng',
    );
    await tester.pumpAndSettle();

    expect(
      find.text('United States • Lifespan: 12 - 15 years'),
      findsOneWidget,
    );
    expect(
      find.ancestor(
        of: find.byType(BreedGallery),
        matching: find.byKey(const Key('breed-information-scroll')),
      ),
      findsNothing,
    );
    final galleryTopBefore = tester.getTopLeft(find.byType(BreedGallery)).dy;
    await tester.drag(
      find.byKey(const Key('breed-information-scroll')),
      const Offset(0, -180),
    );
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byType(BreedGallery)).dy, galleryTopBefore);
    final imageInsideRow = find.ancestor(
      of: find.byType(AppRemoteImage),
      matching: find.byType(Row),
    );
    expect(imageInsideRow, findsNothing);

    // The approved mock lists adaptability among the characteristics.
    await tester.scrollUntilVisible(
      find.text('Adaptability'),
      300,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    expect(find.text('Adaptability'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(BreedGallery)).dy, galleryTopBefore);

    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpAndSettle();
    expect(imageInsideRow, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail omits the sections the live payload does not supply', (
    tester,
  ) async {
    await pumpApp(
      tester,
      repository: _LiveShapeRepository(),
      location: '/breeds/abys',
    );
    await tester.pumpAndSettle();

    // Facts the API does supply, in the metric system the test locale needs.
    expect(find.text('Egypt • Lifespan: 14-17 years'), findsOneWidget);
    expect(find.text('8-12 lb'), findsNWidgets(2));
    for (final label in const ['Natural', '13-16 in', 'HISTORY']) {
      await tester.scrollUntilVisible(
        find.text(label),
        300,
        scrollable: detailScrollable(),
      );
      expect(find.text(label), findsOneWidget);
    }

    // Sections without values stay out of the page instead of rendering empty.
    await tester.scrollUntilVisible(
      find.text('Read all article on Wikipedia'),
      300,
      scrollable: detailScrollable(),
    );
    expect(find.text('Read all article on Wikipedia'), findsOneWidget);
    expect(find.text('CHARACTERISTICS'), findsNothing);
    expect(find.text('TRAITS'), findsNothing);
  });

  testWidgets('gallery failure keeps breed information and offers retry', (
    tester,
  ) async {
    await pumpApp(
      tester,
      repository: _GalleryFailureRepository(),
      location: '/breeds/beng',
    );
    await tester.pumpAndSettle();

    expect(find.text('Bengal'), findsOneWidget);
    expect(find.text('Retry photos'), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
  });
}
