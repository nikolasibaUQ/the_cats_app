import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_remote_image.dart';

/// Renders one breed. Opening detail is the screen's decision, so the card only
/// reports the tap through [onTap].
class BreedCard extends StatelessWidget {
  const BreedCard({super.key, required this.breed, required this.onTap});

  final Breed breed;
  final VoidCallback onTap;

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
            Expanded(
              child: AppRemoteImage(url: breed.imageUrl, label: breed.name),
            ),
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
                  if (breed.origin != null) ...[
                    SizedBox(height: responsive.spacing(6)),
                    Text(
                      breed.origin!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
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
