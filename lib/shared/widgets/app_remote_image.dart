import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import '../utils/responsive.dart';
import 'localized_state_illustration.dart';

/// Renders a remote breed photo with localized loading and unavailable states.
///
/// The loading state is replaced completely once the image is ready, so it
/// cannot remain visible around a contained photo. Missing URLs and failed
/// requests replace the frame with the unavailable state.
class AppRemoteImage extends StatelessWidget {
  const AppRemoteImage({
    super.key,
    required this.url,
    this.label,
    this.caption,
    this.loading = false,
    this.showStateLabel = true,
    this.fit = BoxFit.cover,
  });

  final String? url;

  /// Accessible name of the remote photo, usually the breed name.
  final String? label;

  /// Accessible explanation used when no photo can be shown.
  final String? caption;

  /// Whether an external lookup is still trying to provide a missing URL.
  final bool loading;

  /// Whether the localized state copy is painted over the artwork.
  final bool showStateLabel;

  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final imageUrl = url?.trim();
    final hasImageUrl = imageUrl != null && imageUrl.isNotEmpty;
    final showLoading = hasImageUrl || loading;
    if (!hasImageUrl) {
      return _PhotoStateArtwork(
        kind: showLoading
            ? StateIllustrationKind.loading
            : StateIllustrationKind.notFound,
        label: showLoading ? strings.loadingCats : caption ?? strings.noPhoto,
        showLabel: showStateLabel,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        // The API serves photos far larger than any frame the app shows (up
        // to ~3100 px wide): decoding one at full size costs tens of
        // megabytes, and a few such photos can evict the whole image cache,
        // which re-downloads them on every scroll back. Decoding at the
        // displayed size keeps photos cached across the scroll and saves
        // bandwidth. The resize never upscales, so a frame wider than the
        // original (the full-screen viewer with its medium-size photos)
        // keeps the original size.
        final maxWidth = constraints.maxWidth;
        final cacheWidth = maxWidth.isFinite
            ? (maxWidth * MediaQuery.devicePixelRatioOf(context)).round()
            : null;
        return Image.network(
          imageUrl,
          fit: fit,
          cacheWidth: cacheWidth,
          width: double.infinity,
          height: double.infinity,
          semanticLabel: label,
          // The Cat API serves images from cdn2.thecatapi.com, which sends no
          // CORS headers. Preferring an HTML element prevents one blocked XHR
          // per photo.
          webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : _PhotoStateArtwork(
                  kind: StateIllustrationKind.loading,
                  label: strings.loadingCats,
                  showLabel: showStateLabel,
                ),
          errorBuilder: (context, error, stackTrace) => _PhotoStateArtwork(
            kind: StateIllustrationKind.notFound,
            label: caption ?? strings.noPhoto,
            showLabel: showStateLabel,
          ),
        );
      },
    );
  }
}

class _PhotoStateArtwork extends StatelessWidget {
  const _PhotoStateArtwork({
    required this.kind,
    required this.label,
    required this.showLabel,
  });

  final StateIllustrationKind kind;
  final String label;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        LocalizedStateIllustration(
          kind: kind,
          semanticLabel: label,
          expand: true,
        ),
        if (showLabel)
          Positioned(
            left: responsive.spacing(12),
            right: responsive.spacing(12),
            bottom: responsive.spacing(12),
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(responsive.radius(10)),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.spacing(12),
                    vertical: responsive.spacing(7),
                  ),
                  child: ExcludeSemantics(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
