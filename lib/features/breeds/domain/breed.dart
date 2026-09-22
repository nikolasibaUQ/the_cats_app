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
    this.affectionLevel,
    this.energyLevel,
    this.grooming,
    this.intelligence,
  });

  final String id;
  final String name;
  final String? description;
  final String? origin;
  final String? temperament;
  final String? lifeSpan;
  final String? weightMetric;
  final String? imageUrl;
  final int? affectionLevel;
  final int? energyLevel;
  final int? grooming;
  final int? intelligence;
}
