import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/responsive.dart';
import '../../../shared/widgets/section_title.dart';
import '../../catalog/widgets/breed_card.dart';

/// Horizontal suggestion row with the remaining breeds.
///
/// The row shows a bounded set and reports how many breeds it leaves out, so
/// browsing stays local while the full catalog stays one action away.
class RelatedBreedsSection extends StatelessWidget {
  const RelatedBreedsSection({
    super.key,
    required this.breeds,
    required this.onBreedSelected,
    required this.onShowAll,
  });

  /// Breeds to suggest, already excluding the one on screen.
  final List<Breed> breeds;

  final ValueChanged<Breed> onBreedSelected;
  final VoidCallback onShowAll;

  static const int visibleCount = 6;

  @override
  Widget build(BuildContext context) {
    if (breeds.isEmpty) return const SizedBox.shrink();
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final visible = breeds.take(visibleCount).toList();
    final remaining = breeds.length - visible.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: SectionTitle(strings.relatedBreeds)),
            if (remaining > 0)
              TextButton(
                onPressed: onShowAll,
                child: Text(strings.moreBreeds(remaining)),
              ),
          ],
        ),
        SizedBox(height: responsive.spacing(8)),
        SizedBox(
          height: responsive.size(240),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visible.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: responsive.spacing(12)),
            itemBuilder: (context, index) {
              final breed = visible[index];
              return SizedBox(
                width: responsive.size(180),
                child: BreedCard(
                  breed: breed,
                  compact: true,
                  onTap: () => onBreedSelected(breed),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
