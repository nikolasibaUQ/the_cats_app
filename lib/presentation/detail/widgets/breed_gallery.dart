import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/breed_photo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/responsive.dart';
import '../../../shared/widgets/app_remote_image.dart';
import '../../../shared/widgets/overlay_circle_surface.dart';
import 'breed_fullscreen_gallery.dart';

/// Renders the breed photo carousel.
///
/// It receives the images to show and the state of the request that loads more
/// of them, so the pending indicator and the retry control never replace the
/// images that are already available.
class BreedGallery extends StatefulWidget {
  const BreedGallery({
    super.key,
    required this.imageUrls,
    required this.photos,
    required this.onRetry,
    this.label,
  });

  /// Primary image first, followed by any photo already loaded.
  final List<String> imageUrls;

  final AsyncValue<List<BreedPhoto>> photos;

  /// Breed name the placeholder uses when no photo can be shown.
  final String? label;

  /// Requests the additional photos again.
  final VoidCallback onRetry;

  @override
  State<BreedGallery> createState() => _BreedGalleryState();
}

class _BreedGalleryState extends State<BreedGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void didUpdateWidget(BreedGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex >= widget.imageUrls.length) {
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
    if (widget.imageUrls.isEmpty) return;
    await showDialog<void>(
      context: context,
      useSafeArea: false,
      builder: (context) => BreedFullscreenGallery(
        imageUrls: widget.imageUrls,
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

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.imageUrls.isEmpty)
          // A breed the API has no photo for: the monogram identifies it and
          // the caption explains the gap, so the area does not look unfinished.
          AppRemoteImage(
            url: null,
            label: widget.label,
            caption: strings.noPhoto,
          )
        else
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Semantics(
              button: true,
              label: strings.openPhotoFullscreen,
              child: InkWell(
                onTap: _openFullscreen,
                child: AppRemoteImage(
                  url: widget.imageUrls[index],
                  label: widget.label,
                ),
              ),
            ),
          ),
        if (widget.imageUrls.isNotEmpty)
          Positioned(
            left: responsive.spacing(12),
            bottom: responsive.spacing(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.imageUrls.length > 1) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
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
                          widget.imageUrls.length,
                        ),
                        style: Theme.of(
                          context,
                        ).textTheme.labelLarge?.copyWith(color: Colors.white),
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
        if (_currentIndex > 0)
          Align(
            alignment: Alignment.centerLeft,
            child: OverlayCircleSurface(
              child: IconButton(
                tooltip: strings.previousPhoto,
                onPressed: () => _showPage(_currentIndex - 1),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ),
        if (_currentIndex + 1 < widget.imageUrls.length)
          Align(
            alignment: Alignment.centerRight,
            child: OverlayCircleSurface(
              child: IconButton(
                tooltip: strings.nextPhoto,
                onPressed: () => _showPage(_currentIndex + 1),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          ),
        if (widget.photos.isLoading)
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
        if (widget.photos.hasError)
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
