import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/l10n/generated/app_localizations.dart';
import 'package:the_cats_app/shared/widgets/app_remote_image.dart';

Widget _frame(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SizedBox(width: 200, height: 200, child: child)),
);

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

    final image = tester
        .widgetList<Image>(find.byType(Image))
        .firstWhere((image) => image.image is NetworkImage);
    final provider = image.image as NetworkImage;
    // The Cat API image host sends no CORS headers, and Flutter Web reads image
    // bytes with XHR, so the browser blocks the request and logs one error per
    // photo. Preferring the HTML element never issues that blocked request.
    expect(provider.webHtmlElementStrategy, WebHtmlElementStrategy.prefer);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps localized loading artwork behind the photo', (
    tester,
  ) async {
    await tester.pumpWidget(
      _frame(const AppRemoteImage(url: 'https://example.invalid/cat.jpg')),
    );

    final stack = tester.widget<Stack>(
      find
          .descendant(
            of: find.byType(AppRemoteImage),
            matching: find.byType(Stack),
          )
          .first,
    );
    // The first layer remains visible until the remote image is ready.
    expect(stack.children.first, isNot(isA<Image>()));
    expect(
      find.byKey(const ValueKey<String>('assets/images/loading_4_3.png')),
      findsOneWidget,
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

    final networkImage = tester
        .widgetList<Image>(find.byType(Image))
        .firstWhere((image) => image.image is NetworkImage);
    expect(networkImage.semanticLabel, 'Bengal');
  });

  testWidgets('shows unavailable artwork when the URL is missing', (
    tester,
  ) async {
    await tester.pumpWidget(_frame(const AppRemoteImage(url: '')));

    expect(
      find.byKey(const ValueKey<String>('assets/images/no_find_4_3.png')),
      findsOneWidget,
    );
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
}
