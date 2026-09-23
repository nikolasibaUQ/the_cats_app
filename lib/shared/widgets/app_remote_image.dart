import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'localized_state_illustration.dart';

/// Remote breed photo that never leaves an empty box behind.
///
/// Localized loading artwork is always rendered underneath a remote request.
/// The matching unavailable artwork replaces it when the URL is absent or the
/// request fails, so cards, detail, and the viewer share the same states.
class AppRemoteImage extends StatelessWidget {
  const AppRemoteImage({
    super.key,
    required this.url,
    this.label,
    this.caption,
    this.loading = false,
    this.fit = BoxFit.cover,
  });

  final String? url;

  /// Accessible name of the remote photo, usually the breed name.
  final String? label;

  /// Accessible explanation used when no photo can be shown.
  final String? caption;

  /// Whether an external lookup is still trying to provide a missing URL.
  final bool loading;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final imageUrl = url?.trim();
    final hasImageUrl = imageUrl != null && imageUrl.isNotEmpty;
    final showLoading = hasImageUrl || loading;
    return Stack(
      fit: StackFit.expand,
      children: [
        LocalizedStateIllustration(
          kind: showLoading
              ? StateIllustrationKind.loading
              : StateIllustrationKind.notFound,
          semanticLabel: showLoading
              ? strings.loadingCats
              : caption ?? strings.noPhoto,
          expand: true,
        ),
        if (hasImageUrl)
          Image.network(
            imageUrl,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: label,
            // The Cat API serves images from cdn2.thecatapi.com, which sends no
            // CORS headers. Flutter Web reads image bytes with XHR, so the
            // browser blocks that request and logs a CORS error for every
            // photo. Preferring the HTML element avoids the blocked request
            // entirely: an <img> tag is not subject to the same-origin policy
            // and the browser caches it. The option is ignored on mobile and
            // desktop, which always fetch bytes and keep the loading builder.
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const SizedBox.expand(),
            errorBuilder: (context, error, stackTrace) =>
                LocalizedStateIllustration(
                  kind: StateIllustrationKind.notFound,
                  semanticLabel: caption ?? strings.noPhoto,
                  expand: true,
                ),
          ),
      ],
    );
  }
}
