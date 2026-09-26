import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_locale_controller.dart';
import '../../../domain/entities/breed.dart';
import '../../../domain/entities/breed_photo.dart';
import '../../../domain/entities/breed_reference.dart';
import '../../../domain/policies/breed_gallery.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/utils/responsive.dart';
import '../../utils/breed_formatting.dart';
import 'breed_detail_hero.dart';
import 'breed_information.dart';
import 'detail_navigation_bar.dart';
import 'external_link_panel.dart';
import 'related_breeds_section.dart';

/// Lays out the photo area and the scrolling breed information.
///
/// It decides how much room the photo area gets: the whole column beside the
/// information on wide layouts, a bounded band above it on narrow ones. The area
/// itself takes the shape of the photo it shows. Nothing is loaded or mapped
/// here: the breed, its gallery, and the suggested breeds arrive resolved, and
/// every action is reported back to the screen.
class BreedDetailContent extends StatelessWidget {
  const BreedDetailContent({
    super.key,
    required this.breed,
    required this.photos,
    required this.photoRequest,
    required this.relatedBreeds,
    required this.references,
    required this.breedReference,
    required this.onRetryGallery,
    required this.onBreedSelected,
    required this.onShowAllBreeds,
    required this.onBack,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  final Breed breed;
  final List<GalleryPhoto> photos;
  final AsyncValue<List<BreedPhoto>> photoRequest;
  final List<Breed> relatedBreeds;

  /// Traits of the bundled dataset per breed ID, feeding the suggestion cards.
  final Map<String, BreedReference> references;
  final BreedReference? breedReference;
  final VoidCallback onRetryGallery;
  final ValueChanged<Breed> onBreedSelected;
  final VoidCallback onShowAllBreeds;
  final VoidCallback onBack;
  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onLanguageSelected;

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final strings = AppLocalizations.of(context)!;
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              final detailSections = <Widget>[
                BreedInformation(
                  breed: breed,
                  showName: !narrow,
                  reference: breedReference,
                ),
                RelatedBreedsSection(
                  breeds: relatedBreeds,
                  references: references,
                  onBreedSelected: onBreedSelected,
                  onShowAll: onShowAllBreeds,
                ),
                SizedBox(height: responsive.spacing(28)),
                ExternalLinkPanel(
                  title: strings.wikipediaTitle,
                  url: breedArticleSearchUrl(breed),
                ),
              ];
              final hero = BreedDetailHero(
                breed: breed,
                photos: photos,
                photoRequest: photoRequest,
                onRetryGallery: onRetryGallery,
                borderRadius: narrow
                    ? BorderRadius.vertical(
                        bottom: Radius.circular(responsive.radius(24)),
                      )
                    : BorderRadius.circular(responsive.radius(24)),
              );
              final information = ListView(
                key: const Key('breed-information-scroll'),
                padding: EdgeInsets.only(bottom: responsive.spacing(40)),
                children: detailSections,
              );
              if (narrow) {
                // The band bounds how tall the photo area may grow: a portrait
                // photo keeps its shape up to this height instead of pushing the
                // information off the screen.
                final photoBand = math.min(
                  360.0,
                  math.max(160.0, constraints.maxHeight * 0.42),
                );
                return Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: photoBand),
                      child: hero,
                    ),
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
                child: Column(
                  children: [
                    DetailNavigationBar(
                      selectedLanguage: selectedLanguage,
                      onLanguageSelected: onLanguageSelected,
                      onBack: onBack,
                    ),
                    SizedBox(height: responsive.spacing(12)),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // The area keeps the photo's shape while the column
                          // beside it stays as tall as the information it holds.
                          Expanded(
                            flex: 5,
                            child: Align(
                              alignment: Alignment.center,
                              child: hero,
                            ),
                          ),
                          SizedBox(width: responsive.spacing(32)),
                          Expanded(flex: 6, child: information),
                        ],
                      ),
                    ),
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
