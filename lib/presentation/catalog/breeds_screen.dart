import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_routes.dart';
import '../../app/language_menu.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/responsive.dart';
import '../../shared/widgets/app_state_message.dart';
import '../breeds_providers.dart';
import 'breeds_catalog_controller.dart';
import 'breeds_catalog_view.dart';
import 'widgets/breeds_header.dart';
import 'widgets/breeds_results_sliver.dart';

/// Renders the catalog. Loading, retry, search input, navigation, and layout
/// are coordinated here; matching breeds are resolved by
/// `breedsCatalogViewProvider`.
class BreedsScreen extends ConsumerWidget {
  const BreedsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogState = ref.watch(breedsCatalogControllerProvider);
    final catalog = ref.watch(breedsCatalogViewProvider);
    final controller = ref.read(breedsCatalogControllerProvider.notifier);
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          const LanguageMenu(),
          IconButton(
            tooltip: strings.refreshBreeds,
            onPressed: () => ref.invalidate(breedsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.pagePadding,
                    responsive.spacing(20),
                    responsive.pagePadding,
                    responsive.spacing(16),
                  ),
                  child: BreedsHeader(
                    onQueryChanged: controller.search,
                    showMinimumHint: catalogState.showMinimumHint,
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    key: const Key('breeds-results-scroll'),
                    slivers: [
                      catalog.when<Widget>(
                        loading: () => const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stackTrace) => SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppStateMessage(
                            icon: Icons.wifi_off_rounded,
                            title: strings.loadErrorTitle,
                            detail: strings.loadErrorDetail,
                            action: FilledButton(
                              onPressed: () => ref.invalidate(breedsProvider),
                              child: Text(strings.retry),
                            ),
                          ),
                        ),
                        data: (view) => BreedsResultsSliver(
                          view: view,
                          // Pushing keeps the catalog mounted below the detail,
                          // so scroll position, search text, and controller
                          // state survive a return without any extra caching.
                          onBreedSelected: (breed) =>
                              context.push(AppRoutes.breedDetailPath(breed.id)),
                          onShowMore: controller.showMore,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
