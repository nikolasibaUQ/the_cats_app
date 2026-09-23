import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../app/language_menu.dart';
import '../../domain/entities/breed.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_state_message.dart';
import 'breed_detail_providers.dart';
import 'widgets/breed_detail_content.dart';

/// Leaves detail without rebuilding the catalog.
///
/// Arriving from the catalog leaves it mounted below this route, so popping
/// restores it with its scroll position, search text, and state intact. A
/// direct visit or a browser refresh has no previous route, so it falls back
/// to the catalog location.
void _leaveDetail(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.breeds);
  }
}

/// Renders the breed selected by the route.
///
/// Loading, retry, and unavailable-ID states are coordinated here. Gallery and
/// information content arrives resolved from the providers.
class BreedDetailScreen extends ConsumerWidget {
  const BreedDetailScreen({super.key, required this.breedId});

  final String breedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breed = ref.watch(breedByIdProvider(breedId));
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      // The photo area carries its own controls once the breed is known. The
      // states without a photo keep a bar so they still offer a way back.
      appBar: breed.value == null
          ? AppBar(
              leading: IconButton(
                key: const Key('detail-back'),
                tooltip: strings.backToBreeds,
                onPressed: () => _leaveDetail(context),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: Text(strings.appTitle),
              actions: const [LanguageMenu()],
            )
          : null,
      body: breed.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => AppStateMessage(
          icon: Icons.wifi_off_rounded,
          title: strings.detailErrorTitle,
          action: FilledButton(
            onPressed: () => ref.invalidate(breedByIdProvider(breedId)),
            child: Text(strings.retry),
          ),
        ),
        data: (selected) => selected == null
            ? AppStateMessage(
                icon: Icons.pets_outlined,
                title: strings.breedNotFound,
              )
            : _BreedDetailBody(breed: selected),
      ),
    );
  }
}

/// Requests the gallery only once the breed is known, so an unavailable ID
/// never starts a photo request. A gallery failure stays inside the gallery
/// and does not replace the breed information.
class _BreedDetailBody extends ConsumerWidget {
  const _BreedDetailBody({required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(breedPhotosProvider(breed.id));
    return BreedDetailContent(
      breed: breed,
      imageUrls: ref.watch(breedGalleryImagesProvider(breed.id)),
      photos: photos,
      relatedBreeds: ref.watch(relatedBreedsProvider(breed.id)),
      onRetryGallery: () {
        ref.invalidate(breedPhotosProvider(breed.id));
      },
      onBreedSelected: (selected) =>
          context.push(AppRoutes.breedDetailPath(selected.id)),
      onShowAllBreeds: () => context.go(AppRoutes.breeds),
      onBack: () => _leaveDetail(context),
    );
  }
}
