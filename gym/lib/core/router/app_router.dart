import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/auth/presentation/pages/workspace_selection_page.dart';
import 'app_routes.dart';
import 'router_guard.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/member/presentation/pages/explore_page.dart';
import '../../features/member/presentation/pages/train_page.dart';
import '../../features/member/presentation/pages/recovery_page.dart';
import '../../features/member/presentation/pages/profile_page.dart';

@singleton
class AppRouter {
  final AuthCubit _authCubit;
  final SessionCubit _sessionCubit;
  late final GoRouter router;

  AppRouter(this._authCubit, this._sessionCubit) {
    final guard = RouterGuard(_authCubit, _sessionCubit);

    router = GoRouter(
      initialLocation: AppRoute.splash.path,
      redirect: guard.redirect,
      refreshListenable: GoRouterAuthNotifier(_authCubit, _sessionCubit),
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
        ShellRoute(
          builder: (context, state, child) => _MemberShell(child: child),
          routes: [
            GoRoute(
              path: AppRoute.member.path,
              name: AppRoute.member.name,
              redirect: (context, state) => AppRoute.explore.path,
            ),
            GoRoute(
              path: AppRoute.explore.path,
              name: AppRoute.explore.name,
              builder: (context, state) => const ExplorePage(),
            ),
            GoRoute(
              path: AppRoute.train.path,
              name: AppRoute.train.name,
              builder: (context, state) => const TrainPage(),
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
          builder: (context, state, child) => _StaffShell(child: child),
          routes: [
            GoRoute(
              path: AppRoute.staff.path,
              name: AppRoute.staff.name,
              builder: (context, state) => const _PlaceholderPage(title: 'Staff Dashboard'),
            ),
          ],
        ),
      ],
    );
  }
}

class GoRouterAuthNotifier extends ChangeNotifier {
  late final List<dynamic> _subscriptions;

  GoRouterAuthNotifier(AuthCubit authCubit, SessionCubit sessionCubit) {
    _subscriptions = [
      authCubit.stream.listen((_) => notifyListeners()),
      sessionCubit.stream.listen((_) => notifyListeners()),
    ];
  }

  @override
  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
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
    final inactiveFg = isDark ? const Color(0xFFA1A1A1) : const Color(0xFF5F5E5E);

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
                  colorFilter: ColorFilter.mode(isActive ? activeFg : inactiveFg, BlendMode.srcIn),
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
      floatingActionButton: FloatingActionButton(onPressed: (){}),
      body: child,
      bottomNavigationBar: Container(
        color: bgColor,
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          children: [
            buildNavItem(0, 'map', 'EXPLORE', AppRoute.explore.path),
            buildNavItem(1, 'fitness_center', 'TRAIN', AppRoute.train.path),
            buildNavItem(2, 'self_improvement', 'RECOVERY', AppRoute.recovery.path),
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
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Members'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedIndex: 0,
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}
