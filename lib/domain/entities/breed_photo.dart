class BreedPhoto {
  const BreedPhoto({
    required this.id,
    required this.url,
    this.width,
    this.height,
  });

  final String id;
  final String url;
  final int? width;
  final int? height;
}
