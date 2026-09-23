import 'breed.dart';
import 'breed_flag.dart';

/// Breed attributes that a bundled reference dataset can supply.
///
/// The live API stopped returning the 1-to-5 ratings, the binary traits, and
/// the article link on the free plan, so the app ships a dataset captured from
/// that same API. It is not a breed: it holds only the attributes that fill the
/// gaps of a [Breed] the API already described.
class BreedReference {
  const BreedReference({
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
    this.flags = const <BreedFlag>{},
    this.altNames,
    this.wikipediaUrl,
  });

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

  final Set<BreedFlag> flags;
  final String? altNames;
  final String? wikipediaUrl;
}

/// Adds the attributes a reference entry can supply to this breed.
///
/// The API is always the first source: every value it already carries is kept
/// untouched, so a payload with its own ratings, traits, or article link never
/// loses them. The reference only answers for what the breed is missing.
extension BreedReferenceFill on Breed {
  Breed fillFrom(BreedReference? reference) {
    if (reference == null) return this;
    return Breed(
      id: id,
      name: name,
      description: description,
      origin: origin,
      temperament: temperament,
      lifeSpan: lifeSpan,
      weightMetric: weightMetric,
      weightImperial: weightImperial,
      heightMetric: heightMetric,
      heightImperial: heightImperial,
      breedGroup: breedGroup,
      history: history,
      imageUrl: imageUrl,
      altNames: altNames ?? reference.altNames,
      wikipediaUrl: wikipediaUrl ?? reference.wikipediaUrl,
      adaptability: adaptability ?? reference.adaptability,
      affectionLevel: affectionLevel ?? reference.affectionLevel,
      childFriendly: childFriendly ?? reference.childFriendly,
      dogFriendly: dogFriendly ?? reference.dogFriendly,
      energyLevel: energyLevel ?? reference.energyLevel,
      grooming: grooming ?? reference.grooming,
      healthIssues: healthIssues ?? reference.healthIssues,
      intelligence: intelligence ?? reference.intelligence,
      sheddingLevel: sheddingLevel ?? reference.sheddingLevel,
      socialNeeds: socialNeeds ?? reference.socialNeeds,
      strangerFriendly: strangerFriendly ?? reference.strangerFriendly,
      vocalisation: vocalisation ?? reference.vocalisation,
      flags: flags.isNotEmpty ? flags : reference.flags,
    );
  }
}
