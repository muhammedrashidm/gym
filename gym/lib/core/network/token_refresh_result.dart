import 'package:freezed_annotation/freezed_annotation.dart';
import '../../features/auth/domain/entities/auth_token.dart';

part 'token_refresh_result.freezed.dart';

/// Outcome of a [TokenRefreshService.refresh] attempt.
///
/// The distinction between [rejected] and [transientFailure] is load-bearing:
/// only a server-confirmed rejection of the refresh token is grounds for a
/// forced logout. A network/timeout error must leave the session untouched.
@freezed
sealed class RefreshResult with _$RefreshResult {
  const factory RefreshResult.success(AuthToken token) = RefreshSuccess;

  const factory RefreshResult.rejected() = RefreshRejected;

  const factory RefreshResult.transientFailure() = RefreshTransientFailure;
}
