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
    as _i29;
import 'package:gym/features/auth/domain/usecases/send_otp_command_handler.dart'
    as _i34;
import 'package:gym/features/auth/domain/usecases/verify_otp_command_handler.dart'
    as _i42;
import 'package:gym/features/auth/presentation/cubit/auth_cubit.dart' as _i12;
import 'package:gym/features/exercise_config/data/datasources/exercise_config_remote_datasource.dart'
    as _i26;
import 'package:gym/features/exercise_config/data/repositories/exercise_config_repository_impl.dart'
    as _i28;
import 'package:gym/features/exercise_config/domain/repositories/exercise_config_repository.dart'
    as _i27;
import 'package:gym/features/exercise_config/domain/usecases/manage_exercise_config.dart'
    as _i33;
import 'package:gym/features/profile/data/datasources/profile_remote_datasource.dart'
    as _i30;
import 'package:gym/features/profile/data/repositories/profile_repository_impl.dart'
    as _i32;
import 'package:gym/features/profile/domain/repositories/profile_repository.dart'
    as _i31;
import 'package:gym/features/profile/domain/usecases/connect_to_trainer_command.dart'
    as _i48;
import 'package:gym/features/profile/domain/usecases/trainer_signup_command_handler.dart'
    as _i41;
import 'package:gym/features/profile/presentation/cubit/profile_cubit.dart'
    as _i6;
import 'package:gym/features/staff/data/datasources/staff_remote_datasource.dart'
    as _i35;
import 'package:gym/features/staff/data/repositories/staff_repository_impl.dart'
    as _i37;
import 'package:gym/features/staff/domain/repositories/staff_repository.dart'
    as _i36;
import 'package:gym/features/staff/domain/usecases/get_qr_token_query.dart'
    as _i53;
import 'package:gym/features/staff/domain/usecases/list_staff_clients_query.dart'
    as _i55;
import 'package:gym/features/staff/domain/usecases/staff_create_profile_command.dart'
    as _i56;
import 'package:gym/features/task_media/data/datasources/task_media_remote_datasource.dart'
    as _i38;
import 'package:gym/features/task_media/data/repositories/task_media_repository_impl.dart'
    as _i40;
import 'package:gym/features/task_media/domain/repositories/task_media_repository.dart'
    as _i39;
import 'package:gym/features/task_media/domain/usecases/manage_task_media.dart'
    as _i50;
import 'package:gym/features/workout/data/datasources/workout_remote_datasource.dart'
    as _i43;
import 'package:gym/features/workout/data/repositories/workout_repository_impl.dart'
    as _i45;
import 'package:gym/features/workout/domain/repositories/workout_repository.dart'
    as _i44;
import 'package:gym/features/workout/domain/usecases/manage_day_plans.dart'
    as _i52;
import 'package:gym/features/workout/domain/usecases/manage_tasks.dart' as _i49;
import 'package:gym/features/workout/domain/usecases/manage_weekly_plans.dart'
    as _i46;
import 'package:gym/features/workout/domain/usecases/manage_workout_profiles.dart'
    as _i51;
import 'package:gym/features/workout_session/data/datasources/workout_session_local_datasource.dart'
    as _i11;
import 'package:gym/features/workout_session/domain/usecases/get_today_plan_query.dart'
    as _i54;
