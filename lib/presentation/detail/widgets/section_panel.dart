import 'package:flutter/material.dart';

import '../../../shared/utils/responsive.dart';

/// Rounded surface that holds the content of one detail section.
///
/// Description and history share this frame, so the two sections read as one
/// family instead of two unrelated boxes.
class SectionPanel extends StatelessWidget {
  const SectionPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.spacing(20)),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: child,
    );
  }
}
