import 'package:flutter/material.dart';

import '../../../shared/responsive.dart';

class BreedImage extends StatelessWidget {
  const BreedImage({super.key, required this.url, this.fit = BoxFit.cover});

  final String? url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) return const _Fallback();
    return Image.network(
      imageUrl,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const _Fallback(showProgress: true),
      errorBuilder: (context, error, stackTrace) => const _Fallback(),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({this.showProgress = false});

  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return ColoredBox(
      color: const Color(0xFFF2E6D9),
      child: Center(
        child: showProgress
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Icon(
                Icons.pets_rounded,
                size: responsive.icon(48),
                color: const Color(0xFFB58B74),
              ),
      ),
    );
  }
}
