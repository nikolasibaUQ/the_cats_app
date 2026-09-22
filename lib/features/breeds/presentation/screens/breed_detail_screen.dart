import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/language_menu.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/breed.dart';
import '../breeds_providers.dart';
import '../widgets/breed_detail_content.dart';
import '../widgets/breed_state_message.dart';

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
        error: (error, stackTrace) => BreedStateMessage(
          icon: Icons.wifi_off_rounded,
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
            return BreedStateMessage(
              icon: Icons.pets_outlined,
              title: strings.breedNotFound,
            );
          }
          return BreedDetailContent(breed: selected);
        },
      ),
    );
  }
}
