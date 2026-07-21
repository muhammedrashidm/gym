import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../../features/auth/domain/usecases/send_otp_command_handler.dart';
import '../../features/auth/domain/usecases/verify_otp_command_handler.dart';
import '../../features/auth/domain/usecases/logout_command_handler.dart';
import '../../features/profile/domain/usecases/trainer_signup_command_handler.dart';
import '../../features/profile/domain/usecases/connect_to_trainer_command.dart';
import '../../features/staff/domain/usecases/get_qr_token_query.dart';
import '../../features/staff/domain/usecases/list_staff_clients_query.dart';
import '../../features/staff/domain/usecases/staff_create_profile_command.dart';
import '../../features/workout/domain/usecases/manage_workout_profiles.dart';
import '../../features/workout/domain/usecases/manage_weekly_plans.dart';
import '../../features/workout/domain/usecases/manage_day_plans.dart';
import '../../features/workout/domain/usecases/manage_tasks.dart';
import '../../features/task_media/domain/usecases/manage_task_media.dart';
import '../../features/exercise_config/domain/usecases/manage_exercise_config.dart';
import '../../features/workout_session/domain/usecases/get_today_plan_query.dart';
import '../../features/workout_session/domain/usecases/member_session_commands.dart';
import '../../features/workout_session/domain/usecases/trainer_session_commands.dart';
import '../live_session/session_sync_service.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(AppConfig config) async {
  // 1. Register external deps that injectable cannot auto-discover
  getIt.registerSingleton<AppConfig>(config);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // FlutterLocalNotificationsPlugin (no auto-discovery, register manually)
  getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin(),
  );

  // 2. Mediator must be registered before getIt.init() because AuthCubit
  //    (registered inside init) depends on it.
  final mediator = Mediator();
  getIt.registerSingleton<Mediator>(mediator);

  // 3. Run generated injectable registrations (synchronous)
  getIt.init();

  // 4. Wire command handlers into Mediator after handlers are built by get_it
  mediator.registerCommandHandler(getIt<SendOtpCommandHandler>());
  mediator.registerCommandHandler(getIt<VerifyOtpCommandHandler>());
  mediator.registerCommandHandler(getIt<LogoutCommandHandler>());
  mediator.registerCommandHandler(getIt<TrainerSignupCommandHandler>());
  mediator.registerCommandHandler(getIt<ConnectToTrainerCommandHandler>());

  // Staff Handlers
  mediator.registerCommandHandler(getIt<GetQrTokenQueryHandler>());
  mediator.registerCommandHandler(getIt<ListStaffClientsQueryHandler>());
  mediator.registerCommandHandler(getIt<StaffCreateProfileCommandHandler>());

  // Workout Handlers
  mediator.registerCommandHandler(getIt<GetWorkoutProfilesQueryHandler>());
  mediator.registerCommandHandler(getIt<CreateWorkoutProfileCommandHandler>());
  mediator.registerCommandHandler(getIt<UpdateWorkoutProfileCommandHandler>());
  mediator.registerCommandHandler(getIt<CreateWeeklyPlanCommandHandler>());
  mediator.registerCommandHandler(getIt<CreateFullWeeklyPlanCommandHandler>());
  mediator.registerCommandHandler(getIt<GetWeeklyPlansQueryHandler>());
  mediator.registerCommandHandler(getIt<GetWeeklyPlanDetailsQueryHandler>());
  mediator.registerCommandHandler(getIt<ActivateWeeklyPlanCommandHandler>());
  mediator.registerCommandHandler(getIt<GetDayPlanDetailsQueryHandler>());
  mediator.registerCommandHandler(getIt<UpdateDayPlanCommandHandler>());
  mediator.registerCommandHandler(getIt<CreateTaskCommandHandler>());
  mediator.registerCommandHandler(getIt<UpdateTaskCommandHandler>());
  mediator.registerCommandHandler(getIt<DeleteTaskCommandHandler>());

  // Task Media Handlers
  mediator.registerCommandHandler(getIt<SearchTaskMediaQueryHandler>());
  mediator.registerCommandHandler(getIt<CreateTaskMediaCommandHandler>());

  // Exercise Config Handlers
  mediator.registerCommandHandler(getIt<SearchExerciseConfigQueryHandler>());

  // Workout Session Handlers (shared)
  mediator.registerCommandHandler(getIt<GetTodayPlanQueryHandler>());

  // Workout Session Handlers (Member)
  mediator.registerCommandHandler(getIt<GetMemberActiveProfileQueryHandler>());
  mediator.registerCommandHandler(getIt<CompleteMemberWorkoutSessionCommandHandler>());
  mediator.registerCommandHandler(getIt<SkipMemberWorkoutSessionCommandHandler>());
  mediator.registerCommandHandler(getIt<GetMemberWorkoutSessionLogsQueryHandler>());

  // Workout Session Handlers (Trainer)
  mediator.registerCommandHandler(getIt<GetClientWorkoutProfileQueryHandler>());
  mediator.registerCommandHandler(getIt<CompleteClientWorkoutSessionCommandHandler>());
  mediator.registerCommandHandler(getIt<SkipClientWorkoutSessionCommandHandler>());
  mediator.registerCommandHandler(getIt<GetClientWorkoutSessionLogsQueryHandler>());
  mediator.registerCommandHandler(getIt<GetTrainerActiveClientDraftsQueryHandler>());

  // 5. Bootstrap background sync service (lives for app lifetime)
  getIt<SessionSyncService>();
}
