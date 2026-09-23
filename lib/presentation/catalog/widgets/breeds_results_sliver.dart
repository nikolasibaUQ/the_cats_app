import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_state_message.dart';
import '../../../shared/widgets/localized_state_illustration.dart';
import '../breeds_catalog_view.dart';
import 'breed_card.dart';

/// Renders derived catalog results.
///
/// Visible breeds, match count, and whether the source list had breeds all
/// arrive resolved, so this widget only lays out the grid, the empty states,
/// and the reveal control. Navigation is dispatched to the screen.
class BreedsResultsSliver extends StatelessWidget {
  const BreedsResultsSliver({
    super.key,
    required this.view,
    required this.onBreedSelected,
    required this.onShowMore,
  });

  final BreedsCatalogView view;
  final ValueChanged<Breed> onBreedSelected;
  final VoidCallback onShowMore;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final breeds = view.visibleBreeds;
    if (breeds.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AppStateMessage(
          title: view.hasLoadedBreeds
              ? strings.noMatchesTitle
              : strings.noBreedsTitle,
          visual: LocalizedStateIllustration(
            kind: StateIllustrationKind.notFound,
            semanticLabel: view.hasLoadedBreeds
                ? strings.noMatchesTitle
                : strings.noBreedsTitle,
            maxWidth: 240,
          ),
          detail: view.hasLoadedBreeds
              ? strings.noMatchesDetail
              : strings.noBreedsDetail,
        ),
      );
    }

    final responsive = Responsive.of(context);
    final hasMore = view.matchedCount > breeds.length;
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            responsive.pagePadding,
            responsive.spacing(4),
            responsive.pagePadding,
            responsive.spacing(16),
          ),
          sliver: SliverToBoxAdapter(
            child: _ResultsHeader(
              shown: breeds.length,
              total: view.matchedCount,
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
          sliver: SliverLayoutBuilder(
            builder: (context, constraints) {
              final gap = responsive.spacing(16);
              final columns =
                  ((constraints.crossAxisExtent + gap) /
                          (responsive.size(220) + gap))
                      .floor()
                      .clamp(1, 4);
              return SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: gap,
                  mainAxisSpacing: gap,
                  mainAxisExtent: responsive.size(columns == 1 ? 320 : 280),
                ),
                itemCount: breeds.length,
                itemBuilder: (context, index) {
                  final breed = breeds[index];
                  return BreedCard(
                    breed: breed,
                    onTap: () => onBreedSelected(breed),
                  );
                },
              );
            },
          ),
        ),
        if (hasMore)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              responsive.pagePadding,
              responsive.spacing(20),
              responsive.pagePadding,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: OutlinedButton(
                  key: const Key('show-more-breeds'),
                  onPressed: onShowMore,
                  child: Text(strings.showMoreBreeds),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(child: SizedBox(height: responsive.spacing(32))),
      ],
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.shown, required this.total});

  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: responsive.spacing(12),
      runSpacing: responsive.spacing(4),
      children: [
        Text(
          strings.breedsLabel,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        Text(
          strings.showingBreeds(shown, total),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }
}
