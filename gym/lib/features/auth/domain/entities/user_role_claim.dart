import 'package:freezed_annotation/freezed_annotation.dart';
part 'user_role_claim.freezed.dart';

@freezed
class UserRoleClaim with _$UserRoleClaim {
  const factory UserRoleClaim({
    required String roleId,
    required String roleName,
    String? gymId,
  }) = _UserRoleClaim;
}
