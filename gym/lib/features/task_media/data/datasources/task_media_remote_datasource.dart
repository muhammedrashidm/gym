import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/task_media_model.dart';

abstract interface class TaskMediaRemoteDataSource {
  Future<({List<TaskMediaModel> items, int total, int page, int pageSize})> search({
    String? search,
    bool? mine,
    int page,
    int pageSize,
  });

  Future<TaskMediaModel> create({
    required PlatformFile file,
    required String name,
    String? description,
    List<String>? keywords,
    bool isPrivate,
  });
}

@Singleton(as: TaskMediaRemoteDataSource)
class TaskMediaRemoteDataSourceImpl implements TaskMediaRemoteDataSource {
  final ApiClient _apiClient;

  const TaskMediaRemoteDataSourceImpl(this._apiClient);

  @override
  Future<({List<TaskMediaModel> items, int total, int page, int pageSize})> search({
    String? search,
    bool? mine,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/task-media',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (mine != null) 'mine': mine,
        'page': page,
        'pageSize': pageSize,
      },
    );
    final data = response.data!;
    final items = (data['data'] as List<dynamic>? ?? [])
        .map((j) => TaskMediaModel.fromJson(j as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    return (
      items: items,
      total: meta['total'] as int? ?? items.length,
      page: meta['page'] as int? ?? page,
      pageSize: meta['pageSize'] as int? ?? pageSize,
    );
  }

  @override
  Future<TaskMediaModel> create({
    required PlatformFile file,
    required String name,
    String? description,
    List<String>? keywords,
    bool isPrivate = false,
  }) async {
    final MultipartFile multipart;
    if (file.bytes != null) {
      multipart = MultipartFile.fromBytes(file.bytes!, filename: file.name);
    } else if (file.path != null) {
      multipart = await MultipartFile.fromFile(file.path!, filename: file.name);
    } else {
      throw ArgumentError('Picked file has neither bytes nor a path.');
    }

    final formData = FormData.fromMap({
      'file': multipart,
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
      if (keywords != null && keywords.isNotEmpty) 'keywords': keywords.join(','),
      'isPrivate': isPrivate ? 'true' : 'false',
    });

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/task-media',
      data: formData,
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return TaskMediaModel.fromJson(data);
  }
}
