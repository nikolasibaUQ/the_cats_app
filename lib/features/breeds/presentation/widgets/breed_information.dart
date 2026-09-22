import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/responsive.dart';
import '../../domain/breed.dart';

class BreedInformation extends StatelessWidget {
  const BreedInformation({super.key, required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final temperament = breed.temperament
        ?.split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
    final traits = <(String, int?)>[
      (strings.intelligence, breed.intelligence),
      (strings.affection, breed.affectionLevel),
      (strings.energy, breed.energyLevel),
      (strings.groomingNeeds, breed.grooming),
    ].where((trait) => trait.$2 != null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          breed.name,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (breed.origin != null) ...[
          SizedBox(height: responsive.spacing(4)),
          Text(
            strings.fromOrigin(breed.origin!),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        if (breed.lifeSpan != null || breed.weightMetric != null) ...[
          SizedBox(height: responsive.spacing(24)),
          _SectionTitle(strings.atGlance),
          SizedBox(height: responsive.spacing(12)),
          Wrap(
            spacing: responsive.spacing(12),
            runSpacing: responsive.spacing(12),
            children: [
              if (breed.lifeSpan != null)
                _FactCard(
                  label: strings.lifeSpan,
                  value: strings.lifeSpanValue(breed.lifeSpan!),
                ),
              if (breed.weightMetric != null)
                _FactCard(
                  label: strings.weight,
                  value: strings.weightValue(breed.weightMetric!),
                ),
            ],
          ),
        ],
        if (breed.description != null) ...[
          SizedBox(height: responsive.spacing(28)),
          _SectionTitle(strings.descriptionTitle),
          SizedBox(height: responsive.spacing(12)),
          _SurfacePanel(
            child: Text(
              breed.description!,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
          ),
        ],
        if (traits.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(28)),
          _SectionTitle(strings.characteristics),
          SizedBox(height: responsive.spacing(12)),
          _SurfacePanel(
            child: Column(
              children: [
                for (final (index, trait) in traits.indexed) ...[
                  if (index > 0) const Divider(height: 24),
                  _TraitRating(label: trait.$1, value: trait.$2!),
                ],
              ],
            ),
          ),
        ],
        if (temperament != null && temperament.isNotEmpty) ...[
          SizedBox(height: responsive.spacing(28)),
          _SectionTitle(strings.temperament),
          SizedBox(height: responsive.spacing(12)),
          Wrap(
            spacing: responsive.spacing(8),
            runSpacing: responsive.spacing(8),
            children: [
              for (final quality in temperament)
                Chip(
                  label: Text(quality),
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  side: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title.toUpperCase(),
    style: Theme.of(context).textTheme.titleSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  );
}

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

class _FactCard extends StatelessWidget {
  const _FactCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 130),
      padding: EdgeInsets.all(responsive.spacing(16)),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          SizedBox(height: responsive.spacing(6)),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TraitRating extends StatelessWidget {
  const _TraitRating({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final responsive = Responsive.of(context);
    final rating = AppLocalizations.of(context)!.ratingValue(value);
    return Semantics(
      label: '$label: $rating',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(child: Text(label)),
            for (var index = 0; index < 5; index++) ...[
              if (index > 0) SizedBox(width: responsive.spacing(4)),
              Icon(
                Icons.circle,
                size: responsive.icon(10),
                color: index < value ? colors.primary : colors.outlineVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
