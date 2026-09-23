import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/breed_flag.dart';
import '../../domain/entities/breed_reference.dart';
import '../mappers/json_values.dart';

part 'breed_reference_dto.g.dart';

/// One entry of the bundled reference dataset.
///
/// The keys match the API response the dataset was captured from, so entries
/// are interpreted with the same rules as a live payload.
@JsonSerializable(createToJson: false)
class BreedReferenceDto {
  const BreedReferenceDto({
    this.adaptability,
    this.affectionLevel,
    this.childFriendly,
    this.dogFriendly,
    this.energyLevel,
    this.grooming,
    this.healthIssues,
    this.intelligence,
    this.sheddingLevel,
    this.socialNeeds,
    this.strangerFriendly,
    this.vocalisation,
    this.traits,
    this.altNames,
    this.wikipediaUrl,
  });

  factory BreedReferenceDto.fromJson(Map<String, dynamic> json) =>
      _$BreedReferenceDtoFromJson(json);

  final int? adaptability;
  @JsonKey(name: 'affection_level')
  final int? affectionLevel;
  @JsonKey(name: 'child_friendly')
  final int? childFriendly;
  @JsonKey(name: 'dog_friendly')
  final int? dogFriendly;
  @JsonKey(name: 'energy_level')
  final int? energyLevel;
  final int? grooming;
  @JsonKey(name: 'health_issues')
  final int? healthIssues;
  final int? intelligence;
  @JsonKey(name: 'shedding_level')
  final int? sheddingLevel;
  @JsonKey(name: 'social_needs')
  final int? socialNeeds;
  @JsonKey(name: 'stranger_friendly')
  final int? strangerFriendly;
  final int? vocalisation;

  /// Names of the binary traits the breed has, such as `hypoallergenic`.
  final List<String>? traits;

  @JsonKey(name: 'alt_names')
  final String? altNames;
  @JsonKey(name: 'wikipedia_url')
  final String? wikipediaUrl;

  BreedReference toDomain() => BreedReference(
    adaptability: rating(adaptability),
    affectionLevel: rating(affectionLevel),
    childFriendly: rating(childFriendly),
    dogFriendly: rating(dogFriendly),
    energyLevel: rating(energyLevel),
    grooming: rating(grooming),
    healthIssues: rating(healthIssues),
    intelligence: rating(intelligence),
    sheddingLevel: rating(sheddingLevel),
    socialNeeds: rating(socialNeeds),
    strangerFriendly: rating(strangerFriendly),
    vocalisation: rating(vocalisation),
    flags: _flags(traits),
    altNames: nonBlank(altNames),
    wikipediaUrl: absoluteUrl(wikipediaUrl),
  );
}

/// Trait names that match the application enum. An unknown name is ignored so
/// a newer dataset cannot break a build that predates it.
Set<BreedFlag> _flags(List<String>? names) => {
  for (final name in names ?? const <String>[])
    for (final flag in BreedFlag.values)
      if (flag.name == name) flag,
};
