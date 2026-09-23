import '../entities/breed.dart';

/// Breeds whose name or API-provided origin contain [query].
///
/// Matching ignores case and surrounding spaces. An empty query keeps the whole
/// list. Callers decide when a query is long enough to apply.
List<Breed> searchBreeds(List<Breed> breeds, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return breeds;
  return breeds.where((breed) => _matches(breed, normalizedQuery)).toList();
}

bool _matches(Breed breed, String normalizedQuery) {
  final name = breed.name.toLowerCase();
  final origin = breed.origin?.toLowerCase();
  return name.contains(normalizedQuery) ||
      (origin?.contains(normalizedQuery) ?? false);
}
