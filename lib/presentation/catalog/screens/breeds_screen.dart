import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_locale_controller.dart';
import '../../../app/app_routes.dart';
import '../../../app/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';
import '../../breeds_providers.dart';
import '../controllers/breeds_catalog_controller.dart';
import '../providers/breeds_catalog_view_provider.dart';
import '../widgets/widgets.dart';

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
    final selectedLanguage = ref.watch(appLocaleControllerProvider);
    final selectLanguage = ref
        .read(appLocaleControllerProvider.notifier)
        .select;
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          LanguageMenu(selected: selectedLanguage, onSelected: selectLanguage),
        ],
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(gradient: AppTheme.appBarGradient),
        ),
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
                        loading: () => SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppStateMessage(
                            title: strings.loadingCats,
                            visual: LocalizedStateIllustration(
                              kind: StateIllustrationKind.loading,
                              semanticLabel: strings.loadingCats,
                            ),
                          ),
                        ),
                        error: (error, stackTrace) => SliverFillRemaining(
                          hasScrollBody: false,
                          child: AppStateMessage(
                            title: strings.loadErrorTitle,
                            visual: LocalizedStateIllustration(
                              kind: StateIllustrationKind.notFound,
                              semanticLabel: strings.loadErrorTitle,
                              maxWidth: 240,
                            ),
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
