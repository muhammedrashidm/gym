import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/exercise_config_model.dart';

abstract interface class ExerciseConfigRemoteDataSource {
  Future<({List<ExerciseConfigModel> items, int total, int page, int pageSize})> search({
    String? search,
    String? analyzerType,
    int page,
    int pageSize,
  });
}

@Singleton(as: ExerciseConfigRemoteDataSource)
class ExerciseConfigRemoteDataSourceImpl implements ExerciseConfigRemoteDataSource {
  final ApiClient _apiClient;

  const ExerciseConfigRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<ExerciseConfigModel> items, int total, int page, int pageSize})> search({
    String? search,
    String? analyzerType,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/exercise-configs',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (analyzerType != null && analyzerType.isNotEmpty) 'analyzerType': analyzerType,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = response.data!;
    final items = (data['data'] as List<dynamic>? ?? [])
        .map((j) => ExerciseConfigModel.fromJson(j as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    return (
      items: items,
      total: meta['total'] as int? ?? items.length,
      page: meta['page'] as int? ?? page,
      pageSize: meta['pageSize'] as int? ?? pageSize,
    );
  }
}
