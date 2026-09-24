import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/app/app_router.dart';
import 'package:the_cats_app/app/cats_app.dart';
import 'package:the_cats_app/di/breeds_dependencies.dart';
import 'package:the_cats_app/domain/entities/breed.dart';
import 'package:the_cats_app/domain/entities/breed_photo.dart';
import 'package:the_cats_app/domain/repositories/breeds_repository.dart';
import 'package:the_cats_app/presentation/detail/widgets/breed_gallery.dart';
import 'package:the_cats_app/presentation/photo_framing.dart';
import 'package:the_cats_app/presentation/splash/controllers/splash_controller.dart';
import 'package:the_cats_app/shared/widgets/localized_state_illustration.dart';

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
        temperament: 'Alert, Agile, Energetic',
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

/// Breeds shaped like the free-plan live response: only the factual fields.
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

class _RetryingBreedsRepository implements BreedsRepository {
  int requests = 0;

  @override
  Future<List<Breed>> getBreeds() async {
    requests++;
    if (requests == 1) {
      throw Exception('Temporary API failure');
    }
    return [
      Breed(
        id: 'breed-$requests',
        name: requests == 2 ? 'Abyssinian' : 'Bengal',
      ),
    ];
  }

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async => const <BreedPhoto>[];
}

class _FailOnceBreedsRepository implements BreedsRepository {
  int requests = 0;

  @override
  Future<List<Breed>> getBreeds() async {
    requests++;
    if (requests == 1) throw Exception('Temporary API failure');
    return const [Breed(id: 'beng', name: 'Bengal')];
  }

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async => const <BreedPhoto>[];
}

/// Breed whose primary photo is landscape while the gallery also holds a
/// portrait one, like the live data does.
class _MixedPhotoShapeRepository extends _FakeBreedsRepository {
  @override
  Future<List<Breed>> getBreeds() async => const [
    Breed(
      id: 'abys',
      name: 'Abyssinian',
      imageUrl: 'https://example.invalid/abys.jpg',
      imageWidth: 1600,
      imageHeight: 1000,
    ),
  ];

  @override
  Future<List<BreedPhoto>> getBreedPhotos(
    String breedId, {
    int limit = 8,
  }) async => const [
    BreedPhoto(
      id: 'photo-1',
      url: 'https://example.invalid/abys-1.jpg',
      width: 900,
      height: 1200,
    ),
  ];
}

/// Proportion of the photo area drawn on screen.
double photoAreaAspect(WidgetTester tester) {
  final size = tester.getSize(find.byType(BreedGallery));
  return size.width / size.height;
}

