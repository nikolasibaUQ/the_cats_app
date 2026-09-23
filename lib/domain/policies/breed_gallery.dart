import '../entities/breed_photo.dart';

/// Photo the detail gallery shows, with the pixel size the API reports for it.
///
/// The size is optional because a response may omit it; the photo area then
/// falls back to its default shape instead of guessing one.
typedef GalleryPhoto = ({String url, int? width, int? height});

/// Photos the detail gallery shows for a breed.
///
/// The breed's primary photo comes first and is deduplicated against the photo
/// search, so it stays visible while the additional photo request is pending or
/// failed. When both sources describe the same URL, the primary entry wins: it
/// is the photo the catalog already shows for the breed.
List<GalleryPhoto> mergeGalleryPhotos({
  required GalleryPhoto? primary,
  required List<BreedPhoto> photos,
}) {
  final entries = <String, GalleryPhoto>{};
  final primaryUrl = primary?.url.trim();
  if (primary != null && primaryUrl != null && primaryUrl.isNotEmpty) {
    entries[primaryUrl] = (
      url: primaryUrl,
      width: primary.width,
      height: primary.height,
    );
  }
  for (final photo in photos) {
    entries.putIfAbsent(
      photo.url,
      () => (url: photo.url, width: photo.width, height: photo.height),
    );
  }
  return entries.values.toList();
}
