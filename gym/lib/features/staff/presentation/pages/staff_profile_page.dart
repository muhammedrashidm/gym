import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/domain/entities/user_role.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';

class StaffProfilePage extends StatelessWidget {
  const StaffProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: const _StaffProfileView(),
    );
  }
}

class _StaffProfileView extends StatelessWidget {
  const _StaffProfileView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-specific colors
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final mutedColor =
        isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);
    final borderCol =
        isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'TRAINER PROFILE',
          style: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }
          if (state is ProfileLoaded) {
            final profile = state.profile;
            final fullName =
                '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim();
            final displayName = fullName.isNotEmpty ? fullName : 'TRAINER';

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Profile Header Card
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: borderCol, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius
                              .zero, // Sharp profile photo container
                        ),
                        child: Center(
                          child: Text(
                            displayName.substring(0, 1).toUpperCase(),
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SENIOR PERFORMANCE COACH',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                                color: mutedColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              profile.phoneNumber,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: mutedColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Specializations Section
                _buildSectionHeader(
                    title: 'SPECIALIZATIONS & CERTIFICATIONS',
                    mutedColor: mutedColor),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: borderCol, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['STRENGTH', 'HIIT', 'CROSSFIT', 'NUTRITION']
                            .map((spec) {
                          return Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFE2E2E2),
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Text(
                              spec,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                                color: textColor,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CERTIFIED ATHLETIC TRAINER (CAT)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'National Board of Fitness Examiners • Exp. Dec 2027',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: mutedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Switch Workspace / Roles Section
                BlocBuilder<AuthCubit, AuthState>(
                  bloc: getIt<AuthCubit>(),
                  builder: (context, authState) {
                    if (authState is AuthAuthenticated) {
                      final memberRole = authState.availableRoles
                          .where((r) => r.roleEnum == Role.member)
                          .firstOrNull;

                      if (memberRole != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                                title: 'SWITCH WORKSPACE',
                                mutedColor: mutedColor),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                border: Border.all(color: borderCol, width: 1),
                                borderRadius: BorderRadius.zero,
                              ),
                              child: ListTile(
                                leading:
                                    Icon(Icons.swap_horiz, color: textColor),
                                title: Text(
                                  'SWITCH TO MEMBER VIEW',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  'Access your personal workout plans and recovery tracking',
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: mutedColor),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios,
                                    size: 14, color: textColor),
                                onTap: () {
                                  getIt<AuthCubit>().selectRole(memberRole);
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      }
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Account Actions Section
                _buildSectionHeader(
                    title: 'ACCOUNT ACTIONS', mutedColor: mutedColor),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    border: Border.all(color: borderCol, width: 1),
                    borderRadius: BorderRadius.zero,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.edit_outlined, color: textColor),
                        title: Text(
                          'EDIT PROFILE DETAILS',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: textColor,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 14, color: textColor),
                        onTap: () {},
                      ),
                      Divider(height: 1, thickness: 0.5, color: borderCol),
                      ListTile(
                        leading:
                            const Icon(Icons.logout, color: Colors.redAccent),
                        title: Text(
                          'LOG OUT',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                            color: Colors.redAccent,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.redAccent),
                        onTap: () async {
                          await getIt<AuthCubit>().logout();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.inter(color: Colors.redAccent),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(
      {required String title, required Color mutedColor}) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2.0,
        color: mutedColor,
      ),
    );
  }
}
