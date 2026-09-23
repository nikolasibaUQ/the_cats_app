import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/breed_photo.dart';
import '../mappers/json_values.dart';

part 'breed_photo_dto.g.dart';

@JsonSerializable(createToJson: false)
class BreedPhotoDto {
  const BreedPhotoDto({
    required this.id,
    required this.url,
    this.width,
    this.height,
  });

  factory BreedPhotoDto.fromJson(Map<String, dynamic> json) =>
      _$BreedPhotoDtoFromJson(json);

  final String id;
  final String url;
  final int? width;
  final int? height;

  BreedPhoto toDomain() {
    final normalizedId = id.trim();
    final normalizedUrl = absoluteUrl(url);
    if (normalizedId.isEmpty || normalizedUrl == null) {
      throw const FormatException('Breed photo is invalid');
    }
    return BreedPhoto(
      id: normalizedId,
      url: normalizedUrl,
      width: positive(width),
      height: positive(height),
    );
  }
}