/// Pumps the app with a stub repository and an isolated router per test.
Future<void> pumpApp(
  WidgetTester tester, {
  required BreedsRepository repository,
  String location = '/breeds',
}) async {
  final container = ProviderContainer(
    overrides: [breedsRepositoryProvider.overrideWithValue(repository)],
    retry: (retryCount, error) => null,
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
  testWidgets('the splash hands over to the catalog on its own', (
    tester,
  ) async {
    await pumpApp(tester, repository: _FakeBreedsRepository(), location: '/');

    // While the splash is on screen the catalog is not mounted yet.
    expect(find.byType(EditableText), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    expect(find.byType(EditableText), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // The splash replaces itself, so no extra browser-history stop is created.
    expect(find.byType(EditableText), findsOneWidget);
    expect(find.text('Abyssinian'), findsOneWidget);
  });

  testWidgets('the splash artwork fits narrow, landscape, and wide viewports', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    // Narrow phone: the artwork keeps a modest, width-proportional size.
    await tester.binding.setSurfaceSize(const Size(320, 568));
    await pumpApp(tester, repository: _FakeBreedsRepository(), location: '/');
    expect(tester.takeException(), isNull);
    expect(find.byType(Image), findsOneWidget);
    expect(tester.getSize(find.byType(Image)).width, lessThan(320 * 0.6));

    // Landscape phone: the artwork shrinks before the screen overflows.
    await tester.binding.setSurfaceSize(const Size(568, 320));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Image)).height, lessThanOrEqualTo(320));

    // Wide desktop: the artwork is capped instead of scaling to the screen.
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(Image)).width, 280);

    // Let the hand-over fire so no timer stays pending at test end.
    await tester.pump(SplashController.displayDuration);
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('catalog retries an error and refreshes loaded breeds', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    final repository = _RetryingBreedsRepository();
    await pumpApp(tester, repository: repository, location: '/breeds');
    await tester.pumpAndSettle();

    expect(find.text('Could not load breeds'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Abyssinian'), findsOneWidget);

    await tester.tap(find.byTooltip('Refresh breeds'));
    await tester.pumpAndSettle();

    expect(find.text('Bengal'), findsOneWidget);
    expect(repository.requests, 3);
  });

  testWidgets('search filters breeds and a card opens detail', (tester) async {
    await pumpApp(tester, repository: _FakeBreedsRepository(), location: '/');
    await tester.pump(SplashController.displayDuration);
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
    // Origin and life span live in the overview cards only, so each of them is
    // rendered exactly once in the whole screen.
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('12 - 15 years'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.language_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    expect(find.text('12 - 15 años'), findsOneWidget);
    expect(find.text('United States'), findsOneWidget);
    // Spanish reads kilograms, and the weight card is the only weight on screen.
    expect(find.text('4 - 7 kg'), findsOneWidget);
    expect(find.byTooltip('Volver a las razas'), findsOneWidget);
  });

  testWidgets('returning from detail restores the catalog without refetching', (
    tester,
  ) async {
    final repository = _FakeBreedsRepository();
    await pumpApp(tester, repository: repository, location: '/');
    await tester.pump(SplashController.displayDuration);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText), 'beng');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Abyssinian'), findsNothing);

    await tester.tap(find.text('Bengal'));
    await tester.pumpAndSettle();
    expect(find.text('12 - 15 years'), findsOneWidget);

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
    expect(find.text('12 - 15 years'), findsOneWidget);

    await tester.tap(find.byKey(const Key('detail-back')));
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsOneWidget);
    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Bengal'), findsOneWidget);
  });

  testWidgets('detail reports an unavailable breed ID', (tester) async {
    await pumpApp(
      tester,
      repository: _FakeBreedsRepository(),
      location: '/breeds/missing',
    );
    await tester.pumpAndSettle();

    expect(find.text('Breed not found'), findsOneWidget);
    expect(find.byKey(const Key('detail-back')), findsOneWidget);
  });

  testWidgets('detail retries a recoverable list failure', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    final repository = _FailOnceBreedsRepository();
    await pumpApp(tester, repository: repository, location: '/breeds/beng');
    await tester.pumpAndSettle();

    expect(find.text('Could not load this breed'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Bengal'), findsOneWidget);
    expect(repository.requests, 2);
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

    // English reads pounds and inches, and every fact is listed once: the
    // overview cards are the only place that repeats data from the header.
    expect(find.text('8 - 15 lb'), findsOneWidget);
    expect(find.text('United States'), findsOneWidget);
    expect(find.text('BENG'), findsOneWidget);

    for (final label in const [
      'Breed group',
      'Short-haired',
      'Height',
      '13-16 in',
      'HISTORY',
      'Developed by crossing domestic cats with the Asian leopard cat.',
      'TEMPERAMENT',
      'Alert',
      'EXPLORE OTHER BREEDS',
      'Read all article on Wikipedia',
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

    expect(find.text('12 - 15 years'), findsOneWidget);
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
      of: find.byType(BreedGallery),
      matching: find.byType(Row),
    );
    expect(imageInsideRow, findsNothing);

    // The information scrolls while the photo area stays fixed.
    await tester.scrollUntilVisible(
      find.text('HISTORY'),
      300,
      scrollable: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    expect(find.text('HISTORY'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(BreedGallery)).dy, galleryTopBefore);

    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpAndSettle();
    expect(imageInsideRow, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the photo area adopts the shape of the photo it shows', (
    tester,
  ) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await pumpApp(
      tester,
      repository: _MixedPhotoShapeRepository(),
      location: '/breeds/abys',
    );
    await tester.pumpAndSettle();

    // The primary photo is 1600x1000, which is 1.6: the area follows it up to
    // the band, past which it would resize far more than the photo needs.
    expect(photoAreaAspect(tester), closeTo(maxPhotoAspect, 0.01));

    await tester.tap(find.byTooltip('Next photo'));
    await tester.pumpAndSettle();

    // The portrait photo reshapes the area instead of being zoomed into the
    // frame the landscape one needed.
    expect(photoAreaAspect(tester), closeTo(minPhotoAspect, 0.01));

    // On a narrow screen the area keeps the full width, and the band stops a
    // portrait photo from pushing the information off the screen.
    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    final area = tester.getSize(find.byType(BreedGallery));
    expect(area.width, closeTo(390, 1));
    expect(area.height, lessThanOrEqualTo(360));
    expect(tester.takeException(), isNull);
  });

  testWidgets('detail shows the facts the live payload supplies', (
    tester,
  ) async {
    await pumpApp(
      tester,
      repository: _LiveShapeRepository(),
      location: '/breeds/abys',
    );
    await tester.pumpAndSettle();

    // Facts the API does supply, in the metric system the test locale needs.
    expect(find.text('Egypt'), findsOneWidget);
    expect(find.text('14-17 years'), findsOneWidget);
    expect(find.text('8-12 lb'), findsOneWidget);
    for (final label in const ['Natural', '13-16 in', 'HISTORY']) {
      await tester.scrollUntilVisible(
        find.text(label),
        300,
        scrollable: detailScrollable(),
      );
      expect(find.text(label), findsOneWidget);
    }

    // The article action closes the page, always through the Wikipedia search.
    await tester.scrollUntilVisible(
      find.text('Read all article on Wikipedia'),
      300,
      scrollable: detailScrollable(),
    );
    expect(find.text('Read all article on Wikipedia'), findsOneWidget);
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
    final illustration = tester.widget<LocalizedStateIllustration>(
      find.byType(LocalizedStateIllustration),
    );
    expect(illustration.kind, StateIllustrationKind.notFound);
  });
}
