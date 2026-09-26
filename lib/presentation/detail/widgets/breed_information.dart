import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../domain/entities/breed_reference.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';
import '../../breed_formatting.dart';
import 'breed_fact_card.dart';
import 'section_panel.dart';

class BreedInformation extends StatelessWidget {
  const BreedInformation({
    super.key,
    required this.breed,
    this.showName = true,
    this.reference,
  });

  final Breed breed;

  /// The compact detail app bar already shows this name, so its content avoids
  /// repeating the same heading below the photo.
  final bool showName;

  /// Traits of the bundled dataset for this breed. When absent, the two trait
  /// sections stay hidden without affecting the rest of the information.
  final BreedReference? reference;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final weightLabel = _withUnit(
      breedWeight(breed, locale),
      metric: strings.weightMetricValue,
      imperial: strings.weightImperialValue,
    );
    final heightLabel = _withUnit(
      breedHeight(breed, locale),
      metric: strings.heightMetricValue,
      imperial: strings.heightImperialValue,
    );
    final temperament = _split(breed.temperament);
    final ratings = <(String, int?)>[
      (strings.intelligence, reference?.intelligence),
      (strings.energy, reference?.energyLevel),
      (strings.affection, reference?.affectionLevel),
      (strings.groomingNeeds, reference?.grooming),
      (strings.socialNeeds, reference?.socialNeeds),
    ].where((rating) => rating.$2 != null).toList();
    final traits = <(String, bool?)>[
      (strings.hypoallergenic, reference?.hypoallergenic),
      (strings.rare, reference?.rare),
      (strings.lap, reference?.lap),
    ].where((trait) => trait.$2 != null).toList();
    final facts = <Widget>[
      if (breed.origin != null)
        BreedFactCard(
          icon: Icons.public_rounded,
          label: strings.origin,
          value: breed.origin!,
        ),
      if (breed.breedGroup != null)
        BreedFactCard(
          icon: Icons.category_outlined,
          label: strings.group,
          value: breed.breedGroup!,
        ),
      if (breed.lifeSpan != null)
        BreedFactCard(
          icon: Icons.event_outlined,
          label: strings.lifeSpan,
          value: strings.lifeSpanValue(breed.lifeSpan!),
        ),
      if (weightLabel != null)
        BreedFactCard(
          icon: Icons.monitor_weight_outlined,
          label: strings.weight,
          value: weightLabel,
        ),
      if (heightLabel != null)
        BreedFactCard(
          icon: Icons.height_rounded,
          label: strings.height,
          value: heightLabel,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showName) ...[
          Text(
            breed.name,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive.spacing(20)),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
        ],
        if (facts.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(showName ? 24 : 0)),
          SectionTitle(strings.overview),
          SizedBox(height: responsive.spacing(12)),
          _FactGrid(cards: facts),
        ],
        if (breed.description != null) ...[
          SizedBox(height: responsive.spacing(28)),
          SectionTitle(strings.descriptionTitle),
          SizedBox(height: responsive.spacing(12)),
          SectionPanel(
            child: Text(
              breed.description!,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
        if (breed.history != null) ...[
          SizedBox(height: responsive.spacing(28)),
          SectionTitle(strings.historyTitle),
          SizedBox(height: responsive.spacing(12)),
          SectionPanel(
            child: Text(
              breed.history!,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
        if (ratings.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(28)),
          SectionTitle(strings.characteristics),
          SizedBox(height: responsive.spacing(12)),
          SectionPanel(
            child: Column(
              children: [
                for (final (index, rating) in ratings.indexed) ...[
                  if (index > 0) const Divider(height: 24),
                  _TraitRating(label: rating.$1, value: rating.$2!),
                ],
              ],
            ),
          ),
        ],
        if (traits.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(28)),
          SectionTitle(strings.traitsTitle),
          SizedBox(height: responsive.spacing(12)),
          SectionPanel(
            child: Column(
              children: [
                for (final (index, trait) in traits.indexed) ...[
                  if (index > 0) const Divider(height: 24),
                  _TraitFlag(label: trait.$1, value: trait.$2!),
                ],
              ],
            ),
          ),
        ],
        if (temperament.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(28)),
          SectionTitle(strings.temperament),
          SizedBox(height: responsive.spacing(12)),
          Wrap(
            spacing: responsive.spacing(8),
            runSpacing: responsive.spacing(8),
            children: [
              for (final quality in temperament) _QualityChip(label: quality),
            ],
          ),
        ],
      ],
    );
  }
}

/// Applies the unit that matches the range the API supplied.
///
/// The API states ranges as bare numbers, so the unit comes from the locale
/// rule that selected the range.
String? _withUnit(
  ({String range, bool imperial})? measurement, {
  required String Function(String range) metric,
  required String Function(String range) imperial,
}) {
  if (measurement == null) return null;
  return measurement.imperial
      ? imperial(measurement.range)
      : metric(measurement.range);
}

List<String> _split(String? value) => value == null
    ? const <String>[]
    : [
        for (final part in value.split(','))
          if (part.trim().isNotEmpty) part.trim(),
      ];

/// Lays overview cards out with enough width for their localized labels.
class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.cards});

  final List<Widget> cards;

  static const int columns = 3;
  static const double _minimumCardWidth = 180;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final gap = responsive.spacing(8);
    return LayoutBuilder(
      builder: (context, constraints) {
        final canShowThreeColumns =
            constraints.maxWidth >= _minimumCardWidth * columns + gap * 2;
        final columnCount = canShowThreeColumns ? columns : 2;
        final width =
            (constraints.maxWidth - gap * (columnCount - 1)) / columnCount;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final card in cards) SizedBox(width: width, child: card),
          ],
        );
      },
    );
  }
}

/// One 1-to-5 trait row: the label reads the dots that measure it.
class _TraitRating extends StatelessWidget {
  const _TraitRating({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Text(label)),
      RatingDots(value: value, semanticLabel: label),
    ],
  );
}

/// One binary trait row: true reads as a filled check with "yes", false as a
/// muted mark with "no", so both states stay explicit.
class _TraitFlag extends StatelessWidget {
  const _TraitFlag({required this.label, required this.value});

  final String label;
  final bool value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final answer = value ? strings.yesValue : strings.noValue;
    return Semantics(
      label: '$label: $answer',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Icon(
              value ? Icons.check_circle_rounded : Icons.cancel_outlined,
              size: responsive.icon(20),
              color: value ? colors.primary : colors.outline,
            ),
            SizedBox(width: responsive.spacing(8)),
            Text(
              answer,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: value ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fuchsia-tinted pill for single-word breed qualities such as temperament
/// words, adding a playful accent without competing with the photos.
class _QualityChip extends StatelessWidget {
  const _QualityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Chip(
      label: Text(label),
      backgroundColor: colors.secondaryContainer,
      side: BorderSide(color: colors.secondary),
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color: colors.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
