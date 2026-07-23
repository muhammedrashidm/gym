import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/workspace_selection_page.dart';
import 'app_routes.dart';
import 'router_guard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/member/presentation/pages/explore_page.dart';
import '../../features/workout_session/presentation/pages/weekly_plan_page.dart';
import '../../features/member/presentation/pages/recovery_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/trainer_signup_page.dart';
import '../../features/staff/presentation/pages/staff_dashboard_page.dart';
import '../../features/staff/presentation/pages/staff_clients_page.dart';
import '../../features/staff/presentation/pages/staff_profile_page.dart';
import '../../features/staff/presentation/pages/staff_qr_page.dart';
import '../../features/staff/presentation/pages/staff_add_client_page.dart';
import '../../features/profile/presentation/pages/client_scanner_page.dart';
import '../../features/workout/presentation/pages/athlete_profile_page.dart';
import '../../features/workout/presentation/pages/initiate_program_page.dart';
import '../../features/workout/presentation/pages/day_plan_creator_page.dart';
import '../../features/workout/presentation/pages/week_plan_creator_page.dart';
import '../../features/workout_session/presentation/pages/task_execution_page.dart';
import '../../features/workout_session/presentation/pages/trainer_live_clients_page.dart';
import '../../features/workout_session/presentation/pages/trainer_client_session_page.dart';
import '../../features/workout_session/presentation/pages/day_preview_page.dart';
import '../../features/exercise_ai/presentation/pages/watch_me_args.dart';
import '../../features/exercise_ai/presentation/pages/watch_me_page.dart';
import '../../features/exercise_ai/presentation/cubit/watch_me_cubit.dart';
import '../../features/workout_session/presentation/cubit/member_workout_session/member_workout_session_cubit.dart';
import '../../features/workout_session/presentation/cubit/trainer_live_clients/trainer_live_clients_cubit.dart';
import '../../features/workout_session/presentation/cubit/trainer_client_session/trainer_client_session_cubit.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _memberShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'memberShell');
final GlobalKey<NavigatorState> _staffShellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'staffShell');

@singleton
class AppRouter {
  final AuthCubit _authCubit;
  late final GoRouter router;

