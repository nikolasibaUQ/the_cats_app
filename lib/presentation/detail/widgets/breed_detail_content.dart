import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/breed.dart';
import '../../../domain/entities/breed_photo.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/responsive.dart';
import '../../breed_formatting.dart';
import 'breed_detail_hero.dart';
import 'breed_information.dart';
import 'external_link_panel.dart';
import 'related_breeds_section.dart';

/// Lays out the fixed photo area and the scrolling breed information.
///
/// Nothing is loaded or mapped here: the breed, its gallery, and the suggested
/// breeds arrive resolved, and every action is reported back to the screen.
class BreedDetailContent extends StatelessWidget {
  const BreedDetailContent({
    super.key,
    required this.breed,
    required this.imageUrls,
    required this.photos,
    required this.relatedBreeds,
    required this.onRetryGallery,
    required this.onBreedSelected,
    required this.onShowAllBreeds,
    required this.onBack,
  });

  final Breed breed;
  final List<String> imageUrls;
  final AsyncValue<List<BreedPhoto>> photos;
  final List<Breed> relatedBreeds;
  final VoidCallback onRetryGallery;
  final ValueChanged<Breed> onBreedSelected;
  final VoidCallback onShowAllBreeds;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    final sections = <Widget>[
      BreedInformation(breed: breed),
      RelatedBreedsSection(
        breeds: relatedBreeds,
        onBreedSelected: onBreedSelected,
        onShowAll: onShowAllBreeds,
      ),
      SizedBox(height: responsive.spacing(28)),
      ExternalLinkPanel(
        title: strings.wikipediaTitle,
        url: breedArticleUrl(breed),
      ),
    ];
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final hero = BreedDetailHero(
                breed: breed,
                imageUrls: imageUrls,
                photos: photos,
                onRetryGallery: onRetryGallery,
                onBack: onBack,
                borderRadius: narrow
                    ? BorderRadius.vertical(
                        bottom: Radius.circular(responsive.radius(24)),
                      )
                    : BorderRadius.circular(responsive.radius(24)),
              );
              final information = ListView(
                key: const Key('breed-information-scroll'),
                padding: EdgeInsets.only(bottom: responsive.spacing(40)),
                children: sections,
              );
              if (narrow) {
                final photoHeight = math.min(
                  360.0,
                  math.max(160.0, constraints.maxHeight * 0.42),
                );
                return Column(
                  children: [
                    SizedBox(height: photoHeight, child: hero),
                    SizedBox(height: responsive.spacing(20)),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.pagePadding,
                        ),
                        child: information,
                      ),
                    ),
                  ],
                );
              }
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.pagePadding,
                  vertical: responsive.spacing(20),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: hero),
                    SizedBox(width: responsive.spacing(32)),
                    Expanded(flex: 6, child: information),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
