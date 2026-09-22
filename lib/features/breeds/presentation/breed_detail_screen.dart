import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/language_menu.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/responsive.dart';
import '../domain/breed.dart';
import 'breed_image.dart';
import 'breeds_providers.dart';

class BreedDetailScreen extends ConsumerWidget {
  const BreedDetailScreen({super.key, required this.breedId});

  final String breedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breeds = ref.watch(breedsProvider);
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: strings.backToBreeds,
          onPressed: () => context.go('/breeds'),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(strings.appTitle),
        actions: const [LanguageMenu()],
      ),
      body: breeds.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DetailState(
          title: strings.detailErrorTitle,
          action: FilledButton(
            onPressed: () => ref.invalidate(breedsProvider),
            child: Text(strings.retry),
          ),
        ),
        data: (items) {
          Breed? selected;
          for (final breed in items) {
            if (breed.id == breedId) {
              selected = breed;
              break;
            }
          }
          if (selected == null) {
            return _DetailState(title: strings.breedNotFound);
          }
          return _BreedContent(breed: selected);
        },
      ),
    );
  }
}

class _DetailState extends StatelessWidget {
  const _DetailState({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pets_outlined, size: responsive.icon(48)),
            SizedBox(height: responsive.spacing(12)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (action != null) ...[
              SizedBox(height: responsive.spacing(16)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _BreedContent extends StatelessWidget {
  const _BreedContent({required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 760) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(
                    responsive.pagePadding,
                    responsive.spacing(16),
                    responsive.pagePadding,
                    responsive.spacing(40),
                  ),
                  children: [
                    _photo(
                      responsive,
                      height: responsive.hp(38).clamp(200.0, 360.0),
                    ),
                    SizedBox(height: responsive.spacing(26)),
                    ..._information(context, responsive),
                  ],
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                  vertical: responsive.spacing(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _photo(responsive)),
                    SizedBox(width: responsive.spacing(32)),
                    Expanded(
                      flex: 6,
                      child: ListView(
                        padding: EdgeInsets.only(
                          bottom: responsive.spacing(24),
                        ),
                        children: _information(context, responsive),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _photo(Responsive responsive, {double? height}) => ClipRRect(
    borderRadius: BorderRadius.circular(responsive.radius(22)),
    child: height == null
        ? BreedImage(url: breed.imageUrl)
        : SizedBox(
            height: height,
            child: BreedImage(url: breed.imageUrl),
          ),
  );

  List<Widget> _information(BuildContext context, Responsive responsive) {
    final strings = AppLocalizations.of(context)!;
    final theme = Theme.of(context).textTheme;
    return [
      Text(
        breed.name,
        style: theme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      if (breed.origin != null) ...[
        SizedBox(height: responsive.spacing(4)),
        Text(strings.fromOrigin(breed.origin!), style: theme.titleMedium),
      ],
      if (breed.description != null) ...[
        SizedBox(height: responsive.spacing(24)),
        Text(breed.description!, style: theme.bodyLarge),
      ],
      if (breed.temperament != null ||
          breed.lifeSpan != null ||
          breed.weightMetric != null) ...[
        SizedBox(height: responsive.spacing(28)),
        Text(
          strings.atGlance,
          style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: responsive.spacing(12)),
        if (breed.temperament != null)
          _Fact(label: strings.temperament, value: breed.temperament!),
        if (breed.lifeSpan != null)
          _Fact(
            label: strings.lifeSpan,
            value: strings.lifeSpanValue(breed.lifeSpan!),
          ),
        if (breed.weightMetric != null)
          _Fact(
            label: strings.weight,
            value: strings.weightValue(breed.weightMetric!),
          ),
      ],
      if ([
        breed.affectionLevel,
        breed.energyLevel,
        breed.grooming,
        breed.intelligence,
      ].any((value) => value != null)) ...[
        SizedBox(height: responsive.spacing(28)),
        Text(
          strings.characteristics,
          style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: responsive.spacing(12)),
        if (breed.affectionLevel != null)
          _Trait(label: strings.affection, value: breed.affectionLevel!),
        if (breed.energyLevel != null)
          _Trait(label: strings.energy, value: breed.energyLevel!),
        if (breed.grooming != null)
          _Trait(label: strings.groomingNeeds, value: breed.grooming!),
        if (breed.intelligence != null)
          _Trait(label: strings.intelligence, value: breed.intelligence!),
      ],
    ];
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: Responsive.of(context).spacing(5)),
    child: Text(AppLocalizations.of(context)!.factValue(label, value)),
  );
}

class _Trait extends StatelessWidget {
  const _Trait({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(vertical: Responsive.of(context).spacing(8)),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          AppLocalizations.of(context)!.ratingValue(value),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
