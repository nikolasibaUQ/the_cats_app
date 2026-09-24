import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';
import '../../breed_formatting.dart';
import 'breed_fact_card.dart';
import 'section_panel.dart';

class BreedInformation extends StatelessWidget {
  const BreedInformation({super.key, required this.breed});

  final Breed breed;

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
        Text(
          breed.name,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: responsive.spacing(20)),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        if (facts.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(24)),
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

/// Lays the overview cards out three per row, wrapping any remaining card.
class _FactGrid extends StatelessWidget {
  const _FactGrid({required this.cards});

  final List<Widget> cards;

  static const int columns = 3;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final gap = responsive.spacing(8);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
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

/// Outlined pill for single-word breed qualities such as temperament words.
class _QualityChip extends StatelessWidget {
  const _QualityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      backgroundColor: colors.surfaceContainer,
      side: BorderSide(color: colors.outlineVariant),
    );
  }
}
