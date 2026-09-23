import 'breed_flag.dart';

/// A cat breed as the application uses it.
///
/// Optional values are unknown when absent, which lets each screen decide what
/// to omit instead of rendering an empty placeholder for every API field.
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
    this.heightMetric,
    this.heightImperial,
    this.breedGroup,
    this.history,
    this.adaptability,
    this.affectionLevel,
    this.altNames,
    this.childFriendly,
    this.dogFriendly,
    this.energyLevel,
    this.flags = const <BreedFlag>{},
    this.grooming,
    this.healthIssues,
    this.intelligence,
    this.sheddingLevel,
    this.socialNeeds,
    this.strangerFriendly,
    this.vocalisation,
    this.weightImperial,
    this.wikipediaUrl,
  });

  final String id;
  final String name;
  final String? description;
  final String? origin;
  final String? temperament;
  final String? lifeSpan;
  final String? imageUrl;

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

  /// Comma-separated alternative names, as supplied by the API.
  final String? altNames;

  /// Wikipedia article for the breed, when the API supplies an absolute URL.
  final String? wikipediaUrl;

  /// Traits rated from 1 to 5. Absent means unknown, never zero.
  final int? adaptability;
  final int? affectionLevel;
  final int? childFriendly;
  final int? dogFriendly;
  final int? energyLevel;
  final int? grooming;
  final int? healthIssues;
  final int? intelligence;
  final int? sheddingLevel;
  final int? socialNeeds;
  final int? strangerFriendly;
  final int? vocalisation;

  /// Binary traits this breed has. Traits that do not apply stay absent.
  final Set<BreedFlag> flags;
}
