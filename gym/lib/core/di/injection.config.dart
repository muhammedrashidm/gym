// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dart_mediatr/dart_mediatr.dart' as _i13;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i18;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i8;
import 'package:get_it/get_it.dart' as _i1;
import 'package:gym/core/config/app_config.dart' as _i10;
import 'package:gym/core/database/app_database.dart' as _i3;
import 'package:gym/core/live_session/session_sync_service.dart' as _i17;
import 'package:gym/core/network/api_client.dart' as _i21;
import 'package:gym/core/network/interceptors/auth_interceptor.dart' as _i14;
import 'package:gym/core/network/token_refresh_service.dart' as _i9;
import 'package:gym/core/router/app_router.dart' as _i22;
import 'package:gym/core/storage/preferences_storage.dart' as _i4;
import 'package:gym/core/storage/secure_storage.dart' as _i7;
import 'package:gym/features/auth/data/datasources/auth_remote_data_source.dart'
    as _i23;
import 'package:gym/features/auth/data/repositories/auth_repository_impl.dart'
    as _i25;
import 'package:gym/features/auth/domain/repositories/auth_repository.dart'
    as _i24;
import 'package:gym/features/auth/domain/usecases/logout_command_handler.dart'
    as _i26;
import 'package:gym/features/auth/domain/usecases/send_otp_command_handler.dart'
    as _i30;
import 'package:gym/features/auth/domain/usecases/verify_otp_command_handler.dart'
    as _i38;
import 'package:gym/features/auth/presentation/cubit/auth_cubit.dart' as _i12;
import 'package:gym/features/profile/data/datasources/profile_remote_datasource.dart'
    as _i27;
import 'package:gym/features/profile/data/repositories/profile_repository_impl.dart'
    as _i29;
import 'package:gym/features/profile/domain/repositories/profile_repository.dart'
    as _i28;
import 'package:gym/features/profile/domain/usecases/connect_to_trainer_command.dart'
    as _i44;
import 'package:gym/features/profile/domain/usecases/trainer_signup_command_handler.dart'
    as _i37;
import 'package:gym/features/profile/presentation/cubit/profile_cubit.dart'
    as _i6;
import 'package:gym/features/staff/data/datasources/staff_remote_datasource.dart'
    as _i31;
import 'package:gym/features/staff/data/repositories/staff_repository_impl.dart'
    as _i33;
import 'package:gym/features/staff/domain/repositories/staff_repository.dart'
    as _i32;
import 'package:gym/features/staff/domain/usecases/get_qr_token_query.dart'
    as _i49;
import 'package:gym/features/staff/domain/usecases/list_staff_clients_query.dart'
    as _i51;
import 'package:gym/features/staff/domain/usecases/staff_create_profile_command.dart'
    as _i52;
import 'package:gym/features/task_media/data/datasources/task_media_remote_datasource.dart'
    as _i34;
import 'package:gym/features/task_media/data/repositories/task_media_repository_impl.dart'
    as _i36;
import 'package:gym/features/task_media/domain/repositories/task_media_repository.dart'
    as _i35;
import 'package:gym/features/task_media/domain/usecases/manage_task_media.dart'
    as _i46;
import 'package:gym/features/workout/data/datasources/workout_remote_datasource.dart'
    as _i39;
import 'package:gym/features/workout/data/repositories/workout_repository_impl.dart'
    as _i41;
import 'package:gym/features/workout/domain/repositories/workout_repository.dart'
    as _i40;
import 'package:gym/features/workout/domain/usecases/manage_day_plans.dart'
    as _i48;
import 'package:gym/features/workout/domain/usecases/manage_tasks.dart' as _i45;
import 'package:gym/features/workout/domain/usecases/manage_weekly_plans.dart'
    as _i42;
import 'package:gym/features/workout/domain/usecases/manage_workout_profiles.dart'
    as _i47;
import 'package:gym/features/workout_session/data/datasources/workout_session_local_datasource.dart'
    as _i11;
import 'package:gym/features/workout_session/domain/usecases/get_today_plan_query.dart'
    as _i50;
import 'package:gym/features/workout_session/domain/usecases/member_session_commands.dart'
    as _i43;
import 'package:gym/features/workout_session/domain/usecases/trainer_session_commands.dart'
    as _i15;
import 'package:gym/features/workout_session/presentation/cubit/member_workout_session/member_workout_session_cubit.dart'
    as _i16;
import 'package:gym/features/workout_session/presentation/cubit/trainer_client_session/trainer_client_session_cubit.dart'
    as _i19;
