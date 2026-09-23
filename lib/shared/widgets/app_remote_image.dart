import 'package:flutter/material.dart';

import '../responsive.dart';

class AppRemoteImage extends StatelessWidget {
  const AppRemoteImage({super.key, required this.url, this.fit = BoxFit.cover});

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
      // The Cat API serves images from cdn2.thecatapi.com, which does not send
      // CORS headers. Flutter Web reads image bytes with XHR, so the browser
      // blocks those requests and the image never reaches the canvas. The
      // fallback strategy retries the same URL in an HTML <img> platform view,
      // which is not subject to that restriction. The option is ignored on
      // mobile and desktop, where bytes are always fetched.
      webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
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
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: showProgress
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Icon(
                Icons.pets_rounded,
                size: responsive.icon(48),
                color: colors.primary,
              ),
      ),
    );
  }
}
