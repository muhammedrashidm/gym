import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_role.dart';

part 'session_state.freezed.dart';

@freezed
class SessionState with _$SessionState {
  const factory SessionState.initial() = SessionInitial;
  const factory SessionState.loaded({
    required List<UserRole> availableRoles,
    UserRole? activeRole,
  }) = SessionLoaded;
}
