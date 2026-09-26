import 'package:flutter/material.dart';

import '../../../domain/entities/breed.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_remote_image.dart';
import '../../../shared/widgets/rating_dots.dart';

/// Renders one breed. Opening detail is the screen's decision, so the card only
/// reports the tap through [onTap].
///
/// The footer states the country of origin under its label and, when the
/// bundled reference dataset has an entry for the breed, its intelligence as
/// five dots on the right of the same row.
///
/// On pointer devices the card lifts with a brand-tinted shadow and purple
/// border while hovered, keeping the grid alive; touch devices simply never
/// enter the hover state.
class BreedCard extends StatefulWidget {
  const BreedCard({
    super.key,
    required this.breed,
    required this.onTap,
    this.intelligence,
  });

  final Breed breed;
  final VoidCallback onTap;

  /// 1-to-5 intelligence rating of the bundled reference dataset, when the
  /// dataset has an entry for this breed.
  final int? intelligence;

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
                      if (widget.breed.origin != null ||
                          widget.intelligence != null) ...[
                        SizedBox(height: responsive.spacing(10)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.breed.origin != null)
                              Expanded(
                                child: _LabeledFact(
                                  label: AppLocalizations.of(
                                    context,
                                  )!.countryOfOrigin,
                                  child: Text(
                                    widget.breed.origin!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ),
                            if (widget.intelligence != null) ...[
                              if (widget.breed.origin != null)
                                SizedBox(width: responsive.spacing(8)),
                              _LabeledFact(
                                label: AppLocalizations.of(
                                  context,
                                )!.intelligence,
                                alignEnd: true,
                                child: RatingDots(
                                  value: widget.intelligence!,
                                  size: 8,
                                  semanticLabel: AppLocalizations.of(
                                    context,
                                  )!.intelligence,
                                ),
                              ),
                            ],
                          ],
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

/// Small label above a value, keeping the two footer facts of a card aligned
/// with each other while the label stays readable.
class _LabeledFact extends StatelessWidget {
  const _LabeledFact({
    required this.label,
    required this.child,
    this.alignEnd = false,
  });

  final String label;
  final Widget child;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2),
        child,
      ],
    );
  }
}
