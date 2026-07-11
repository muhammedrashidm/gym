import 'package:freezed_annotation/freezed_annotation.dart';

part 'client_profile.freezed.dart';

@freezed
class ClientProfile with _$ClientProfile {
  const factory ClientProfile({
    required String id,
    required String phoneNumber,
    required String fullName,
    required bool isClaimed,
    required bool isActive,
    String? userId,
    int? age,
    String? sex,
    String? expLevel,
    String? avatarUrl,
    double? weight,
    double? height,
    double? muscleMass,
    double? bodyFatPct,
  }) = _ClientProfile;
}