  AppRouter(this._authCubit) {
    final guard = RouterGuard(_authCubit);

    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoute.splash.path,
      redirect: guard.redirect,
      refreshListenable: GoRouterAuthNotifier(_authCubit),
      routes: [
        GoRoute(
          path: AppRoute.splash.path,
          name: AppRoute.splash.name,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoute.login.path,
          name: AppRoute.login.name,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoute.otp.path,
          name: AppRoute.otp.name,
          builder: (context, state) => OtpPage(
            phoneNumber: state.extra as String,
          ),
        ),
        GoRoute(
          path: AppRoute.selectWorkspace.path,
          name: AppRoute.selectWorkspace.name,
          builder: (context, state) => const WorkspaceSelectionPage(),
        ),
        GoRoute(
          path: AppRoute.trainerSignup.path,
          name: AppRoute.trainerSignup.name,
          builder: (context, state) => const TrainerSignupPage(),
        ),
        GoRoute(
          path: AppRoute.staffQr.path,
          name: AppRoute.staffQr.name,
          builder: (context, state) => const StaffQrPage(),
        ),
        GoRoute(
          path: AppRoute.clientScanner.path,
          name: AppRoute.clientScanner.name,
          builder: (context, state) => const ClientScannerPage(),
        ),
        GoRoute(
          path: AppRoute.staffAddClient.path,
          name: AppRoute.staffAddClient.name,
          builder: (context, state) => const StaffAddClientPage(),
        ),
        GoRoute(
          path: AppRoute.athleteWorkout.path,
          name: AppRoute.athleteWorkout.name,
          builder: (context, state) => AthleteProfilePage(
            clientId: state.pathParameters['clientId']!,
          ),
        ),
        GoRoute(
          path: AppRoute.initiateProgram.path,
          name: AppRoute.initiateProgram.name,
          builder: (context, state) => InitiateProgramPage(
            clientId: state.pathParameters['clientId']!,
          ),
        ),
        GoRoute(
          path: AppRoute.weekPlanCreator.path,
          name: AppRoute.weekPlanCreator.name,
          builder: (context, state) => WeekPlanCreatorPage(
            workoutProfileId: state.pathParameters['workoutProfileId']!,
          ),
        ),
        GoRoute(
          path: AppRoute.dayPlanCreator.path,
          name: AppRoute.dayPlanCreator.name,
          builder: (context, state) => DayPlanCreatorPage(
            pageProps: state.extra as DayPlanCreatorPageProps,
          ),
        ),
        GoRoute(
          path: AppRoute.member.path,
          name: AppRoute.member.name,
          redirect: (context, state) => AppRoute.explore.path,
        ),
        GoRoute(
          path: AppRoute.staff.path,
          name: AppRoute.staff.name,
          redirect: (context, state) => AppRoute.staffDashboard.path,
        ),
        ShellRoute(
          navigatorKey: _memberShellNavigatorKey,
          builder: (context, state, child) => _MemberShell(child: child),
          routes: [
            GoRoute(
              path: AppRoute.explore.path,
              name: AppRoute.explore.name,
              builder: (context, state) => const ExplorePage(),
            ),
            GoRoute(
              path: AppRoute.train.path,
              name: AppRoute.train.name,
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<MemberWorkoutSessionCubit>(),
                child: const WeeklyPlanPage(),
              ),
            ),
            GoRoute(
              path: AppRoute.taskExecution.path,
              name: AppRoute.taskExecution.name,
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<MemberWorkoutSessionCubit>(),
                child: TaskExecutionPage(
                  taskData: state.extra as Map<String, dynamic>,
                ),
              ),
              // builder: (context, state) => TaskExecutionPage(
              //   taskData: state.extra as Map<String, dynamic>,
              // ),
            ),
            GoRoute(
              path: AppRoute.recovery.path,
              name: AppRoute.recovery.name,
              builder: (context, state) => const RecoveryPage(),
            ),
            GoRoute(
              path: AppRoute.profile.path,
              name: AppRoute.profile.name,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
        ShellRoute(
          navigatorKey: _staffShellNavigatorKey,
          builder: (context, state, child) => _StaffShell(child: child),
          routes: [
            GoRoute(
              path: AppRoute.staffDashboard.path,
              name: AppRoute.staffDashboard.name,
              builder: (context, state) => const StaffDashboardPage(),
            ),
            GoRoute(
              path: AppRoute.staffClients.path,
              name: AppRoute.staffClients.name,
              builder: (context, state) => const StaffClientsPage(),
            ),
            GoRoute(
              path: AppRoute.staffProfile.path,
              name: AppRoute.staffProfile.name,
              builder: (context, state) => const StaffProfilePage(),
            ),
            GoRoute(
              path: AppRoute.staffLiveSessions.path,
              name: AppRoute.staffLiveSessions.name,
              builder: (context, state) => BlocProvider(
                create: (_) => GetIt.I<TrainerLiveClientsCubit>(),
                child: const TrainerLiveClientsPage(),
              ),
            ),
          ],
        ),
        // Root-level (pushes over shell, hides bottom nav during active logging)
        GoRoute(
          path: AppRoute.clientSessionUpdate.path,
          name: AppRoute.clientSessionUpdate.name,
          builder: (context, state) => BlocProvider(
            create: (_) => GetIt.I<TrainerClientSessionCubit>(),
            child: TrainerClientSessionPage(
              clientId: state.pathParameters['clientId']!,
              clientName: state.extra as String? ?? '',
            ),
          ),
        ),
        GoRoute(
          path: AppRoute.dayPreview.path,
          name: AppRoute.dayPreview.name,
          builder: (context, state) => DayPreviewPage(
            args: state.extra as DayPreviewArgs,
          ),
        ),
        // AI form coach — root-level so the bottom nav is hidden while the
        // camera is live. Receives the pre-fetched ExerciseConfig plus the
        // athlete's set/rep prescription as `extra`.
        GoRoute(
          path: AppRoute.watchMe.path,
          name: AppRoute.watchMe.name,
          builder: (context, state) {
            final args = state.extra as WatchMeArgs;
            return BlocProvider(
              create: (_) => GetIt.I<WatchMeCubit>(),
              child: WatchMePage(config: args.config, plan: args.plan),
            );
          },
        ),
      ],
    );
  }
}

