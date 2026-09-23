import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/shared/widgets/app_remote_image.dart';

Widget _frame(Widget child) => MaterialApp(
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

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as NetworkImage;
    // The Cat API image host sends no CORS headers, and Flutter Web reads image
    // bytes with XHR, so the browser blocks the request and logs one error per
    // photo. Preferring the HTML element never issues that blocked request.
    expect(provider.webHtmlElementStrategy, WebHtmlElementStrategy.prefer);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the placeholder behind the photo, never an empty box', (
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
    // The first layer is the placeholder, so a slow or failed download still
    // shows the breed instead of a blank area.
    expect(stack.children.first, isNot(isA<Image>()));
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('names the placeholder with the breed initial', (tester) async {
    await tester.pumpWidget(
      _frame(
        const AppRemoteImage(
          url: 'https://example.invalid/cat.jpg',
          label: 'Bengal',
        ),
      ),
    );

    expect(find.text('B'), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
  });

  testWidgets('shows the placeholder when the URL is missing', (tester) async {
    await tester.pumpWidget(_frame(const AppRemoteImage(url: '')));

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
  });
}
