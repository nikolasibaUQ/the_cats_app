import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/breeds_dependencies.dart';
import '../domain/breed.dart';

part 'breeds_providers.g.dart';

@Riverpod(keepAlive: true)
Future<List<Breed>> breeds(Ref ref) =>
    ref.watch(breedsRepositoryProvider).getBreeds();
