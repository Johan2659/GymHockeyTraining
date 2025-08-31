import '../../core/repositories/extras_repository.dart';
import '../../core/models/models.dart';
import '../datasources/local_extras_source.dart';

/// Implementation of ExtrasRepository using local data source
class ExtrasRepositoryImpl implements ExtrasRepository {
  const ExtrasRepositoryImpl({
    required this.localSource,
  });

  final LocalExtrasSource localSource;

  @override
  Future<List<ExtraItem>> getAll() async {
    return localSource.getAllExtras();
  }

  @override
  Future<List<ExtraItem>> getByType(ExtraType type) async {
    return localSource.getExtrasByType(type);
  }

  @override
  Future<ExtraItem?> getById(String id) async {
    return localSource.getExtraById(id);
  }
}