import 'package:gym/features/workout_session/domain/usecases/member_session_commands.dart'
    as _i47;
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
    gh.singleton<_i26.ExerciseConfigRemoteDataSource>(
        () => _i26.ExerciseConfigRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i27.ExerciseConfigRepository>(() =>
        _i28.ExerciseConfigRepositoryImpl(
            gh<_i26.ExerciseConfigRemoteDataSource>()));
    gh.factory<_i29.LogoutCommandHandler>(
        () => _i29.LogoutCommandHandler(gh<_i24.AuthRepository>()));
    gh.singleton<_i30.ProfileRemoteDataSource>(
        () => _i30.ProfileRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i31.ProfileRepository>(
        () => _i32.ProfileRepositoryImpl(gh<_i30.ProfileRemoteDataSource>()));
    gh.factory<_i33.SearchExerciseConfigQueryHandler>(() =>
        _i33.SearchExerciseConfigQueryHandler(
            gh<_i27.ExerciseConfigRepository>()));
    gh.factory<_i34.SendOtpCommandHandler>(
        () => _i34.SendOtpCommandHandler(gh<_i24.AuthRepository>()));
    gh.singleton<_i35.StaffRemoteDataSource>(
        () => _i35.StaffRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i36.StaffRepository>(
        () => _i37.StaffRepositoryImpl(gh<_i35.StaffRemoteDataSource>()));
    gh.singleton<_i38.TaskMediaRemoteDataSource>(
        () => _i38.TaskMediaRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i39.TaskMediaRepository>(() =>
        _i40.TaskMediaRepositoryImpl(gh<_i38.TaskMediaRemoteDataSource>()));
    gh.factory<_i41.TrainerSignupCommandHandler>(
        () => _i41.TrainerSignupCommandHandler(gh<_i31.ProfileRepository>()));
    gh.factory<_i42.VerifyOtpCommandHandler>(
        () => _i42.VerifyOtpCommandHandler(gh<_i24.AuthRepository>()));
    gh.singleton<_i43.WorkoutRemoteDataSource>(
        () => _i43.WorkoutRemoteDataSourceImpl(gh<_i21.ApiClient>()));
    gh.factory<_i44.WorkoutRepository>(
        () => _i45.WorkoutRepositoryImpl(gh<_i43.WorkoutRemoteDataSource>()));
    gh.factory<_i46.ActivateWeeklyPlanCommandHandler>(() =>
        _i46.ActivateWeeklyPlanCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i15.CompleteClientWorkoutSessionCommandHandler>(() =>
        _i15.CompleteClientWorkoutSessionCommandHandler(
            gh<_i44.WorkoutRepository>()));
    gh.factory<_i47.CompleteMemberWorkoutSessionCommandHandler>(() =>
        _i47.CompleteMemberWorkoutSessionCommandHandler(
            gh<_i44.WorkoutRepository>()));
    gh.factory<_i48.ConnectToTrainerCommandHandler>(() =>
        _i48.ConnectToTrainerCommandHandler(gh<_i31.ProfileRepository>()));
    gh.factory<_i46.CreateFullWeeklyPlanCommandHandler>(() =>
        _i46.CreateFullWeeklyPlanCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i49.CreateTaskCommandHandler>(
        () => _i49.CreateTaskCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i50.CreateTaskMediaCommandHandler>(() =>
        _i50.CreateTaskMediaCommandHandler(gh<_i39.TaskMediaRepository>()));
    gh.factory<_i46.CreateWeeklyPlanCommandHandler>(() =>
        _i46.CreateWeeklyPlanCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i51.CreateWorkoutProfileCommandHandler>(() =>
        _i51.CreateWorkoutProfileCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i49.DeleteTaskCommandHandler>(
        () => _i49.DeleteTaskCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i15.GetClientWorkoutProfileQueryHandler>(() =>
        _i15.GetClientWorkoutProfileQueryHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i15.GetClientWorkoutSessionLogsQueryHandler>(() =>
        _i15.GetClientWorkoutSessionLogsQueryHandler(
            gh<_i44.WorkoutRepository>()));
    gh.factory<_i52.GetDayPlanDetailsQueryHandler>(
        () => _i52.GetDayPlanDetailsQueryHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i47.GetMemberActiveProfileQueryHandler>(() =>
        _i47.GetMemberActiveProfileQueryHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i47.GetMemberWorkoutSessionLogsQueryHandler>(() =>
        _i47.GetMemberWorkoutSessionLogsQueryHandler(
            gh<_i44.WorkoutRepository>()));
    gh.factory<_i53.GetQrTokenQueryHandler>(
        () => _i53.GetQrTokenQueryHandler(gh<_i36.StaffRepository>()));
    gh.factory<_i54.GetTodayPlanQueryHandler>(
        () => _i54.GetTodayPlanQueryHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i46.GetWeeklyPlanDetailsQueryHandler>(() =>
        _i46.GetWeeklyPlanDetailsQueryHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i46.GetWeeklyPlansQueryHandler>(
        () => _i46.GetWeeklyPlansQueryHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i51.GetWorkoutProfilesQueryHandler>(() =>
        _i51.GetWorkoutProfilesQueryHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i55.ListStaffClientsQueryHandler>(
        () => _i55.ListStaffClientsQueryHandler(gh<_i36.StaffRepository>()));
    gh.factory<_i50.SearchTaskMediaQueryHandler>(
        () => _i50.SearchTaskMediaQueryHandler(gh<_i39.TaskMediaRepository>()));
    gh.factory<_i15.SkipClientWorkoutSessionCommandHandler>(() =>
        _i15.SkipClientWorkoutSessionCommandHandler(
            gh<_i44.WorkoutRepository>()));
    gh.factory<_i47.SkipMemberWorkoutSessionCommandHandler>(() =>
        _i47.SkipMemberWorkoutSessionCommandHandler(
            gh<_i44.WorkoutRepository>()));
    gh.factory<_i56.StaffCreateProfileCommandHandler>(() =>
        _i56.StaffCreateProfileCommandHandler(gh<_i36.StaffRepository>()));
    gh.factory<_i52.UpdateDayPlanCommandHandler>(
        () => _i52.UpdateDayPlanCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i49.UpdateTaskCommandHandler>(
        () => _i49.UpdateTaskCommandHandler(gh<_i44.WorkoutRepository>()));
    gh.factory<_i51.UpdateWorkoutProfileCommandHandler>(() =>
        _i51.UpdateWorkoutProfileCommandHandler(gh<_i44.WorkoutRepository>()));
    return this;
  }
}
