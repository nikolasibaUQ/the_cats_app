import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/entities/breed.dart';
import 'package:the_cats_app/domain/entities/breed_reference.dart';
import 'package:the_cats_app/l10n/generated/app_localizations.dart';
import 'package:the_cats_app/presentation/detail/widgets/related_breeds_section.dart';

final List<Breed> _breeds = List<Breed>.generate(
  RelatedBreedsSection.visibleCount,
  (int index) => Breed(id: 'breed-$index', name: 'Breed $index'),
);

Widget _frame() => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(
      width: 500,
      child: RelatedBreedsSection(
        breeds: _breeds,
        references: const <String, BreedReference>{},
        onBreedSelected: (_) {},
        onShowAll: () {},
      ),
    ),
  ),
);

void main() {
  testWidgets('desktop suggestion buttons page through related breeds', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view
      ..physicalSize = const Size(1200, 800)
      ..devicePixelRatio = 1;
    await tester.pumpWidget(_frame());
    await tester.pumpAndSettle();

    expect(
      MediaQuery.sizeOf(
        tester.element(find.byType(RelatedBreedsSection)),
      ).width,
      1200,
    );

    final previous = find.byKey(const Key('related-breeds-previous'));
    final next = find.byKey(const Key('related-breeds-next'));

    expect(previous, findsOneWidget);
    expect(next, findsOneWidget);
    expect(tester.widget<IconButton>(previous).onPressed, isNull);
    expect(tester.widget<IconButton>(next).onPressed, isNotNull);

    await tester.tap(next);
    await tester.pumpAndSettle();

    expect(tester.widget<IconButton>(previous).onPressed, isNotNull);
  });
}
