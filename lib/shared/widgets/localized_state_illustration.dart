import 'package:flutter/material.dart';

/// State artwork that selects its portrait or landscape variant from the space
/// available to it. Visible copy stays outside the bitmap and is rendered by
/// Flutter, while [semanticLabel] gives the illustration an accessible name.
class LocalizedStateIllustration extends StatelessWidget {
  const LocalizedStateIllustration({
    super.key,
    required this.kind,
    required this.semanticLabel,
    this.maxWidth = 300,
    this.expand = false,
  });

  final StateIllustrationKind kind;
  final String semanticLabel;
  final double maxWidth;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    if (!expand) {
      final viewport = MediaQuery.sizeOf(context);
      return _buildIllustration(
        useLandscape: viewport.width >= viewport.height,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final useLandscape =
            constraints.hasBoundedWidth &&
            constraints.hasBoundedHeight &&
            constraints.maxWidth >= constraints.maxHeight;
        return _buildIllustration(useLandscape: useLandscape);
      },
    );
  }

  Widget _buildIllustration({required bool useLandscape}) {
    final suffix = useLandscape ? '4_3' : '3_4';
    final assetName = switch (kind) {
      StateIllustrationKind.loading => 'assets/images/loading_$suffix.png',
      StateIllustrationKind.notFound => 'assets/images/no_find_$suffix.png',
    };
    final image = Image.asset(
      assetName,
      key: ValueKey<String>(assetName),
      width: expand ? double.infinity : maxWidth,
      height: expand ? double.infinity : null,
      fit: expand ? BoxFit.cover : BoxFit.contain,
    );

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ExcludeSemantics(child: image),
    );
  }
}

enum StateIllustrationKind { loading, notFound }
