import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/usecases/send_otp_command.dart';
import '../../domain/usecases/verify_otp_command.dart';
import 'auth_state.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  final Mediator _mediator;
  final SecureStorage _secureStorage;

  AuthCubit(this._mediator, this._secureStorage)
      : super(const AuthState.initial());

  /// Called from SplashPage on app startup.
  /// Reads stored token into state and optionally fetches profile.
  Future<void> loadAuthState() async {
    // Artificial delay to show splash screen branding
    await Future.delayed(const Duration(seconds: 1));

    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      final refresh = await _secureStorage.getRefreshToken();
      
      // Mock fetching basic profile from shared preferences or API
      // TODO: Implement actual profile fetch later
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(AuthState.authenticated(
        token: AuthToken(
          accessToken: token,
          refreshToken: refresh ?? '',
        ),
      ));
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> sendOtp({required String phoneNumber}) async {
    emit(const AuthState.loading());

    final result = await _mediator.sendCommand(SendOtpCommand(phoneNumber: phoneNumber))
    as Either<Failure, Unit>;

    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (_) => emit(AuthState.otpSent(phoneNumber: phoneNumber)),
    );
  }

  Future<void> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    emit(const AuthState.loading());
    final result = await _mediator
        .sendCommand(VerifyOtpCommand(phoneNumber: phoneNumber, otp: otp))as Either<Failure, AuthToken>;
    result.fold(
      (failure) => emit(AuthState.error(message: failure.toString())),
      (token) async {
        await _secureStorage.saveAccessToken(token.accessToken);
        await _secureStorage.saveRefreshToken(token.refreshToken);
        emit(AuthState.authenticated(token: token));
      },
    );
  }

  Future<void> logout() async {
    await _secureStorage.clearTokens();
    emit(const AuthState.unauthenticated());
  }
}
