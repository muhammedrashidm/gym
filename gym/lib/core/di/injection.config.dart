// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dart_mediatr/dart_mediatr.dart' as _i9;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i7;
import 'package:get_it/get_it.dart' as _i1;
import 'package:gym/core/config/app_config.dart' as _i11;
import 'package:gym/core/network/api_client.dart' as _i13;
import 'package:gym/core/network/interceptors/auth_interceptor.dart' as _i10;
import 'package:gym/core/router/app_router.dart' as _i14;
import 'package:gym/core/storage/preferences_storage.dart' as _i3;
import 'package:gym/core/storage/secure_storage.dart' as _i6;
import 'package:gym/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i15;
import 'package:gym/features/auth/data/repositories/auth_repository_impl.dart'
    as _i17;
import 'package:gym/features/auth/domain/repositories/auth_repository.dart'
    as _i16;
import 'package:gym/features/auth/domain/usecases/send_otp_command_handler.dart'
    as _i18;
import 'package:gym/features/auth/domain/usecases/verify_otp_command_handler.dart'
    as _i19;
import 'package:gym/features/auth/presentation/cubit/auth_cubit.dart' as _i8;
import 'package:gym/features/auth/presentation/cubit/session_cubit.dart'
    as _i12;
import 'package:gym/features/profile/presentation/cubit/profile_cubit.dart'
    as _i5;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i4;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i3.PreferencesStorage>(
        () => _i3.PreferencesStorage(gh<_i4.SharedPreferences>()));
    gh.factory<_i5.ProfileCubit>(() => _i5.ProfileCubit());
    gh.singleton<_i6.SecureStorage>(
        () => _i6.SecureStorage(gh<_i7.FlutterSecureStorage>()));
    gh.singleton<_i8.AuthCubit>(() => _i8.AuthCubit(
          gh<_i9.Mediator>(),
          gh<_i6.SecureStorage>(),
        ));
    gh.singleton<_i10.AuthInterceptor>(() => _i10.AuthInterceptor(
          gh<_i6.SecureStorage>(),
          gh<_i11.AppConfig>(),
        ));
    gh.singleton<_i12.SessionCubit>(
        () => _i12.SessionCubit(gh<_i8.AuthCubit>()));
    gh.singleton<_i13.ApiClient>(() => _i13.ApiClient(
          gh<_i11.AppConfig>(),
          gh<_i10.AuthInterceptor>(),
        ));
    gh.singleton<_i14.AppRouter>(() => _i14.AppRouter(
          gh<_i8.AuthCubit>(),
          gh<_i12.SessionCubit>(),
        ));
    gh.singleton<_i15.AuthRemoteDataSource>(
        () => _i15.AuthRemoteDataSource(gh<_i13.ApiClient>()));
    gh.factory<_i16.AuthRepository>(
        () => _i17.AuthRepositoryImpl(gh<_i15.AuthRemoteDataSource>()));
    gh.factory<_i18.SendOtpCommandHandler>(
        () => _i18.SendOtpCommandHandler(gh<_i16.AuthRepository>()));
    gh.factory<_i19.VerifyOtpCommandHandler>(
        () => _i19.VerifyOtpCommandHandler(gh<_i16.AuthRepository>()));
    return this;
  }
}
