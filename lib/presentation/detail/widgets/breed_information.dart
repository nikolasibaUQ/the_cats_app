import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../domain/entities/breed_flag.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/rating_dots.dart';
import '../../../shared/widgets/section_title.dart';
import '../../breed_formatting.dart';

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
    final ratings = <(String, int?)>[
      (strings.intelligence, breed.intelligence),
      (strings.adaptability, breed.adaptability),
      (strings.energy, breed.energyLevel),
      (strings.affection, breed.affectionLevel),
      (strings.childFriendly, breed.childFriendly),
      (strings.dogFriendly, breed.dogFriendly),
      (strings.strangerFriendly, breed.strangerFriendly),
      (strings.socialNeeds, breed.socialNeeds),
      (strings.vocalisation, breed.vocalisation),
      (strings.groomingNeeds, breed.grooming),
      (strings.sheddingLevel, breed.sheddingLevel),
      (strings.healthIssues, breed.healthIssues),
    ].where((rating) => rating.$2 != null).toList();
    final facts = <Widget>[
      if (breed.origin != null)
        _FactCard(
          icon: Icons.public_rounded,
          label: strings.origin,
          value: breed.origin!,
        ),
      if (breed.breedGroup != null)
        _FactCard(
          icon: Icons.category_outlined,
          label: strings.group,
          value: breed.breedGroup!,
        ),
      if (breed.lifeSpan != null)
        _FactCard(
          icon: Icons.event_outlined,
          label: strings.lifeSpan,
          value: strings.lifeSpanValue(breed.lifeSpan!),
        ),
      if (weightLabel != null)
        _FactCard(
          icon: Icons.monitor_weight_outlined,
          label: strings.weight,
          value: weightLabel,
        ),
      if (heightLabel != null)
        _FactCard(
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
        if (breed.altNames != null) ...[
          SizedBox(height: responsive.spacing(4)),
          Text(
            strings.alsoKnownAs(breed.altNames!),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
          _SurfacePanel(
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
          _SurfacePanel(
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
          _SurfacePanel(
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
        if (breed.flags.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(28)),
          SectionTitle(strings.traitsTitle),
          SizedBox(height: responsive.spacing(12)),
          Wrap(
            spacing: responsive.spacing(8),
            runSpacing: responsive.spacing(8),
            children: [
              for (final flag in BreedFlag.values)
                if (breed.flags.contains(flag))
                  _TraitChip(label: _flagLabel(strings, flag), tinted: true),
            ],
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
              for (final quality in temperament) _TraitChip(label: quality),
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

String _flagLabel(AppLocalizations strings, BreedFlag flag) => switch (flag) {
  BreedFlag.indoor => strings.flagIndoor,
  BreedFlag.lap => strings.flagLap,
  BreedFlag.hypoallergenic => strings.flagHypoallergenic,
  BreedFlag.natural => strings.flagNatural,
  BreedFlag.rare => strings.flagRare,
  BreedFlag.rex => strings.flagRex,
  BreedFlag.hairless => strings.flagHairless,
  BreedFlag.shortLegs => strings.flagShortLegs,
  BreedFlag.suppressedTail => strings.flagSuppressedTail,
  BreedFlag.experimental => strings.flagExperimental,
};

class _SurfacePanel extends StatelessWidget {
  const _SurfacePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}

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

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(14),
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: responsive.icon(16), color: colors.primary),
              SizedBox(width: responsive.spacing(6)),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.spacing(6)),
          Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined pill for single-word breed qualities.
///
/// Traits the breed has are tinted so this row does not read as a copy of the
/// temperament row below it.
class _TraitChip extends StatelessWidget {
  const _TraitChip({required this.label, this.tinted = false});

  final String label;
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      backgroundColor: tinted
          ? colors.primary.withValues(alpha: 0.10)
          : colors.surfaceContainer,
      labelStyle: tinted
          ? TextStyle(color: colors.primary, fontWeight: FontWeight.w600)
          : null,
      side: BorderSide(
        color: tinted
            ? colors.primary.withValues(alpha: 0.30)
            : colors.outlineVariant,
      ),
    );
  }
}

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
