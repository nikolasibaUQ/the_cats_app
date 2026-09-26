import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../utils/responsive.dart';

/// Renders a 1-to-5 rating as filled and empty dots.
///
/// Ratings describe how much of a trait a breed shows, not a quality score, so
/// the dots stay neutral: the primary color marks filled values only. Pass a
/// [semanticLabel] when the dots have no visible label of their own.
class RatingDots extends StatelessWidget {
  const RatingDots({
    super.key,
    required this.value,
    this.size = 10,
    this.semanticLabel,
  });

  final int value;
  final double size;
  final String? semanticLabel;

  static const int maxValue = 5;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    final dots = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < maxValue; index++) ...[
          if (index > 0) SizedBox(width: responsive.spacing(4)),
          Icon(
            Icons.circle,
            size: responsive.icon(size),
            color: index < value ? colors.primary : colors.outlineVariant,
          ),
        ],
      ],
    );
    final label = semanticLabel;
    if (label == null) return dots;
    final rating = AppLocalizations.of(context)!.ratingValue(value);
    return Semantics(
      label: '$label: $rating',
      child: ExcludeSemantics(child: dots),
    );
  }
}
