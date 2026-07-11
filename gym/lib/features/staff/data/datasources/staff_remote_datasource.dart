import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../models/client_profile_model.dart';
import '../models/qr_token_model.dart';

abstract interface class StaffRemoteDataSource {
  Future<QrTokenModel> getQrToken();

  Future<List<ClientProfileModel>> listStaffClients();

  Future<ClientProfileModel> staffCreateProfile({
    required String phoneNumber,
    required String fullName,
    int? age,
    String? sex,
    String? expLevel,
    double? weight,
    double? height,
    double? muscleMass,
    double? bodyFatPct,
  });
}

@Singleton(as: StaffRemoteDataSource)
class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final ApiClient _apiClient;

  const StaffRemoteDataSourceImpl(this._apiClient);

  @override
  Future<QrTokenModel> getQrToken() async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/staff/qr-token',
    );
    return QrTokenModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<ClientProfileModel>> listStaffClients() async {
    final response = await _apiClient.get<List<dynamic>>(
      '/users/staff/clients',
    );
    return (response.data as List<dynamic>)
        .map((e) => ClientProfileModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ClientProfileModel> staffCreateProfile({
    required String phoneNumber,
    required String fullName,
    int? age,
    String? sex,
    String? expLevel,
    double? weight,
    double? height,
    double? muscleMass,
    double? bodyFatPct,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/users/manage/members',
      data: {
        'phoneNumber': phoneNumber,
        'fullName': fullName,
        if (age != null) 'age': age,
        if (sex != null) 'sex': sex,
        if (expLevel != null) 'expLevel': expLevel,
        if (weight != null) 'weight': weight,
        if (height != null) 'height': height,
        if (muscleMass != null) 'muscleMass': muscleMass,
        if (bodyFatPct != null) 'bodyFatPct': bodyFatPct,
      },
    );
    return ClientProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
