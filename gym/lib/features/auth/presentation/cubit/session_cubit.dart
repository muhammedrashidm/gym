import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/user_role.dart';
import 'auth_cubit.dart';
import 'auth_state.dart';
import 'session_state.dart';

@singleton
class SessionCubit extends Cubit<SessionState> {
  final AuthCubit _authCubit;
  late final StreamSubscription<AuthState> _authSubscription;

  SessionCubit(this._authCubit) : super(const SessionState.initial()) {
    // React to existing auth state immediately
    _handleAuthState(_authCubit.state);

    // Listen to future changes
    _authSubscription = _authCubit.stream.listen(_handleAuthState);
  }

  void _handleAuthState(AuthState authState) {
    if (authState is AuthAuthenticated) {
      final token = authState.token.accessToken;
      if (JwtDecoder.isExpired(token)) {
        emit(const SessionState.initial());
        return;
      }

      final payload = JwtDecoder.decode(token);
      final rawRoles = payload['roles'] as List<dynamic>? ?? [];
      
      final List<UserRole> availableRoles = rawRoles
          .map((r) => UserRole.fromJson(r as Map<String, dynamic>))
          .toList();

      UserRole? activeRole;
      if (availableRoles.length == 1) {
        activeRole = availableRoles.first;
      }

      emit(SessionState.loaded(
        availableRoles: availableRoles,
        activeRole: activeRole,
      ));
    } else if (authState is AuthUnauthenticated || authState is AuthError) {
      emit(const SessionState.initial());
    }
  }

  void selectWorkspace(UserRole role) {
    if (state is SessionLoaded) {
      final loadedState = state as SessionLoaded;
      emit(loadedState.copyWith(activeRole: role));
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
