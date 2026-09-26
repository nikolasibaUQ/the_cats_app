import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_remote_image.dart';

/// Renders one breed. Opening detail is the screen's decision, so the card only
/// reports the tap through [onTap].
///
/// On pointer devices the card lifts with a brand-tinted shadow and purple
/// border while hovered, keeping the grid alive; touch devices simply never
/// enter the hover state.
class BreedCard extends StatefulWidget {
  const BreedCard({super.key, required this.breed, required this.onTap});

  final Breed breed;
  final VoidCallback onTap;

  @override
  State<BreedCard> createState() => _BreedCardState();
}

class _BreedCardState extends State<BreedCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(responsive.radius(16));
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: radius,
          border: Border.all(
            color: _hovered ? colors.primary : colors.outlineVariant,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: radius,
            hoverColor: colors.primary.withValues(alpha: 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppRemoteImage(
                    url: widget.breed.imageUrl,
                    label: widget.breed.name,
                  ),
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
                              widget.breed.name,
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
                      if (widget.breed.origin != null) ...[
                        SizedBox(height: responsive.spacing(6)),
                        Text(
                          widget.breed.origin!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
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