class GoRouterAuthNotifier extends ChangeNotifier {
  late final dynamic _subscription;

  GoRouterAuthNotifier(AuthCubit authCubit) {
    _subscription = authCubit.stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _MemberShell extends StatelessWidget {
  final Widget child;
  const _MemberShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.startsWith(AppRoute.train.path)) currentIndex = 1;
    if (location.startsWith(AppRoute.recovery.path)) currentIndex = 2;
    if (location.startsWith(AppRoute.profile.path)) currentIndex = 3;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9F9);
    final activeBg = isDark ? const Color(0xFF3B3B3C) : const Color(0xFFE2E2E2);
    final activeFg = isDark ? Colors.white : Colors.black;
    final inactiveBg = Colors.transparent;
    final inactiveFg =
        isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);

    Widget buildNavItem(int index, String iconName, String label, String path) {
      final isActive = currentIndex == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.go(path),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? activeBg : inactiveBg,
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/$iconName.svg',
                  colorFilter: ColorFilter.mode(
                      isActive ? activeFg : inactiveFg, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                    color: isActive ? activeFg : inactiveFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(onPressed: () {}),
      body: child,
      bottomNavigationBar: Container(
        color: bgColor,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            buildNavItem(0, 'map', 'EXPLORE', AppRoute.explore.path),
            buildNavItem(1, 'fitness_center', 'TRAIN', AppRoute.train.path),
            buildNavItem(
                2, 'self_improvement', 'RECOVERY', AppRoute.recovery.path),
            buildNavItem(3, 'person', 'PROFILE', AppRoute.profile.path),
          ],
        ),
      ),
    );
  }
}

class _StaffShell extends StatelessWidget {
  final Widget child;
  const _StaffShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.startsWith(AppRoute.staffClients.path)) currentIndex = 1;
    if (location.startsWith(AppRoute.staffLiveSessions.path)) currentIndex = 2;
    if (location.startsWith(AppRoute.staffProfile.path)) currentIndex = 3;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific colors
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final activeBg = isDark ? const Color(0xFF3B3B3C) : const Color(0xFFE2E2E2);
    final activeFg = isDark ? Colors.white : Colors.black;
    final inactiveBg = Colors.transparent;
    final inactiveFg =
        isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);
    final borderCol =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    Widget buildNavItem(
        int index, IconData iconData, String label, String path) {
      final isActive = currentIndex == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => context.go(path),
          behavior: HitTestBehavior.opaque,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? activeBg : inactiveBg,
              borderRadius: BorderRadius.zero, // Sharp 0px borders
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconData,
                  color: isActive ? activeFg : inactiveFg,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.1,
                    color: isActive ? activeFg : inactiveFg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(color: borderCol, width: 1),
          ),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            buildNavItem(
                0, Icons.dashboard, 'DASHBOARD', AppRoute.staffDashboard.path),
            buildNavItem(1, Icons.group, 'CLIENTS', AppRoute.staffClients.path),
            buildNavItem(
                2, Icons.bolt, 'SESSIONS', AppRoute.staffLiveSessions.path),
            buildNavItem(
                3, Icons.person, 'PROFILE', AppRoute.staffProfile.path),
          ],
        ),
      ),
    );
  }
}
