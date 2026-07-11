import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileLoaded) {
            final profile = state.profile;
            final authState = context.watch<AuthCubit>().state;
            final showBecomeTrainer = authState is AuthAuthenticated &&
                !authState.availableRoles.any((r) => r.roleEnum == Role.staff);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    profile.firstName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  title: const Text('Name'),
                  subtitle: Text('${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim()),
                ),
                ListTile(
                  title: const Text('Phone Number'),
                  subtitle: Text(profile.phoneNumber),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.qr_code_scanner),
                    title: const Text(
                      'CONNECT TO TRAINER',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    subtitle: const Text(
                      'Scan a trainer\'s QR code to link your account',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      context.push(AppRoute.clientScanner.path);
                    },
                  ),
                ),
                if (showBecomeTrainer) ...[
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF131313), // Deep ink black
                      borderRadius: BorderRadius.circular(0), // Sharp 0px corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'JOIN THE SANCTUARY',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2.0,
                            color: Color(0xFFc4c7c8), // Muted grey
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'BECOME A TRAINER',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Share your experience, upload your certificates, and guide others to peak performance.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            height: 1.5,
                            color: Color(0xFFc4c7c8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero, // 0px radius
                              ),
                            ),
                            onPressed: () => context.push(AppRoute.trainerSignup.path),
                            child: const Text(
                              'APPLY NOW',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (authState is AuthAuthenticated) ...[
                  for (final role in authState.availableRoles)
                    if (role.roleEnum == Role.staff) ...[
                      const SizedBox(height: 32),
                      const Text(
                        'SWITCH WORKSPACE',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.zero,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.swap_horiz),
                          title: const Text(
                            'SWITCH TO TRAINER VIEW',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                          subtitle: const Text(
                            'Manage clients, sessions, and track gym statistics',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 11),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () {
                            context.read<AuthCubit>().selectRole(role);
                          },
                        ),
                      ),
                    ],
                ],
              ],
            );
          }
          if (state is ProfileError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
