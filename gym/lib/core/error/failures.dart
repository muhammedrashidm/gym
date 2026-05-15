import 'package:freezed_annotation/freezed_annotation.dart';
part 'failures.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  const factory Failure.server({
    required int statusCode,
    required String message,
  }) = ServerFailure;

  const factory Failure.network({String? message}) = NetworkFailure;

  const factory Failure.unauthorized() = UnauthorizedFailure;

  const factory Failure.unknown({String? message}) = UnknownFailure;
}
