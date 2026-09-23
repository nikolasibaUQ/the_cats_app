import 'package:flutter/material.dart';

import '../../../domain/breed.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/responsive.dart';
import '../../../shared/widgets/app_remote_image.dart';
import '../../../shared/widgets/rating_dots.dart';

/// Renders one breed. Opening detail is the screen's decision, so the card only
/// reports the tap through [onTap].
class BreedCard extends StatelessWidget {
  const BreedCard({
    super.key,
    required this.breed,
    required this.onTap,
    this.compact = false,
  });

  final Breed breed;
  final VoidCallback onTap;

  /// Keeps only the identifying information, for suggestion rows where the card
  /// is a secondary choice rather than the content of the screen.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: AppRemoteImage(url: breed.imageUrl)),
            Padding(
              padding: EdgeInsets.all(responsive.spacing(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          breed.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  if (breed.origin != null ||
                      (!compact && breed.intelligence != null)) ...[
                    SizedBox(height: responsive.spacing(6)),
                    Row(
                      children: [
                        if (breed.origin != null)
                          Expanded(
                            child: Text(
                              breed.origin!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          )
                        else
                          const Spacer(),
                        if (!compact && breed.intelligence != null)
                          RatingDots(
                            value: breed.intelligence!,
                            size: 8,
                            semanticLabel: AppLocalizations.of(
                              context,
                            )!.intelligence,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
