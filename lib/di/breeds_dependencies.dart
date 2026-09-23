import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/repositories/breeds_repository_impl.dart';
import '../data/sources/breeds_remote_data_source.dart';
import '../domain/repositories/breeds_repository.dart';

part 'breeds_dependencies.g.dart';

/// Composition root of the breeds feature.
///
/// This is the only file that names the concrete Data implementation. Every
/// other layer depends on the `BreedsRepository` contract, so changing
/// transport or mapping never reaches presentation.
@riverpod
BreedsRepository breedsRepository(Ref ref) {
  final dataSource = DioBreedsRemoteDataSource();
  ref.onDispose(dataSource.close);
  return BreedsRepositoryImpl(remoteDataSource: dataSource);
}
