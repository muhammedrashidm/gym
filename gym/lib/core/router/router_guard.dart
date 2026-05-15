import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/auth/presentation/cubit/session_state.dart';
import '../../features/auth/domain/entities/user_role.dart';
import 'app_routes.dart';

class RouterGuard {
  final AuthCubit authCubit;
  final SessionCubit sessionCubit;

  const RouterGuard(this.authCubit, this.sessionCubit);

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = authCubit.state;
    final sessionState = sessionCubit.state;
    final isAuthenticated = authState is AuthAuthenticated;
    final isAuthRoute = state.matchedLocation == AppRoute.login.path ||
        state.matchedLocation == AppRoute.otp.path;
    final isSplashRoute = state.matchedLocation == AppRoute.splash.path;
    final isSelectWorkspaceRoute = state.matchedLocation == AppRoute.selectWorkspace.path;

    if (authState is AuthInitial) {
      if (!isSplashRoute) return AppRoute.splash.path;
      return null;
    }

    if (!isAuthenticated && !isAuthRoute) {
      return AppRoute.login.path;
    }

    if (isAuthenticated) {
      if (sessionState is SessionLoaded) {
        final activeRole = sessionState.activeRole;
        final availableRoles = sessionState.availableRoles;

        if (availableRoles.isEmpty) {
          // TODO: Redirect to a NoAccess page instead of login if 0 roles
          return AppRoute.login.path; 
        }

        if (activeRole == null) {
          if (!isSelectWorkspaceRoute) return AppRoute.selectWorkspace.path;
          return null; // Stay on workspace selection
        }

        // We have an active role
        final roleEnum = activeRole.roleEnum;
        
        // Prevent going back to login/splash/select workspace if already active
        if (isAuthRoute || isSplashRoute || isSelectWorkspaceRoute) {
          if (roleEnum == Role.member) return AppRoute.member.path;
          if (roleEnum == Role.staff) return AppRoute.staff.path;
        }

        // Prevent accessing member route if staff, or staff route if member
        final isMemberRoute = state.matchedLocation.startsWith(AppRoute.member.path);
        final isStaffRoute = state.matchedLocation.startsWith(AppRoute.staff.path);

        if (isMemberRoute && roleEnum != Role.member) return AppRoute.staff.path;
        if (isStaffRoute && roleEnum != Role.staff) return AppRoute.member.path;

        return null; // Let them proceed
      } else {
        // If Session is Initial but Auth is Authenticated, stay on splash while it processes
        if (!isSplashRoute) return AppRoute.splash.path;
      }
    }

    return null;
  }
}
