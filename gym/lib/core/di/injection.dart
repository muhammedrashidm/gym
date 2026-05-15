import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../../features/auth/domain/usecases/send_otp_command_handler.dart';
import '../../features/auth/domain/usecases/verify_otp_command_handler.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies(AppConfig config) async {
  // 1. Register external deps that injectable cannot auto-discover
  getIt.registerSingleton<AppConfig>(config);
  getIt.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());

  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // 2. Mediator must be registered before getIt.init() because AuthCubit
  //    (registered inside init) depends on it.
  final mediator = Mediator();
  getIt.registerSingleton<Mediator>(mediator);

  // 3. Run generated injectable registrations (synchronous)
  getIt.init();

  // 4. Wire command handlers into Mediator after handlers are built by get_it
  mediator.registerCommandHandler(getIt<SendOtpCommandHandler>());
  mediator.registerCommandHandler(getIt<VerifyOtpCommandHandler>());
}
