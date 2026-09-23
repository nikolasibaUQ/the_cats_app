import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/language_menu.dart';
import '../../../domain/entities/breed.dart';
import '../../../domain/entities/breed_photo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../../shared/widgets/overlay_circle_surface.dart';
import 'breed_gallery.dart';

/// Fixed photo area of the detail screen.
///
/// The gallery fills the area and the controls that belong to the screen float
/// above it: leaving the detail, the language selector, the origin, and the
/// breed code. The photo never scrolls; only the information below it does.
class BreedDetailHero extends StatelessWidget {
  const BreedDetailHero({
    super.key,
    required this.breed,
    required this.imageUrls,
    required this.photos,
    required this.onRetryGallery,
    required this.onBack,
    required this.borderRadius,
  });

  final Breed breed;
  final List<String> imageUrls;
  final AsyncValue<List<BreedPhoto>> photos;
  final VoidCallback onRetryGallery;
  final VoidCallback onBack;

  /// Rounded edges of the photo area. Detail that fills the top of a narrow
  /// screen rounds its bottom corners only.
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final responsive = Responsive.of(context);
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BreedGallery(
            imageUrls: imageUrls,
            photos: photos,
            onRetry: onRetryGallery,
            label: breed.name,
          ),
          Positioned(
            top: responsive.spacing(12),
            left: responsive.spacing(12),
            child: OverlayCircleSurface(
              key: const Key('detail-back'),
              child: IconButton(
                tooltip: strings.backToBreeds,
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
          Positioned(
            top: responsive.spacing(12),
            right: responsive.spacing(12),
            child: const OverlayCircleSurface(child: LanguageMenu()),
          ),
          Positioned(
            right: responsive.spacing(12),
            bottom: responsive.spacing(12),
            child: _HeroLabel(
              label: breed.id.toUpperCase(),
              background: Colors.black.withValues(alpha: 0.62),
              foreground: Colors.white,
            ),
          ),
        ],
      ),
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
