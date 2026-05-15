import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';

import 'app.dart';

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(config);

  // Removed: await getIt<AuthCubit>().loadAuthState();
  // Instead, the SplashPage will call loadAuthState() on initialization.

  runApp(const App());
}
