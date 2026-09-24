/// A cat breed as the application uses it.
///
/// It carries the fields the free-plan response supplies. Fields the plan
/// never returns (ratings, alternative names, article links) are not mapped,
/// so no code carries values that can never arrive.
class Breed {
  const Breed({
    required this.id,
    required this.name,
    this.description,
    this.origin,
    this.temperament,
    this.lifeSpan,
    this.weightMetric,
    this.imageUrl,
    this.imageWidth,
    this.imageHeight,
    this.heightMetric,
    this.heightImperial,
    this.breedGroup,
    this.history,
    this.weightImperial,
  });

  final String id;
  final String name;
  final String? description;
  final String? origin;
  final String? temperament;
  final String? lifeSpan;
  final String? imageUrl;

  /// Pixel size the API reports for [imageUrl], when it states one. The detail
  /// photo area uses it to adopt the shape of the photo instead of scaling it
  /// into a frame of a different proportion.
  final int? imageWidth;
  final int? imageHeight;

  /// Weight ranges exactly as the API states them, one per measurement system.
  final String? weightMetric;
  final String? weightImperial;

  /// Height ranges, stated in the same two systems as the weight.
  final String? heightMetric;
  final String? heightImperial;

  /// Category the API assigns to the breed, such as a coat group.
  final String? breedGroup;

  /// Origin story of the breed, when the API explains it.
  final String? history;
}
