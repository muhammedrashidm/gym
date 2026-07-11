import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:gym/features/profile/presentation/cubit/profile_cubit.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'globals.dart';
import 'theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    themeManager.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeManager.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>().router;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (BuildContext context) {
            return getIt<AuthCubit>();
          },
        ),BlocProvider(
          create: (BuildContext context) {
            return getIt<ProfileCubit>();
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'Kinetic',
        routerConfig: router,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeManager.themeMode,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
