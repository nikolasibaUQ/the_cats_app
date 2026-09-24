import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_locale_controller.dart';
import '../../../app/app_routes.dart';
import '../../../domain/entities/breed.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/widgets.dart';
import '../../breeds_providers.dart';
import '../providers/breed_detail_providers.dart';
import '../widgets/widgets.dart';

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
    final selectedLanguage = ref.watch(appLocaleControllerProvider);
    final selectLanguage = ref
        .read(appLocaleControllerProvider.notifier)
        .select;
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
              actions: [
                LanguageMenu(
                  selected: selectedLanguage,
                  onSelected: selectLanguage,
                ),
              ],
            )
          : null,
      body: breed.when(
        loading: () => AppStateMessage(
          title: strings.loadingCats,
          visual: LocalizedStateIllustration(
            kind: StateIllustrationKind.loading,
            semanticLabel: strings.loadingCats,
          ),
        ),
        error: (error, stackTrace) => AppStateMessage(
          title: strings.detailErrorTitle,
          visual: LocalizedStateIllustration(
            kind: StateIllustrationKind.notFound,
            semanticLabel: strings.detailErrorTitle,
            maxWidth: 240,
          ),
          action: FilledButton(
            onPressed: () => ref.invalidate(breedsProvider),
            child: Text(strings.retry),
          ),
        ),
        data: (selected) => selected == null
            ? AppStateMessage(
                title: strings.breedNotFound,
                visual: LocalizedStateIllustration(
                  kind: StateIllustrationKind.notFound,
                  semanticLabel: strings.breedNotFound,
                ),
              )
            : _BreedDetailBody(
                breed: selected,
                selectedLanguage: selectedLanguage,
                onLanguageSelected: selectLanguage,
              ),
      ),
    );
  }
}

/// Requests the gallery only once the breed is known, so an unavailable ID
/// never starts a photo request. A gallery failure stays inside the gallery
/// and does not replace the breed information.
class _BreedDetailBody extends ConsumerWidget {
  const _BreedDetailBody({
    required this.breed,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  final Breed breed;
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoRequest = ref.watch(breedPhotosProvider(breed.id));
    return BreedDetailContent(
      breed: breed,
      photos: ref.watch(breedGalleryPhotosProvider(breed.id)),
      photoRequest: photoRequest,
      relatedBreeds: ref.watch(relatedBreedsProvider(breed.id)),
      onRetryGallery: () {
        ref.invalidate(breedPhotosProvider(breed.id));
      },
      onBreedSelected: (selected) =>
          context.push(AppRoutes.breedDetailPath(selected.id)),
      onShowAllBreeds: () => context.go(AppRoutes.breeds),
      onBack: () => _leaveDetail(context),
      selectedLanguage: selectedLanguage,
      onLanguageSelected: onLanguageSelected,
    );
  }
}
