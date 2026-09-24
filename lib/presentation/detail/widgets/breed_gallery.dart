import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/breed_photo.dart';
import '../../../domain/policies/breed_gallery.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/app_remote_image.dart';
import '../../../shared/widgets/overlay_circle_surface.dart';
import 'breed_fullscreen_gallery.dart';

/// Renders the breed photo carousel.
///
/// It receives the photos to show and the state of the request that loads more
/// of them, so the pending indicator and the retry control never replace the
/// photos that are already available. The area that frames it sizes itself from
/// the photo the carousel reports through [onPhotoChanged].
class BreedGallery extends StatefulWidget {
  const BreedGallery({
    super.key,
    required this.photos,
    required this.photoRequest,
    required this.onRetry,
    this.label,
    this.onPhotoChanged,
  });

  /// Primary photo first, followed by any photo already loaded.
  final List<GalleryPhoto> photos;

  /// State of the request that loads the additional photos.
  final AsyncValue<List<BreedPhoto>> photoRequest;

  /// Breed name the placeholder uses when no photo can be shown.
  final String? label;

  /// Requests the additional photos again.
  final VoidCallback onRetry;

  /// Reports the photo now shown, so the area framing the carousel can adopt
  /// its shape instead of scaling it into a fixed rectangle.
  final ValueChanged<GalleryPhoto>? onPhotoChanged;

  @override
  State<BreedGallery> createState() => _BreedGalleryState();
}

class _BreedGalleryState extends State<BreedGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void didUpdateWidget(BreedGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex >= widget.photos.length) {
      _currentIndex = 0;
      if (_pageController.hasClients) _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openFullscreen() async {
    if (widget.photos.isEmpty) return;
    await showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (context) => BreedFullscreenGallery(
        photos: widget.photos,
        initialIndex: _currentIndex,
        label: widget.label,
      ),
    );
  }

  Future<void> _showPage(int index) => _pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 220),
    curve: Curves.easeOut,
  );

  void _showIndex(int index) {
    setState(() => _currentIndex = index);
    widget.onPhotoChanged?.call(widget.photos[index]);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    final colors = Theme.of(context).colorScheme;
    final isLoadingPhotos =
        widget.photoRequest.isLoading && !widget.photoRequest.hasError;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.photos.isEmpty)
          // A breed the API has no photo for uses the localized unavailable
          // artwork, so the area does not look unfinished.
          AppRemoteImage(
            url: null,
            label: widget.label,
            caption: strings.noPhoto,
            loading: isLoadingPhotos,
            showStateLabel: !widget.photoRequest.hasError,
          )
        else
          PageView.builder(
            controller: _pageController,
            itemCount: widget.photos.length,
            onPageChanged: _showIndex,
            itemBuilder: (context, index) => Semantics(
              button: true,
              label: strings.openPhotoFullscreen,
              child: InkWell(
                onTap: _openFullscreen,
                child: AppRemoteImage(
                  url: widget.photos[index].url,
                  label: widget.label,
                ),
              ),
            ),
          ),
        if (widget.photos.isNotEmpty)
          Positioned(
            left: responsive.spacing(12),
            bottom: responsive.spacing(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.photos.length > 1) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.onSurface.withValues(alpha: 0.78),
                      borderRadius: BorderRadius.circular(
                        responsive.radius(12),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.spacing(10),
                        vertical: responsive.spacing(6),
                      ),
                      child: Text(
                        strings.photoPosition(
                          _currentIndex + 1,
                          widget.photos.length,
                        ),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.surfaceContainer,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: responsive.spacing(8)),
                ],
                OverlayCircleSurface(
                  child: IconButton(
                    tooltip: strings.openPhotoFullscreen,
                    onPressed: _openFullscreen,
                    icon: const Icon(Icons.fullscreen_rounded),
                  ),
                ),
              ],
            ),
          ),
        if (widget.photos.length > 1) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: _GalleryPagerButton(
              tooltip: strings.previousPhoto,
              onPressed: _currentIndex == 0
                  ? null
                  : () => _showPage(_currentIndex - 1),
              icon: const Icon(Icons.chevron_left_rounded),
              useAccentSurface: !responsive.isDesktop,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _GalleryPagerButton(
              tooltip: strings.nextPhoto,
              onPressed: _currentIndex + 1 == widget.photos.length
                  ? null
                  : () => _showPage(_currentIndex + 1),
              icon: const Icon(Icons.chevron_right_rounded),
              useAccentSurface: !responsive.isDesktop,
            ),
          ),
        ],
        if (widget.photos.isNotEmpty && isLoadingPhotos)
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        if (widget.photoRequest.hasError)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: responsive.spacing(12)),
              child: FilledButton.tonalIcon(
                onPressed: widget.onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(strings.retryGallery),
              ),
            ),
          ),
      ],
    );
  }
}

/// Keeps photo paging legible without making it resemble a screen action on
/// compact layouts. The terracotta treatment retains the app's visual
/// direction; wide layouts retain the light overlay treatment.
class _GalleryPagerButton extends StatelessWidget {
  const _GalleryPagerButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    required this.useAccentSurface,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget icon;
  final bool useAccentSurface;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final button = IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: icon,
      style: useAccentSurface
          ? IconButton.styleFrom(
              foregroundColor: colors.onPrimary,
              disabledForegroundColor: colors.onSurfaceVariant,
            )
          : null,
    );
    if (!useAccentSurface) return OverlayCircleSurface(child: button);

    return Material(
      color: onPressed == null
          ? colors.surfaceContainerHighest.withValues(alpha: 0.94)
          : colors.primary.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: button,
    );
  }
}
