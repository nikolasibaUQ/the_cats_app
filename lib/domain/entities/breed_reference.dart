/// Breed attributes supplied by the bundled reference dataset.
///
/// The free plan of The Cat API stopped returning the 1-to-5 ratings and the
/// binary traits, so the application ships `assets/breed_reference.json`, a
/// dataset captured from that same API before the change (see `docs/api.md`).
/// It is not a breed: it holds only the traits that fill the gaps of a [Breed]
/// the API already described. A breed the dataset does not cover simply has no
/// reference and renders no trait sections.
class BreedReference {
  const BreedReference({
    required this.energyLevel,
    required this.affectionLevel,
    required this.intelligence,
    required this.grooming,
    required this.socialNeeds,
    required this.hypoallergenic,
    required this.rare,
    required this.lap,
  });

  /// How much of a trait the breed shows, on the API's 1-to-5 scale.
  ///
  /// Ratings describe quantity of a trait, not quality: a 5 on energy means a
  /// very active breed, not a better one.
  final int energyLevel;
  final int affectionLevel;
  final int intelligence;
  final int grooming;
  final int socialNeeds;

  /// Binary traits, stated explicitly as true or false by the dataset.
  final bool hypoallergenic;
  final bool rare;
  final bool lap;
}
