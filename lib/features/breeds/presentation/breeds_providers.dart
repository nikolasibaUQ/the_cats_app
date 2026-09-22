import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/remote_breeds_repository.dart';
import '../domain/breed.dart';
import '../domain/breeds_repository.dart';

part 'breeds_providers.g.dart';

@riverpod
BreedsRepository breedsRepository(Ref ref) {
  final repository = RemoteBreedsRepository();
  ref.onDispose(repository.close);
  return repository;
}

@Riverpod(keepAlive: true)
Future<List<Breed>> breeds(Ref ref) =>
    ref.watch(breedsRepositoryProvider).getBreeds();
