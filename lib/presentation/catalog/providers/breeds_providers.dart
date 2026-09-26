import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../di/breeds_dependencies.dart';
import '../../../domain/entities/breed.dart';
import '../../../domain/entities/breed_reference.dart';

part 'breeds_providers.g.dart';

@Riverpod(keepAlive: true)
Future<List<Breed>> breeds(Ref ref) =>
    ref.watch(breedsRepositoryProvider).getBreeds();

/// Traits every breed of the bundled reference dataset supplies.
///
/// The dataset is read once per run, so keeping this alive reuses the same
/// cache for every detail screen that asks for a reference.
@Riverpod(keepAlive: true)
Future<Map<String, BreedReference>> breedReferences(Ref ref) =>
    ref.watch(breedsRepositoryProvider).getBreedReferences();
