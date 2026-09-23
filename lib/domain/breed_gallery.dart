import 'breed_photo.dart';

/// Images the detail gallery shows for a breed.
///
/// The breed's primary image comes first and is deduplicated against the
/// photo search, so it stays visible while the additional photo request is
/// pending or failed.
List<String> breedGalleryImageUrls({
  required String? primaryUrl,
  required List<BreedPhoto> photos,
}) {
  final primary = primaryUrl?.trim();
  return <String>{
    if (primary != null && primary.isNotEmpty) primary,
    for (final photo in photos) photo.url,
  }.toList();
}
