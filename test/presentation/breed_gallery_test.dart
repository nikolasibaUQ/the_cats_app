import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/entities/breed_photo.dart';
import 'package:the_cats_app/domain/policies/breed_gallery.dart';
import 'package:the_cats_app/l10n/generated/app_localizations.dart';
import 'package:the_cats_app/presentation/detail/widgets/breed_gallery.dart';

/// Photos shaped like the live data: the gallery mixes proportions.
const _photos = <GalleryPhoto>[
  (url: 'https://example.invalid/cat-1.jpg', width: 1600, height: 1000),
  (url: 'https://example.invalid/cat-2.jpg', width: 900, height: 1200),
];

void _retryPhotos() {}

Widget _frame(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SizedBox(width: 400, height: 400, child: child)),
);

void main() {
  testWidgets('opens the photo carousel in a full screen viewer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _frame(
        BreedGallery(
          photos: _photos,
          photoRequest: const AsyncData(<BreedPhoto>[]),
          onRetry: _retryPhotos,
        ),
      ),
    );

    expect(find.text('Photo 1 of 2'), findsOneWidget);
    await tester.tap(find.byTooltip('Next photo'));
    await tester.pumpAndSettle();
    expect(find.text('Photo 2 of 2'), findsOneWidget);
    await tester.tap(find.byTooltip('View photo full screen'));
    await tester.pump();

    expect(find.byTooltip('Close photo viewer'), findsOneWidget);
    expect(find.text('Photo 2 of 2'), findsWidgets);
    expect(find.byTooltip('Previous photo'), findsWidgets);
    expect(find.byType(InteractiveViewer), findsOneWidget);
  });

  testWidgets('reports the photo it shows so the area can adopt its shape', (
    tester,
  ) async {
    final reported = <GalleryPhoto>[];
    await tester.pumpWidget(
      _frame(
        BreedGallery(
          photos: _photos,
          photoRequest: const AsyncData(<BreedPhoto>[]),
          onRetry: _retryPhotos,
          onPhotoChanged: reported.add,
        ),
      ),
    );

    // A different proportion is what makes the area resizing worthwhile.
    await tester.tap(find.byTooltip('Next photo'));
    await tester.pumpAndSettle();

    expect(reported, <GalleryPhoto>[_photos[1]]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('explains a breed without photos instead of an empty box', (
    tester,
  ) async {
    await tester.pumpWidget(
      _frame(
        BreedGallery(
          photos: const [],
          photoRequest: const AsyncData(<BreedPhoto>[]),
          onRetry: _retryPhotos,
          label: 'American Ringtail',
        ),
      ),
    );

    // The monogram identifies the breed and the caption explains the gap, so a
    // breed without photos never looks like a screen that failed to load.
    expect(find.text('A'), findsOneWidget);
    expect(find.text('No photo available for this breed'), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
