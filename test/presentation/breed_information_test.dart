import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/entities/breed.dart';
import 'package:the_cats_app/l10n/generated/app_localizations.dart';
import 'package:the_cats_app/presentation/detail/widgets/breed_fact_card.dart';
import 'package:the_cats_app/presentation/detail/widgets/breed_information.dart';

const _breed = Breed(
  id: 'acur',
  name: 'American Curl',
  origin: 'United States',
  breedGroup: 'Short/Long-hair',
  lifeSpan: '12-16',
  weightMetric: '3.2-5',
  heightMetric: '23-30',
);

Widget _frame({bool showName = true}) => MaterialApp(
  locale: Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SizedBox(
      width: 344,
      child: BreedInformation(breed: _breed, showName: showName),
    ),
  ),
);

void main() {
  testWidgets('wraps Spanish overview labels in two-column mobile cards', (
    tester,
  ) async {
    await tester.pumpWidget(_frame());

    final cards = find.byType(BreedFactCard);
    final origin = tester.getTopLeft(cards.at(0));
    final group = tester.getTopLeft(cards.at(1));
    final lifeSpan = tester.getTopLeft(cards.at(2));

    expect(cards, findsNWidgets(5));
    expect(group.dy, origin.dy);
    expect(lifeSpan.dy, greaterThan(origin.dy));
    expect(tester.widget<Text>(find.text('Grupo de raza')).maxLines, isNull);
    expect(
      tester.widget<Text>(find.text('Esperanza de vida')).maxLines,
      isNull,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('omits the repeated name and divider when the app bar has it', (
    tester,
  ) async {
    await tester.pumpWidget(_frame(showName: false));

    expect(find.text('American Curl'), findsNothing);
    expect(find.byType(Divider), findsNothing);
    expect(find.text('RESUMEN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
