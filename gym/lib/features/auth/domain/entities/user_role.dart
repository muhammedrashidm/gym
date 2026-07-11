import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_role.freezed.dart';
part 'user_role.g.dart';

enum Role {
  member(1),
  staff(2),
  admin(3),
  owner(4);

  final int id;
  const Role(this.id);

  static Role? fromId(int id) {
    for (final role in values) {
      if (role.id == id) return role;
    }
    return null;
  }
}

@freezed
class UserRole with _$UserRole {
  const factory UserRole({
    required int roleId,
    required String roleName,
    String? gymId,
    /// JWT claim: true if this role is the server-designated active role for
    /// this session. Used to auto-select the active role on login.
    @Default(false) bool isCurrent,
  }) = _UserRole;

  factory UserRole.fromJson(Map<String, dynamic> json) =>
      _$UserRoleFromJson(json);
}

extension UserRoleX on UserRole {
  Role? get roleEnum => Role.fromId(roleId);
}
