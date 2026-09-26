import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_cats_app/domain/entities/breed.dart';
import 'package:the_cats_app/domain/entities/breed_reference.dart';
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

const _reference = BreedReference(
  energyLevel: 5,
  affectionLevel: 4,
  intelligence: 5,
  grooming: 1,
  socialNeeds: 3,
  hypoallergenic: true,
  rare: false,
  lap: true,
);

Widget _frame({bool showName = true, BreedReference? reference}) => MaterialApp(
  locale: Locale('es'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: SingleChildScrollView(
      child: SizedBox(
        width: 344,
        child: BreedInformation(
          breed: _breed,
          showName: showName,
          reference: reference,
        ),
      ),
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

  testWidgets('renders the ratings and traits of the reference dataset', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(_frame(reference: _reference));

    expect(find.text('CARACTERÍSTICAS'), findsOneWidget);
    for (final label in const [
      'Inteligencia',
      'Energía',
      'Afecto',
      'Necesidades de aseo',
      'Necesidades sociales',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    // A rating row reads its dots through semantics: affection is 4 of 5.
    expect(find.bySemanticsLabel('Afecto: 4 de 5'), findsOneWidget);

    expect(find.text('RASGOS'), findsOneWidget);
    for (final label in const ['Hipoalergénico', 'Raza rara', 'Gato faldero']) {
      expect(find.text(label), findsOneWidget);
    }
    // Both binary states stay explicit: two yes and one no.
    expect(find.text('Sí'), findsNWidgets(2));
    expect(find.text('No'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('hides the trait sections when there is no reference', (
    tester,
  ) async {
    await tester.pumpWidget(_frame());

    expect(find.text('CARACTERÍSTICAS'), findsNothing);
    expect(find.text('RASGOS'), findsNothing);
    expect(find.text('Inteligencia'), findsNothing);
    expect(find.text('Hipoalergénico'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
