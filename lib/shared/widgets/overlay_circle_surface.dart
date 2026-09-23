import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Translucent circular surface for controls that float above a photo.
///
/// The shared surface keeps overlaid controls readable on any image while
/// leaving the control itself (icon button, menu) up to the caller.
class OverlayCircleSurface extends StatelessWidget {
  const OverlayCircleSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: responsive.spacing(1),
      child: child,
    );
  }
}
