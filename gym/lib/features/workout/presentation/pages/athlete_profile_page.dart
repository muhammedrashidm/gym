import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gym/core/router/app_routes.dart';
import 'package:gym/features/workout/domain/entities/weekly_plan.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/workout_profile.dart';
import '../cubit/athlete_profile/athlete_profile_cubit.dart';
import '../cubit/athlete_profile/athlete_profile_state.dart';

class AthleteProfilePage extends StatelessWidget {
  final String clientId;

  const AthleteProfilePage({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AthleteProfileCubit(getIt())..loadProfile(clientId),
      child: AthleteProfileView(clientId: clientId),
    );
  }
}

class AthleteProfileView extends StatelessWidget {
  final String clientId;

  const AthleteProfileView({
    super.key,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131313) : const Color(0xFFF9F9F9);
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderCol = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE2E2E2);
    final mutedColor = isDark ? const Color(0xFFA3A3A3) : const Color(0xFF5F5E5E);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'ATHLETE WORKOUT',
          style: GoogleFonts.manrope(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: BlocBuilder<AthleteProfileCubit, AthleteProfileState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ERROR LOADING PROGRAM',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.redAccent,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(fontSize: 10, color: mutedColor),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: cardColor,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () => context.read<AthleteProfileCubit>().loadProfile(clientId),
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
            ),
            loaded: (profiles, activeProfile, weeklyPlans) {
              final pastProfiles = profiles.where((p) => !p.isActive).toList();

              return RefreshIndicator(
                onRefresh: () => context.read<AthleteProfileCubit>().loadProfile(clientId),
                color: textColor,
                backgroundColor: cardColor,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Profile / Program Section
                      Text(
                        'CURRENT PROGRAM',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: mutedColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (activeProfile != null)
                        _buildActiveProfileCard(
                          context: context,
                          profile: activeProfile,
                          weeklyPlans: weeklyPlans,
                          cardColor: cardColor,
                          textColor: textColor,
                          mutedColor: mutedColor,
                          borderCol: borderCol,
                          isDark: isDark,
                        )
                      else
                        _buildEmptyActiveProfileCard(context, cardColor, textColor, borderCol, mutedColor),

                      const SizedBox(height: 32),

                      // Past Profiles Section
                      if (pastProfiles.isNotEmpty) ...[
                        Text(
                          'PAST WORKOUT PROFILES',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: mutedColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...pastProfiles.map(
                          (p) => _buildPastProfileCard(p, cardColor, textColor, borderCol, mutedColor),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActiveProfileCard({
    required BuildContext context,
    required WorkoutProfile profile,
    required List<WeeklyPlan> weeklyPlans,
    required Color cardColor,
    required Color textColor,
    required Color mutedColor,
    required Color borderCol,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NAME",
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'STARTED: DATE',
                      style: GoogleFonts.inter(fontSize: 10, color: mutedColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _confirmDeactivate(context, profile.id),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.zero,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'END PROGRAM',
                    style: GoogleFonts.inter(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WEEKS / PHASES',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await context.push(
                    '/staff/clients/$clientId/workout/workout-profile/${profile.id}/weekly-plan/new',
                  );
                  if (context.mounted) {
                    context.read<AthleteProfileCubit>().loadProfile(clientId);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.add, size: 14, color: textColor),
                    const SizedBox(width: 2),
                    Text(
                      'ADD WEEK',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (weeklyPlans.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  'NO WEEKLY PLANS CREATED YET',
                  style: GoogleFonts.inter(fontSize: 10, color: mutedColor, fontWeight: FontWeight.w800),
                ),
              ),
            )
          else
            ListView.builder(
              
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weeklyPlans.length,
              itemBuilder: (context, index) {
                final plan = weeklyPlans[index];

                return GestureDetector(
                  key: Key(index.toString()),
                  onTap: (){
                    context.push(AppRoute.train.path);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F1F1),
                      border: Border.all(color: borderCol),
                      borderRadius: BorderRadius.zero,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                              if (plan.notes != null && plan.notes!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  plan.notes!,
                                  style: GoogleFonts.inter(fontSize: 10, color: mutedColor),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            if (plan.status == 'ACTIVE')
                              Container(
                                decoration: const BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                child: Text(
                                  'ACTIVE',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () {
                                  context.read<AthleteProfileCubit>().activateWeeklyPlan(
                                        clientId: clientId,
                                        weeklyPlanId: plan.id,
                                      );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: textColor),
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  child: Text(
                                    'ACTIVATE',
                                    style: GoogleFonts.inter(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                context.push('/staff/clients/$clientId/workout/weekly-plan/${plan.id}/edit');
                              },
                              child: Container(
                                color: textColor,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Icon(
                                  Icons.edit,
                                  size: 12,
                                  color: cardColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyActiveProfileCard(
    BuildContext context,
    Color cardColor,
    Color textColor,
    Color borderCol,
    Color mutedColor,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.fitness_center, size: 48, color: mutedColor),
          const SizedBox(height: 16),
          Text(
            'NO ACTIVE WORKOUT PROGRAM',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a workout profile to schedule training phases.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 10, color: mutedColor),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () async {
              await context.push('/staff/clients/$clientId/workout/create');
              if (context.mounted) {
                context.read<AthleteProfileCubit>().loadProfile(clientId);
              }
            },
            child: Container(
              color: textColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'INITIATE PROGRAM',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: cardColor,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPastProfileCard(
    dynamic profile,
    Color cardColor,
    Color textColor,
    Color borderCol,
    Color mutedColor,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.6),
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.zero,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                profile.name.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: textColor.withValues(alpha: 0.7),
                  letterSpacing: -0.2,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderCol),
                  borderRadius: BorderRadius.zero,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Text(
                  'COMPLETED',
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: mutedColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'STARTED: ${profile.startDate.split('T')[0]}',
            style: GoogleFonts.inter(fontSize: 10, color: mutedColor),
          ),
        ],
      ),
    );
  }

  void _confirmDeactivate(BuildContext context, String profileId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'END CURRENT PROGRAM',
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Text(
          'Are you sure you want to end this training program? You cannot reactivate it later.',
          style: GoogleFonts.inter(fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AthleteProfileCubit>().deactivateProfile(
                    clientId: clientId,
                    profileId: profileId,
                  );
            },
            child: Text(
              'END PROGRAM',
              style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
