import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/domain/entities/user_role.dart';
import 'app_routes.dart';

class RouterGuard {
  final AuthCubit authCubit;

  const RouterGuard(this.authCubit);

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = authCubit.state;

    final isAuthRoute = state.matchedLocation == AppRoute.login.path ||
        state.matchedLocation == AppRoute.otp.path;
    final isSplashRoute = state.matchedLocation == AppRoute.splash.path;
    final isSelectWorkspaceRoute =
        state.matchedLocation == AppRoute.selectWorkspace.path;
    final isTrainerSignupRoute =
        state.matchedLocation == AppRoute.trainerSignup.path;

    // ── Startup: stay on splash until loadAuthState() finishes ──────────────
    if (authState is AuthInitial || authState is AuthCheckingToken) {
      if (!isSplashRoute) return AppRoute.splash.path;
      return null;
    }

    // ── Unauthenticated / Error ──────────────────────────────────────────────
    if (authState is AuthUnauthenticated || authState is AuthError) {
      if (!isAuthRoute) return AppRoute.login.path;
      return null;
    }

    // ── OTP sent ─────────────────────────────────────────────────────────────
    if (authState is AuthOtpSent) {
      return null; // OtpPage handles itself
    }

    // ── Authenticated ────────────────────────────────────────────────────────
    if (authState is AuthAuthenticated) {
      final activeRole = authState.activeRole;
      final availableRoles = authState.availableRoles;
      final roleEnum = activeRole.roleEnum;

      final hasStaffRole =
          availableRoles.any((r) => r.roleEnum == Role.staff);

      // Trainer-signup: only members who haven't become staff yet may enter
      if (isTrainerSignupRoute) {
        return hasStaffRole ? AppRoute.staff.path : null;
      }

      // Workspace-selection: only needed when user has multiple roles and
      // hasn't made a choice yet (handled by the user explicitly navigating here)
      if (isSelectWorkspaceRoute) return null;

      // Already authenticated — bounce off auth/splash screens to the active workspace
      if (isAuthRoute || isSplashRoute) {
        if (roleEnum == Role.member) return AppRoute.member.path;
        if (roleEnum == Role.staff) return AppRoute.staff.path;
      }

      // Prevent accessing the wrong workspace shell
      final isMemberRoute =
          state.matchedLocation.startsWith(AppRoute.member.path);
      final isStaffRoute =
          state.matchedLocation.startsWith(AppRoute.staff.path);

      if (isMemberRoute && roleEnum != Role.member) return AppRoute.staff.path;
      if (isStaffRoute && roleEnum != Role.staff) return AppRoute.member.path;

      return null; // All good — let the navigation proceed
    }

    return null;
  }
}
