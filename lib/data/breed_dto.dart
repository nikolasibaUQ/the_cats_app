import 'package:json_annotation/json_annotation.dart';

import '../domain/breed.dart';
import '../domain/breed_flag.dart';
import 'url_value.dart';

part 'breed_dto.g.dart';

@JsonSerializable(createToJson: false)
class BreedDto {
  const BreedDto({
    required this.id,
    required this.name,
    this.altNames,
    this.description,
    this.origin,
    this.temperament,
    this.lifeSpan,
    this.weight,
    this.height,
    this.image,
    this.breedGroup,
    this.history,
    this.wikipediaUrl,
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
    this.indoor,
    this.lap,
    this.hypoallergenic,
    this.natural,
    this.rare,
    this.rex,
    this.hairless,
    this.shortLegs,
    this.suppressedTail,
    this.experimental,
  });

  factory BreedDto.fromJson(Map<String, dynamic> json) =>
      _$BreedDtoFromJson(json);

  final String id;
  final String name;
  @JsonKey(name: 'alt_names')
  final String? altNames;
  final String? description;
  final String? origin;
  final String? temperament;
  @JsonKey(name: 'life_span')
  final String? lifeSpan;
  final WeightDto? weight;
  final WeightDto? height;
  final ImageDto? image;
  @JsonKey(name: 'breed_group')
  final String? breedGroup;
  final String? history;
  @JsonKey(name: 'wikipedia_url')
  final String? wikipediaUrl;
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

  /// Binary traits. Most responses report `0` or `1`, and some report a
  /// boolean, so the raw value stays at this boundary and is interpreted here.
  final Object? indoor;
  final Object? lap;
  final Object? hypoallergenic;
  final Object? natural;
  final Object? rare;
  final Object? rex;
  final Object? hairless;
  @JsonKey(name: 'short_legs')
  final Object? shortLegs;
  @JsonKey(name: 'suppressed_tail')
  final Object? suppressedTail;
  final Object? experimental;

  Breed toDomain() {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw const FormatException('Breed identity is missing');
    }
    return Breed(
      id: id,
      name: name,
      description: _nonBlank(description),
      origin: _nonBlank(origin),
      temperament: _nonBlank(temperament),
      lifeSpan: _nonBlank(lifeSpan),
      imageUrl: absoluteUrl(image?.url),
      weightMetric: _nonBlank(weight?.metric),
      weightImperial: _nonBlank(weight?.imperial),
      heightMetric: _nonBlank(height?.metric),
      heightImperial: _nonBlank(height?.imperial),
      altNames: _nonBlank(altNames),
      breedGroup: _nonBlank(breedGroup),
      history: _nonBlank(history),
      wikipediaUrl: absoluteUrl(wikipediaUrl),
      adaptability: _rating(adaptability),
      affectionLevel: _rating(affectionLevel),
      childFriendly: _rating(childFriendly),
      dogFriendly: _rating(dogFriendly),
      energyLevel: _rating(energyLevel),
      grooming: _rating(grooming),
      healthIssues: _rating(healthIssues),
      intelligence: _rating(intelligence),
      sheddingLevel: _rating(sheddingLevel),
      socialNeeds: _rating(socialNeeds),
      strangerFriendly: _rating(strangerFriendly),
      vocalisation: _rating(vocalisation),
      flags: _flags(),
    );
  }

  /// Traits the API marked as present. Missing or unexpected values stay
  /// absent, so the UI never states a trait the response does not confirm.
  Set<BreedFlag> _flags() => {
    if (_isPresent(indoor)) BreedFlag.indoor,
    if (_isPresent(lap)) BreedFlag.lap,
    if (_isPresent(hypoallergenic)) BreedFlag.hypoallergenic,
    if (_isPresent(natural)) BreedFlag.natural,
    if (_isPresent(rare)) BreedFlag.rare,
    if (_isPresent(rex)) BreedFlag.rex,
    if (_isPresent(hairless)) BreedFlag.hairless,
    if (_isPresent(shortLegs)) BreedFlag.shortLegs,
    if (_isPresent(suppressedTail)) BreedFlag.suppressedTail,
    if (_isPresent(experimental)) BreedFlag.experimental,
  };
}

@JsonSerializable(createToJson: false)
class WeightDto {
  const WeightDto({this.metric, this.imperial});

  factory WeightDto.fromJson(Map<String, dynamic> json) =>
      _$WeightDtoFromJson(json);

  final String? metric;
  final String? imperial;
}

@JsonSerializable(createToJson: false)
class ImageDto {
  const ImageDto({this.url});

  factory ImageDto.fromJson(Map<String, dynamic> json) =>
      _$ImageDtoFromJson(json);

  final String? url;
}

String? _nonBlank(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// Interprets a binary API trait: `1`, `0`, or a boolean.
bool _isPresent(Object? value) => switch (value) {
  true => true,
  final int number => number == 1,
  final String text =>
    text.trim() == '1' || text.trim().toLowerCase() == 'true',
  _ => false,
};

int? _rating(int? value) =>
    value != null && value >= 1 && value <= 5 ? value : null;
