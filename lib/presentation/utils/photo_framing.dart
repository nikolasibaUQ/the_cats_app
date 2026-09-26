import '../../domain/policies/breed_gallery.dart';

/// Shape of a photo area when the API does not state the photo size.
const double defaultPhotoAspect = 4 / 3;

/// Narrowest frame a photo may shape for itself. The live breed list mixes
/// portrait and landscape files, and a frame outside this band would resize the
/// area far more than the photo needs while swiping.
const double minPhotoAspect = 3 / 4;

/// Widest frame a photo may shape for itself.
const double maxPhotoAspect = 3 / 2;

/// Proportion of the frame that shows [photo].
///
/// The photo keeps its own shape, kept inside [minPhotoAspect]..[maxPhotoAspect]
/// so an area framed by it stays within calm bounds: at the median of the live
/// breed list (1.43) that removes the zoom `BoxFit.cover` needs to fill a fixed
/// rectangle, and it crops at most 22% of the extreme files instead of over
/// half of them. A photo whose size the API does not state keeps
/// [defaultPhotoAspect].
double framedPhotoAspect(GalleryPhoto? photo) {
  final width = photo?.width;
  final height = photo?.height;
  if (width == null || height == null || width <= 0 || height <= 0) {
    return defaultPhotoAspect;
  }
  return (width / height).clamp(minPhotoAspect, maxPhotoAspect);
}
