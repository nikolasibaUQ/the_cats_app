import 'package:flutter/material.dart';

/// Muted, letter-spaced heading that introduces a group of related values.
///
/// It is not a page or panel title: it sits inside a scrolling column, so keep
/// it to the section name and let the content carry the emphasis.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: colors.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
