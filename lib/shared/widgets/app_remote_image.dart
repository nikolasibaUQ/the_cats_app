import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Remote breed photo that never leaves an empty box behind.
///
/// A placeholder is always rendered underneath, so a missing URL, a slow
/// download, or a failed request still shows something intentional instead of
/// a blank area. When the photo arrives it simply covers the placeholder, which
/// also removes the loading flash.
class AppRemoteImage extends StatelessWidget {
  const AppRemoteImage({
    super.key,
    required this.url,
    this.label,
    this.caption,
    this.fit = BoxFit.cover,
  });

  final String? url;

  /// Name the placeholder borrows its initial from. Usually the breed name, so
  /// two empty photos do not look like the same broken card.
  final String? label;

  /// Line rendered under the placeholder, for areas where an empty photo needs
  /// an explanation instead of only an image.
  final String? caption;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim();
    return Stack(
      fit: StackFit.expand,
      children: [
        _Placeholder(label: label, caption: caption),
        if (imageUrl != null && imageUrl.isNotEmpty)
          Image.network(
            imageUrl,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
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
            // The placeholder underneath already reports the failure, so the
            // failed image is removed instead of drawing another empty box.
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.expand(),
          ),
      ],
    );
  }
}

/// Calm stand-in for a photo: the initial of the breed on a soft circle, with a
/// small paw that keeps the cat context when no name is available.
class _Placeholder extends StatelessWidget {
  const _Placeholder({this.label, this.caption});

  final String? label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final initial = _initialOf(label);
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (initial != null) ...[
              Container(
                width: responsive.icon(52),
                height: responsive.icon(52),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  initial,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: responsive.spacing(8)),
            ],
            Icon(
              Icons.pets_rounded,
              size: responsive.icon(initial == null ? 48 : 24),
              color: colors.primary.withValues(
                alpha: initial == null ? 1 : 0.6,
              ),
            ),
            if (caption != null) ...[
              SizedBox(height: responsive.spacing(12)),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsive.size(240)),
                child: Text(
                  caption!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// First letter of [label], or null when there is nothing usable to show.
String? _initialOf(String? label) {
  final trimmed = label?.trim() ?? '';
  if (trimmed.isEmpty) return null;
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}
