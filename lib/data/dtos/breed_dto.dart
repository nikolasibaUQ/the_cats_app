import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/breed.dart';
import '../mappers/json_values.dart';

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
    this.height,
    this.image,
    this.breedGroup,
    this.history,
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
  final WeightDto? height;
  final ImageDto? image;
  @JsonKey(name: 'breed_group')
  final String? breedGroup;
  final String? history;

  Breed toDomain() {
    if (id.trim().isEmpty || name.trim().isEmpty) {
      throw const FormatException('Breed identity is missing');
    }
    return Breed(
      id: id,
      name: name,
      description: nonBlank(description),
      origin: nonBlank(origin),
      temperament: nonBlank(temperament),
      lifeSpan: nonBlank(lifeSpan),
      imageUrl: absoluteUrl(image?.url),
      imageWidth: positive(image?.width),
      imageHeight: positive(image?.height),
      weightMetric: nonBlank(weight?.metric),
      weightImperial: nonBlank(weight?.imperial),
      heightMetric: nonBlank(height?.metric),
      heightImperial: nonBlank(height?.imperial),
      breedGroup: nonBlank(breedGroup),
      history: nonBlank(history),
    );
  }
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
  const ImageDto({this.url, this.width, this.height});

  factory ImageDto.fromJson(Map<String, dynamic> json) =>
      _$ImageDtoFromJson(json);

  final String? url;

  /// Pixel size the API reports for the primary photo of the breed.
  final int? width;
  final int? height;
}
