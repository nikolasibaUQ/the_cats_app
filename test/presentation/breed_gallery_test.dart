import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/breed_photo.dart';
import 'package:the_cats_app/l10n/generated/app_localizations.dart';
import 'package:the_cats_app/presentation/detail/widgets/breed_gallery.dart';

void _retryPhotos() {}

void main() {
  testWidgets('opens the photo carousel in a full screen viewer', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 400,
            child: BreedGallery(
              imageUrls: const [
                'https://example.invalid/cat-1.jpg',
                'https://example.invalid/cat-2.jpg',
              ],
              photos: const AsyncData(<BreedPhoto>[]),
              onRetry: _retryPhotos,
            ),
          ),
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
}
