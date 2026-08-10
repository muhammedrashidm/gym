import 'dart:async';

import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/token_refresh_result.dart';
import '../../../../core/network/token_refresh_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/preferences_storage.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/usecases/logout_command.dart';
import '../../domain/usecases/send_otp_command.dart';
import '../../domain/usecases/verify_otp_command.dart';
import 'auth_state.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  final Mediator _mediator;
  final SecureStorage _secureStorage;
  final PreferencesStorage _preferencesStorage;
  final TokenRefreshService _tokenRefreshService;

  AuthCubit(
    this._mediator,
    this._secureStorage,
    this._preferencesStorage,
    this._tokenRefreshService,
  ) : super(const AuthState.initial());

  // ──────────────────────────────────────────────────────────────
  // Startup
  // ──────────────────────────────────────────────────────────────

  /// Called from [SplashPage] on app startup.
  ///
  /// Trusts local storage optimistically: if a token pair exists, the user
  /// is treated as authenticated immediately, regardless of whether the
  /// access token has locally expired. A forced logout only ever happens
  /// when the server explicitly rejects a refresh attempt (see
  /// [_proactiveRefresh], [forceLogout], and [AuthInterceptor]) — never from
  /// an offline expiry check on app start.
  Future<void> loadAuthState() async {
    emit(const AuthState.checkingToken());

    final token = await _secureStorage.getAccessToken();
    if (token == null) {
      emit(const AuthState.unauthenticated());
      return;
    }

    final refresh = await _secureStorage.getRefreshToken();
    final authToken = AuthToken(
      accessToken: token,
      refreshToken: refresh ?? '',
    );

    emit(_buildAuthenticatedState(authToken));

    // Latency optimization only: if the access token is already expired,
    // warm up a new one in the background so the first real request doesn't
    // have to eat a guaranteed 401 -> refresh -> retry round trip. A network
    // failure here must not affect the (already emitted) authenticated state.
    if (JwtDecoder.isExpired(token)) {
      unawaited(_proactiveRefresh());
    }
  }

  Future<void> _proactiveRefresh() async {
    final result = await _tokenRefreshService.refresh();
    switch (result) {
      case RefreshSuccess(:final token):
        // Guard against a race with an interceptor-driven forced logout that
        // may have already resolved while this was in flight.
        if (state is AuthAuthenticated) {
          await updateTokens(token);
        }
      case RefreshRejected():
        await forceLogout();
      case RefreshTransientFailure():
        // Offline / server unreachable — stay authenticated and let the next
        // real API call's interceptor retry the refresh.
        break;
    }
  }

  // ──────────────────────────────────────────────────────────────
  // OTP Flow
  // ──────────────────────────────────────────────────────────────

  Future<void> sendOtp({required String phoneNumber}) async {
    emit(const AuthState.loading());

    final result = await _mediator
        .sendCommand(SendOtpCommand(phoneNumber: phoneNumber))
    as Either<Failure, String?>;

    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (code) => emit(
        AuthState.otpSent(phoneNumber: phoneNumber, debugCode: code),
      ),
    );
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    emit(const AuthState.loading());

    final result = await _mediator
        .sendCommand(VerifyOtpCommand(phoneNumber: phoneNumber, otp: otp))
    as Either<Failure, AuthToken>;

    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (token) async {
        await _secureStorage.saveAccessToken(token.accessToken);
        await _secureStorage.saveRefreshToken(token.refreshToken);
        emit(_buildAuthenticatedState(token));
      },
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Role Management
  // ──────────────────────────────────────────────────────────────

  /// Switches the active role for this session and persists the choice so it
  /// survives an app restart.
  void selectRole(UserRole role) {
    final current = state;
    if (current is! AuthAuthenticated) return;
    _preferencesStorage.setActiveRoleId(role.roleId);
    emit(current.copyWith(activeRole: role));
  }

  // ──────────────────────────────────────────────────────────────
  // Token Refresh / Trainer Upgrade
  // ──────────────────────────────────────────────────────────────

  /// Called after receiving a fresh token pair (e.g., post trainer-signup).
  /// Re-decodes the JWT to pick up any new roles and emits a new
  /// [AuthAuthenticated] state. The router will react and redirect accordingly.
  Future<void> updateTokens(AuthToken token) async {
    await _secureStorage.saveAccessToken(token.accessToken);
    await _secureStorage.saveRefreshToken(token.refreshToken);
    emit(_buildAuthenticatedState(token));
  }

  // ──────────────────────────────────────────────────────────────
  // Logout
  // ──────────────────────────────────────────────────────────────

  /// User-initiated logout. Best-effort revokes the refresh token
  /// server-side, but always clears local state even if that call fails
  /// (e.g. offline) so the user can still log out.
  Future<void> logout() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken != null) {
      await _mediator.sendCommand(LogoutCommand(refreshToken: refreshToken));
    }
    await _secureStorage.clearTokens();
    await _preferencesStorage.clearActiveRoleId();
    emit(const AuthState.unauthenticated());
  }

  /// The one path that forcibly ends a session without user action: the
  /// server explicitly rejected a refresh attempt (called from
  /// [AuthInterceptor] on a 401 whose refresh also fails, and from
  /// [_proactiveRefresh]). No server call — the refresh token is already
  /// known dead. Idempotent so repeated calls (e.g. from a batch of queued
  /// failed requests) are cheap no-ops.
  Future<void> forceLogout() async {
    if (state is AuthUnauthenticated) return;
    await _secureStorage.clearTokens();
    await _preferencesStorage.clearActiveRoleId();
    emit(const AuthState.unauthenticated(sessionExpired: true));
  }

  // ──────────────────────────────────────────────────────────────
  // Private Helpers
  // ──────────────────────────────────────────────────────────────

  /// Decodes [token], maps the `roles` JWT claim to [UserRole] objects, and
  /// picks the [activeRole]:
  ///   1. Persisted preference from a previous session or explicit selection
  ///   2. Member role  — the default workspace for all new / first-login users
  ///   3. [UserRole.isCurrent] == true  — server suggestion (pure staff accounts)
  ///   4. First role in the list as an absolute fallback
  AuthState _buildAuthenticatedState(AuthToken token) {
    final payload = JwtDecoder.decode(token.accessToken);
    final rawRoles = payload['roles'] as List<dynamic>? ?? [];

    final availableRoles = rawRoles
        .map((r) => UserRole.fromJson(r as Map<String, dynamic>))
        .toList();

    if (availableRoles.isEmpty) {
      // Authenticated but no roles — treat as unauthenticated (no access)
      return const AuthState.unauthenticated();
    }

    final activeRole = _resolveActiveRole(availableRoles);

    return AuthState.authenticated(
      token: token,
      availableRoles: availableRoles,
      activeRole: activeRole,
    );
  }

  UserRole _resolveActiveRole(List<UserRole> roles) {
    // 1. Persisted preference — explicit selection or a previously resolved default
    final savedRoleId = _preferencesStorage.activeRoleId;
    if (savedRoleId != null) {
      final saved = roles.where((r) => r.roleId == savedRoleId).firstOrNull;
      if (saved != null) return saved;
      // Saved role was revoked — clear stale value and re-resolve below
      _preferencesStorage.clearActiveRoleId();
    }

    // 2. Member role — always the starting workspace for new users.
    //    Even if a user later gains staff access they begin as a member
    //    until they explicitly switch via the workspace selection screen.
    final memberRole = roles.where((r) => r.roleEnum == Role.member).firstOrNull;
    if (memberRole != null) {
      _preferencesStorage.setActiveRoleId(memberRole.roleId);
      return memberRole;
    }

    // 3. Server-designated role (isCurrent == true) — only reached for
    //    accounts that have no member role (e.g. pure staff / admin).
    final serverDefault = roles.where((r) => r.isCurrent).firstOrNull;
    if (serverDefault != null) {
      _preferencesStorage.setActiveRoleId(serverDefault.roleId);
      return serverDefault;
    }

    // 4. Absolute fallback
    final fallback = roles.first;
    _preferencesStorage.setActiveRoleId(fallback.roleId);
    return fallback;
  }
}
