import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/client_profile.dart';

part 'client_profile_model.g.dart';

@JsonSerializable()
class ClientProfileModel {
  final String id;
  final String phoneNumber;
  final String fullName;
  final bool isClaimed;
  final bool isActive;
  final String? userId;
  final int? age;
  final String? sex;
  final String? expLevel;
  final String? avatarUrl;
  final List<BodyMetricsModel> bodyMetrics;

  const ClientProfileModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.isClaimed,
    required this.isActive,
    this.userId,
    this.age,
    this.sex,
    this.expLevel,
    this.avatarUrl,
    this.bodyMetrics = const [],
  });

  factory ClientProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ClientProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClientProfileModelToJson(this);

  ClientProfile toDomain() {
    BodyMetricsModel? latestMetric;
    if (bodyMetrics.isNotEmpty) {
      latestMetric = bodyMetrics.first;
    }

    return ClientProfile(
      id: id,
      phoneNumber: phoneNumber,
      fullName: fullName,
      isClaimed: isClaimed,
      isActive: isActive,
      userId: userId,
      age: age,
      sex: sex,
      expLevel: expLevel,
      avatarUrl: avatarUrl,
      weight: latestMetric?.weight.toDouble(),
      height: latestMetric?.height.toDouble(),
      muscleMass: latestMetric?.muscleMass?.toDouble(),
      bodyFatPct: latestMetric?.bodyFatPct?.toDouble(),
    );
  }
}

@JsonSerializable()
class BodyMetricsModel {
  final String id;
  final num weight;
  final num height;
  final num? muscleMass;
  final num? bodyFatPct;

  const BodyMetricsModel({
    required this.id,
    required this.weight,
    required this.height,
    this.muscleMass,
    this.bodyFatPct,
  });

  factory BodyMetricsModel.fromJson(Map<String, dynamic> json) =>
      _$BodyMetricsModelFromJson(json);

  Map<String, dynamic> toJson() => _$BodyMetricsModelToJson(this);
}
