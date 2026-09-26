import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/l10n/generated/app_localizations.dart';
import 'package:the_cats_app/shared/widgets/app_remote_image.dart';

Widget _frame(Widget child, {Locale locale = const Locale('en')}) =>
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SizedBox(width: 200, height: 200, child: child)),
    );

/// The photo frame always wraps its network provider in a [ResizeImage] so
/// the decode stays bounded to the displayed size.
Image _photoImage(WidgetTester tester) => tester
    .widgetList<Image>(find.byType(Image))
    .firstWhere((image) => image.image is ResizeImage);

void main() {
  testWidgets('prefers the HTML element so the CDN is not blocked by CORS', (
    tester,
  ) async {
    await tester.pumpWidget(
      _frame(
        const AppRemoteImage(
          url: 'https://cdn2.thecatapi.com/images/KWdLHmOqc.jpg',
        ),
      ),
    );

    final resize = _photoImage(tester).image as ResizeImage;
    final provider = resize.imageProvider as NetworkImage;
    // The Cat API image host sends no CORS headers, and Flutter Web reads image
    // bytes with XHR, so the browser blocks the request and logs one error per
    // photo. Preferring the HTML element never issues that blocked request.
    expect(provider.webHtmlElementStrategy, WebHtmlElementStrategy.prefer);
    expect(tester.takeException(), isNull);
  });

  testWidgets('decodes the photo at the displayed size', (tester) async {
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 2.0;
    await tester.pumpWidget(
      _frame(const AppRemoteImage(url: 'https://example.invalid/cat.jpg')),
    );

    // The 200 px frame at a 2.0 pixel ratio decodes a 400 px image instead of
    // the full ~3100 px the API serves, so the image cache keeps photos while
    // the grid scrolls and nothing is re-downloaded.
    final resize = _photoImage(tester).image as ResizeImage;
    expect(resize.width, 400);
    // A frame wider than the original (the full-screen viewer) never upscales.
    expect(resize.allowUpscaling, isFalse);
    expect(resize.imageProvider, isA<NetworkImage>());
    expect(tester.takeException(), isNull);
  });

  testWidgets('replaces loading artwork when the photo is ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      _frame(const AppRemoteImage(url: 'https://example.invalid/cat.jpg')),
    );

    final photoImage = _photoImage(tester);
    final context = tester.element(find.byType(AppRemoteImage));
    const loadedPhoto = SizedBox(key: Key('loaded-photo'));

    final pendingState = photoImage.loadingBuilder!(
      context,
      loadedPhoto,
      const ImageChunkEvent(cumulativeBytesLoaded: 1, expectedTotalBytes: 2),
    );
    await tester.pumpWidget(_frame(pendingState));
    expect(
      find.byKey(const ValueKey<String>('assets/images/loading_4_3.png')),
      findsOneWidget,
    );
    expect(find.text('Loading cats'), findsOneWidget);

    final loadedState = photoImage.loadingBuilder!(context, loadedPhoto, null);
    await tester.pumpWidget(_frame(loadedState));
    expect(find.byKey(const Key('loaded-photo')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('assets/images/loading_4_3.png')),
      findsNothing,
    );
  });

  testWidgets('uses the breed name as the remote photo semantic label', (
    tester,
  ) async {
    await tester.pumpWidget(
      _frame(
        const AppRemoteImage(
          url: 'https://example.invalid/cat.jpg',
          label: 'Bengal',
        ),
      ),
    );

    expect(_photoImage(tester).semanticLabel, 'Bengal');
  });

  testWidgets('shows unavailable artwork when the URL is missing', (
    tester,
  ) async {
    await tester.pumpWidget(_frame(const AppRemoteImage(url: '')));

    expect(
      find.byKey(const ValueKey<String>('assets/images/no_find_4_3.png')),
      findsOneWidget,
    );
    expect(find.text('No photo available for this breed'), findsOneWidget);
  });

  testWidgets('shows loading artwork while waiting for a missing URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      _frame(const AppRemoteImage(url: null, loading: true)),
    );

    expect(
      find.byKey(const ValueKey<String>('assets/images/loading_4_3.png')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('assets/images/no_find_4_3.png')),
      findsNothing,
    );
  });

  testWidgets('localizes the visible photo-state label', (tester) async {
    await tester.pumpWidget(
      _frame(const AppRemoteImage(url: null), locale: const Locale('es')),
    );

    expect(find.text('No hay foto disponible de esta raza'), findsOneWidget);
  });
}
