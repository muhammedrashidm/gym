import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user_role.dart';

part 'auth_state.freezed.dart';

@freezed
sealed class AuthState with _$AuthState {
  /// App just launched — token read not yet attempted.
  const factory AuthState.initial() = AuthInitial;

  /// Startup token check in progress.
  const factory AuthState.checkingToken() = AuthCheckingToken;

  /// Token read / OTP network call in progress.
  const factory AuthState.loading() = AuthLoading;

  /// OTP was sent; waiting for user to enter the code.
  const factory AuthState.otpSent({required String phoneNumber}) = AuthOtpSent;

  /// No token stored, or the session was forcibly ended.
  /// [sessionExpired] is true when this followed a server-confirmed refresh
  /// rejection (as opposed to simply never having logged in), so the login
  /// screen can show an appropriate message.
  const factory AuthState.unauthenticated({
    @Default(false) bool sessionExpired,
  }) = AuthUnauthenticated;

  /// A network or validation error occurred.
  const factory AuthState.error({required String message}) = AuthError;

  /// Successfully authenticated. Carries the full session:
  ///   - [availableRoles]  — all roles decoded from the JWT
  ///   - [activeRole]      — the role currently being used (never null)
  const factory AuthState.authenticated({
    required AuthToken token,
    required List<UserRole> availableRoles,
    required UserRole activeRole,
  }) = AuthAuthenticated;
}
