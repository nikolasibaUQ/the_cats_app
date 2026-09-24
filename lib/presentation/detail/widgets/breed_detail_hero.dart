import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_locale_controller.dart';
import '../../../domain/entities/entities.dart';
import '../../../domain/policies/breed_gallery.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/widgets.dart';
import '../../photo_framing.dart';
import 'breed_gallery.dart';

/// Photo area of the detail screen.
///
/// The area takes the shape of the photo the gallery is showing, bounded by the
/// space the layout offers, so a landscape photo is not zoomed into a narrow
/// column and a portrait one is not cropped into a wide band. The gallery fills
/// the area and the controls that belong to the screen float above it: leaving
/// the detail, the language selector, and the breed code. The photo area never
/// scrolls; only the information beside or below it does.
class BreedDetailHero extends StatefulWidget {
  const BreedDetailHero({
    super.key,
    required this.breed,
    required this.photos,
    required this.photoRequest,
    required this.onRetryGallery,
    required this.onBack,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.borderRadius,
  });

  final Breed breed;
  final List<GalleryPhoto> photos;
  final AsyncValue<List<BreedPhoto>> photoRequest;
  final VoidCallback onRetryGallery;
  final VoidCallback onBack;
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageSelected;

  /// Rounded edges of the photo area. Detail that fills the top of a narrow
  /// screen rounds its bottom corners only.
  final BorderRadius borderRadius;

  @override
  State<BreedDetailHero> createState() => _BreedDetailHeroState();
}

class _BreedDetailHeroState extends State<BreedDetailHero> {
  /// Photo the gallery is showing. Its shape decides the shape of this area.
  GalleryPhoto? _photo;

  @override
  void initState() {
    super.initState();
    _photo = widget.photos.firstOrNull;
  }

  @override
  void didUpdateWidget(BreedDetailHero oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The gallery returns to the first photo when the list changes, so this area
    // follows it instead of keeping the shape of a photo that is gone.
    if (_photo == null || !widget.photos.contains(_photo)) {
      _photo = widget.photos.firstOrNull;
    }
  }

  void _onPhotoChanged(GalleryPhoto photo) {
    if (photo == _photo) return;
    setState(() => _photo = photo);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    final photoAspect = framedPhotoAspect(_photo);
    return LayoutBuilder(
      builder: (context, constraints) {
        // The area takes the width the layout offers and only leaves that shape
        // when the available height cannot hold it, so it never overflows the
        // column or the band the screen reserves.
        double heightFor(double aspect) =>
            math.min(constraints.maxWidth / aspect, constraints.maxHeight);
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: photoAspect),
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          builder: (context, aspect, child) => SizedBox(
            width: constraints.maxWidth,
            height: heightFor(aspect),
            child: child,
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                BreedGallery(
                  photos: widget.photos,
                  photoRequest: widget.photoRequest,
                  onRetry: widget.onRetryGallery,
                  label: widget.breed.name,
                  onPhotoChanged: _onPhotoChanged,
                ),
                Positioned(
                  top: responsive.spacing(12),
                  left: responsive.spacing(12),
                  child: OverlayCircleSurface(
                    key: const Key('detail-back'),
                    child: IconButton(
                      tooltip: strings.backToBreeds,
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                ),
                Positioned(
                  top: responsive.spacing(12),
                  right: responsive.spacing(12),
                  child: OverlayCircleSurface(
                    child: LanguageMenu(
                      selected: widget.selectedLanguage,
                      onSelected: widget.onLanguageSelected,
                    ),
                  ),
                ),
                Positioned(
                  right: responsive.spacing(12),
                  bottom: responsive.spacing(12),
                  child: _HeroLabel(
                    label: widget.breed.id.toUpperCase(),
                    background: Colors.black.withValues(alpha: 0.62),
                    foreground: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Short label on a translucent surface, used over the breed photo.
class _HeroLabel extends StatelessWidget {
  const _HeroLabel({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(responsive.radius(24)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.spacing(14),
          vertical: responsive.spacing(8),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.wp(45)),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: foreground,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
