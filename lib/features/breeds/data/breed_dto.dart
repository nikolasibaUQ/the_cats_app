import 'package:json_annotation/json_annotation.dart';

import '../domain/breed.dart';

part 'breed_dto.g.dart';

@JsonSerializable(createToJson: false)
class BreedDto {
  const BreedDto({
    required this.id,
    required this.name,
    this.description,
    this.origin,
    this.temperament,
    this.lifeSpan,
    this.weight,
    this.image,
    this.affectionLevel,
    this.energyLevel,
    this.grooming,
    this.intelligence,
  });

  factory BreedDto.fromJson(Map<String, dynamic> json) =>
      _$BreedDtoFromJson(json);

  final String id;
  final String name;
  final String? description;
  final String? origin;
  final String? temperament;
  @JsonKey(name: 'life_span')
  final String? lifeSpan;
  final WeightDto? weight;
  final ImageDto? image;
  @JsonKey(name: 'affection_level')
  final int? affectionLevel;
  @JsonKey(name: 'energy_level')
  final int? energyLevel;
  final int? grooming;
  final int? intelligence;

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
      weightMetric: _nonBlank(weight?.metric),
      imageUrl: _nonBlank(image?.url),
      affectionLevel: _rating(affectionLevel),
      energyLevel: _rating(energyLevel),
      grooming: _rating(grooming),
      intelligence: _rating(intelligence),
    );
  }
}

@JsonSerializable(createToJson: false)
class WeightDto {
  const WeightDto({this.metric});

  factory WeightDto.fromJson(Map<String, dynamic> json) =>
      _$WeightDtoFromJson(json);

  final String? metric;
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

int? _rating(int? value) =>
    value != null && value >= 1 && value <= 5 ? value : null;
