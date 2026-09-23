import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/shared/widgets/app_remote_image.dart';

void main() {
  testWidgets('keeps the HTML element fallback for the image CDN', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppRemoteImage(
            url: 'https://cdn2.thecatapi.com/images/KWdLHmOqc.jpg',
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as NetworkImage;
    // The Cat API image host sends no CORS headers, and Flutter Web reads image
    // bytes with XHR, so the browser blocks the request. Without this strategy
    // every Web image would render the placeholder instead of the photo.
    expect(provider.webHtmlElementStrategy, WebHtmlElementStrategy.fallback);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the placeholder when the URL is missing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppRemoteImage(url: '')),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
  });
}
