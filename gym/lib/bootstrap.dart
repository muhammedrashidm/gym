import 'package:flutter/material.dart';
import 'core/config/app_config.dart';
import 'core/di/injection.dart';

import 'app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies(config);
  await Firebase.initializeApp(
  );
  await FirebaseAppCheck.instance.activate(
    // Set androidProvider to `AndroidProvider.debug`
    providerAndroid: AndroidDebugProvider(),
  );
  // Removed: await getIt<AuthCubit>().loadAuthState();
  // Instead, the SplashPage will call loadAuthState() on initialization.

  runApp(const App());
}
