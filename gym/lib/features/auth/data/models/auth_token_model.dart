import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth_token.dart';

// ignore_for_file: invalid_annotation_target

part 'auth_token_model.freezed.dart';
part 'auth_token_model.g.dart';

@freezed
class AuthTokenModel with _$AuthTokenModel {
  const factory AuthTokenModel({
    @JsonKey(name: 'accessToken') required String accessToken,
    @JsonKey(name: 'refreshToken') required String refreshToken,
  }) = _AuthTokenModel;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  const AuthTokenModel._();

  AuthToken toDomain() => AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
}
