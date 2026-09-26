import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/breed_reference.dart';

part 'breed_reference_dto.g.dart';

/// One entry of the bundled reference dataset.
///
/// The keys match the API response the dataset was captured from, so entries
/// are interpreted with the same rules as a live payload. The trial dataset
/// maps five 1-to-5 ratings and three binary traits per breed; the remaining
/// historic fields are deliberately not modeled.
@JsonSerializable(createToJson: false)
class BreedReferenceDto {
  const BreedReferenceDto({
    required this.energyLevel,
    required this.affectionLevel,
    required this.intelligence,
    required this.grooming,
    required this.socialNeeds,
    required this.hypoallergenic,
    required this.rare,
    required this.lap,
  });

  factory BreedReferenceDto.fromJson(Map<String, dynamic> json) =>
      _$BreedReferenceDtoFromJson(json);

  @JsonKey(name: 'energy_level')
  final int energyLevel;
  @JsonKey(name: 'affection_level')
  final int affectionLevel;
  final int intelligence;
  final int grooming;
  @JsonKey(name: 'social_needs')
  final int socialNeeds;
  final bool hypoallergenic;
  final bool rare;
  final bool lap;

  BreedReference toDomain() => BreedReference(
    energyLevel: _rating(energyLevel),
    affectionLevel: _rating(affectionLevel),
    intelligence: _rating(intelligence),
    grooming: _rating(grooming),
    socialNeeds: _rating(socialNeeds),
    hypoallergenic: hypoallergenic,
    rare: rare,
    lap: lap,
  );
}

/// Keeps a rating on the API's 1-to-5 scale. The bundled asset is trusted, but
/// the boundary still normalizes an out-of-range value instead of letting the
/// UI draw a meaningless scale.
int _rating(int value) => value.clamp(1, 5);
