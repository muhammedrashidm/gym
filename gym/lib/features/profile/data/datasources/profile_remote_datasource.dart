import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/auth_token_model.dart';
import '../models/trainer_connection_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<AuthTokenModel> trainerSignup({
    required String name,
    required String bio,
    required int experienceYears,
    required List<String> specializations,
    required List<PlatformFile> certificates,
  });

  Future<TrainerConnectionModel> connectToTrainer(String qrToken);
}

@Singleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  const ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<AuthTokenModel> trainerSignup({
    required String name,
    required String bio,
    required int experienceYears,
    required List<String> specializations,
    required List<PlatformFile> certificates,
  }) async {
    final Map<String, dynamic> data = {
      'name': name,
      'bio': bio,
      'experience': experienceYears,
      'specializations': specializations,
    };

    final List<MultipartFile> files = [];
    for (final file in certificates) {
      if (file.bytes != null) {
        files.add(MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        ));
      } else if (file.path != null) {
        files.add(await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ));
      }
    }
    data['certificates'] = files;

    final formData = FormData.fromMap(data);

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/trainer-signup',
      data: formData,
    );

    return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TrainerConnectionModel> connectToTrainer(String qrToken) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/connect-trainer',
      data: {
        'qrToken': qrToken,
      },
    );
    return TrainerConnectionModel.fromJson(response.data as Map<String, dynamic>);
  }
}
