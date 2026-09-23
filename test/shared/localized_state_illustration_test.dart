import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/shared/widgets/localized_state_illustration.dart';

Widget testApp(Size size, StateIllustrationKind kind) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: SizedBox.fromSize(
        size: size,
        child: LocalizedStateIllustration(
          kind: kind,
          semanticLabel: 'Cat state',
          expand: true,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('selects the portrait loading illustration', (tester) async {
    await tester.pumpWidget(
      testApp(const Size(300, 400), StateIllustrationKind.loading),
    );

    expect(
      find.byKey(const ValueKey<String>('assets/images/loading_3_4.png')),
      findsOneWidget,
    );
  });

  testWidgets('selects the landscape loading illustration', (tester) async {
    await tester.pumpWidget(
      testApp(const Size(400, 300), StateIllustrationKind.loading),
    );

    expect(
      find.byKey(const ValueKey<String>('assets/images/loading_4_3.png')),
      findsOneWidget,
    );
  });

  testWidgets('selects both unavailable illustration formats', (tester) async {
    await tester.pumpWidget(
      testApp(const Size(300, 400), StateIllustrationKind.notFound),
    );
    expect(
      find.byKey(const ValueKey<String>('assets/images/no_find_3_4.png')),
      findsOneWidget,
    );

    await tester.pumpWidget(
      testApp(const Size(400, 300), StateIllustrationKind.notFound),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey<String>('assets/images/no_find_4_3.png')),
      findsOneWidget,
    );
  });
}