import 'package:gym/features/workout_session/presentation/cubit/trainer_live_clients/trainer_live_clients_cubit.dart'
    as _i20;
import 'package:injectable/injectable.dart' as _i2;
import 'package:shared_preferences/shared_preferences.dart' as _i5;

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
    gh.singleton<_i3.AppDatabase>(() => _i3.AppDatabase());
    gh.singleton<_i4.PreferencesStorage>(
        () => _i4.PreferencesStorage(gh<_i5.SharedPreferences>()));
    gh.singleton<_i6.ProfileCubit>(() => _i6.ProfileCubit());
    gh.singleton<_i7.SecureStorage>(
        () => _i7.SecureStorage(gh<_i8.FlutterSecureStorage>()));
    gh.singleton<_i9.TokenRefreshService>(() => _i9.TokenRefreshService(
          gh<_i7.SecureStorage>(),
          gh<_i10.AppConfig>(),
        ));
    gh.singleton<_i11.WorkoutSessionLocalDataSource>(
        () => _i11.WorkoutSessionLocalDataSource(gh<_i3.AppDatabase>()));
    gh.singleton<_i12.AuthCubit>(() => _i12.AuthCubit(
          gh<_i13.Mediator>(),
          gh<_i7.SecureStorage>(),
          gh<_i4.PreferencesStorage>(),
          gh<_i9.TokenRefreshService>(),
        ));
    gh.singleton<_i14.AuthInterceptor>(() => _i14.AuthInterceptor(
          gh<_i7.SecureStorage>(),
          gh<_i9.TokenRefreshService>(),
        ));
    gh.factory<_i15.GetTrainerActiveClientDraftsQueryHandler>(() =>
        _i15.GetTrainerActiveClientDraftsQueryHandler(
            gh<_i11.WorkoutSessionLocalDataSource>()));
    gh.factory<_i16.MemberWorkoutSessionCubit>(
        () => _i16.MemberWorkoutSessionCubit(
              gh<_i13.Mediator>(),
              gh<_i11.WorkoutSessionLocalDataSource>(),
            ));
    gh.singleton<_i17.SessionSyncService>(() => _i17.SessionSyncService(
          gh<_i11.WorkoutSessionLocalDataSource>(),
          gh<_i12.AuthCubit>(),
          gh<_i18.FlutterLocalNotificationsPlugin>(),
        ));
    gh.factory<_i19.TrainerClientSessionCubit>(
        () => _i19.TrainerClientSessionCubit(
              gh<_i13.Mediator>(),
              gh<_i11.WorkoutSessionLocalDataSource>(),
            ));
    gh.factory<_i20.TrainerLiveClientsCubit>(() => _i20.TrainerLiveClientsCubit(
          gh<_i13.Mediator>(),
          gh<_i11.WorkoutSessionLocalDataSource>(),
        ));
    gh.singleton<_i21.ApiClient>(() => _i21.ApiClient(
          gh<_i10.AppConfig>(),
          gh<_i14.AuthInterceptor>(),
        ));
    gh.singleton<_i22.AppRouter>(() => _i22.AppRouter(gh<_i12.AuthCubit>()));
    gh.singleton<_i23.AuthRemoteDataSource>(
        () => _i23.AuthRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i24.AuthRepository>(
        () => _i25.AuthRepositoryImpl(gh<_i23.AuthRemoteDataSource>()));
    gh.factory<_i26.LogoutCommandHandler>(
        () => _i26.LogoutCommandHandler(gh<_i24.AuthRepository>()));
    gh.singleton<_i27.ProfileRemoteDataSource>(
        () => _i27.ProfileRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i28.ProfileRepository>(
        () => _i29.ProfileRepositoryImpl(gh<_i27.ProfileRemoteDataSource>()));
    gh.factory<_i30.SendOtpCommandHandler>(
        () => _i30.SendOtpCommandHandler(gh<_i24.AuthRepository>()));
    gh.singleton<_i31.StaffRemoteDataSource>(
        () => _i31.StaffRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i32.StaffRepository>(
        () => _i33.StaffRepositoryImpl(gh<_i31.StaffRemoteDataSource>()));
    gh.singleton<_i34.TaskMediaRemoteDataSource>(
        () => _i34.TaskMediaRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i35.TaskMediaRepository>(() =>
        _i36.TaskMediaRepositoryImpl(gh<_i34.TaskMediaRemoteDataSource>()));
    gh.factory<_i37.TrainerSignupCommandHandler>(
        () => _i37.TrainerSignupCommandHandler(gh<_i28.ProfileRepository>()));
    gh.factory<_i38.VerifyOtpCommandHandler>(
        () => _i38.VerifyOtpCommandHandler(gh<_i24.AuthRepository>()));
    gh.singleton<_i39.WorkoutRemoteDataSource>(
        () => _i39.WorkoutRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i40.WorkoutRepository>(
        () => _i41.WorkoutRepositoryImpl(gh<_i39.WorkoutRemoteDataSource>()));
    gh.factory<_i42.ActivateWeeklyPlanCommandHandler>(() =>
        _i42.ActivateWeeklyPlanCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i15.CompleteClientWorkoutSessionCommandHandler>(() =>
        _i15.CompleteClientWorkoutSessionCommandHandler(
            gh<_i40.WorkoutRepository>()));
    gh.factory<_i43.CompleteMemberWorkoutSessionCommandHandler>(() =>
        _i43.CompleteMemberWorkoutSessionCommandHandler(
            gh<_i40.WorkoutRepository>()));
    gh.factory<_i44.ConnectToTrainerCommandHandler>(() =>
        _i44.ConnectToTrainerCommandHandler(gh<_i28.ProfileRepository>()));
    gh.factory<_i42.CreateFullWeeklyPlanCommandHandler>(() =>
        _i42.CreateFullWeeklyPlanCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i45.CreateTaskCommandHandler>(
        () => _i45.CreateTaskCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i46.CreateTaskMediaCommandHandler>(() =>
        _i46.CreateTaskMediaCommandHandler(gh<_i35.TaskMediaRepository>()));
    gh.factory<_i42.CreateWeeklyPlanCommandHandler>(() =>
        _i42.CreateWeeklyPlanCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i47.CreateWorkoutProfileCommandHandler>(() =>
        _i47.CreateWorkoutProfileCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i45.DeleteTaskCommandHandler>(
        () => _i45.DeleteTaskCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i15.GetClientWorkoutProfileQueryHandler>(() =>
        _i15.GetClientWorkoutProfileQueryHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i15.GetClientWorkoutSessionLogsQueryHandler>(() =>
        _i15.GetClientWorkoutSessionLogsQueryHandler(
            gh<_i40.WorkoutRepository>()));
    gh.factory<_i48.GetDayPlanDetailsQueryHandler>(
        () => _i48.GetDayPlanDetailsQueryHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i43.GetMemberActiveProfileQueryHandler>(() =>
        _i43.GetMemberActiveProfileQueryHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i43.GetMemberWorkoutSessionLogsQueryHandler>(() =>
        _i43.GetMemberWorkoutSessionLogsQueryHandler(
            gh<_i40.WorkoutRepository>()));
    gh.factory<_i49.GetQrTokenQueryHandler>(
        () => _i49.GetQrTokenQueryHandler(gh<_i32.StaffRepository>()));
    gh.factory<_i50.GetTodayPlanQueryHandler>(
        () => _i50.GetTodayPlanQueryHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i42.GetWeeklyPlanDetailsQueryHandler>(() =>
        _i42.GetWeeklyPlanDetailsQueryHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i42.GetWeeklyPlansQueryHandler>(
        () => _i42.GetWeeklyPlansQueryHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i47.GetWorkoutProfilesQueryHandler>(() =>
        _i47.GetWorkoutProfilesQueryHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i51.ListStaffClientsQueryHandler>(
        () => _i51.ListStaffClientsQueryHandler(gh<_i32.StaffRepository>()));
    gh.factory<_i46.SearchTaskMediaQueryHandler>(
        () => _i46.SearchTaskMediaQueryHandler(gh<_i35.TaskMediaRepository>()));
    gh.factory<_i15.SkipClientWorkoutSessionCommandHandler>(() =>
        _i15.SkipClientWorkoutSessionCommandHandler(
            gh<_i40.WorkoutRepository>()));
    gh.factory<_i43.SkipMemberWorkoutSessionCommandHandler>(() =>
        _i43.SkipMemberWorkoutSessionCommandHandler(
            gh<_i40.WorkoutRepository>()));
    gh.factory<_i52.StaffCreateProfileCommandHandler>(() =>
        _i52.StaffCreateProfileCommandHandler(gh<_i32.StaffRepository>()));
    gh.factory<_i48.UpdateDayPlanCommandHandler>(
        () => _i48.UpdateDayPlanCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i45.UpdateTaskCommandHandler>(
        () => _i45.UpdateTaskCommandHandler(gh<_i40.WorkoutRepository>()));
    gh.factory<_i47.UpdateWorkoutProfileCommandHandler>(() =>
        _i47.UpdateWorkoutProfileCommandHandler(gh<_i40.WorkoutRepository>()));
    return this;
  }
}
