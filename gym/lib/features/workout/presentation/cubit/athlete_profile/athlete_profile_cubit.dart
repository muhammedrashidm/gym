import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/error/failures.dart';
import '../../../domain/entities/workout_profile.dart';
import '../../../domain/entities/weekly_plan.dart';
import '../../../domain/usecases/manage_workout_profiles.dart';
import '../../../domain/usecases/manage_weekly_plans.dart';
import 'athlete_profile_state.dart';

class AthleteProfileCubit extends Cubit<AthleteProfileState> {
  final Mediator _mediator;

  AthleteProfileCubit(this._mediator) : super(const AthleteProfileState.initial());

  Future<void> loadProfile(String clientId) async {
    emit(const AthleteProfileState.loading());
    await _fetchProfileData(clientId);
  }

  Future<void> createWeeklyPlan({
    required String clientId,
    required String workoutProfileId,
    required String name,
    String? notes,
  }) async {
    final result = await _mediator.sendCommand(
      CreateWeeklyPlanCommand(
        workoutProfileId: workoutProfileId,
        name: name,
        notes: notes,
      ),
    ) as Either<Failure, WeeklyPlan>;

    await result.fold(
      (failure) async {
        emit(AthleteProfileState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchProfileData(clientId);
      },
    );
  }

  Future<void> activateWeeklyPlan({
    required String clientId,
    required String weeklyPlanId,
  }) async {
    final result = await _mediator.sendCommand(
      ActivateWeeklyPlanCommand(weeklyPlanId),
    ) as Either<Failure, WeeklyPlan>;

    await result.fold(
      (failure) async {
        emit(AthleteProfileState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchProfileData(clientId);
      },
    );
  }

  Future<void> deactivateProfile({
    required String clientId,
    required String profileId,
  }) async {
    final result = await _mediator.sendCommand(
      UpdateWorkoutProfileCommand(id: profileId, isActive: false),
    ) as Either<Failure, WorkoutProfile>;

    await result.fold(
      (failure) async {
        emit(AthleteProfileState.error(_mapFailureToMessage(failure)));
      },
      (_) async {
        await _fetchProfileData(clientId);
      },
    );
  }

  Future<void> _fetchProfileData(String clientId) async {
    final profilesResult = await _mediator.sendCommand(
      GetWorkoutProfilesQuery(clientId),
    ) as Either<Failure, List<WorkoutProfile>>;

    await profilesResult.fold(
      (failure) async {
        emit(AthleteProfileState.error(_mapFailureToMessage(failure)));
      },
      (profiles) async {
        final activeProfile = profiles.where((p) => p.isActive).firstOrNull;
        List<WeeklyPlan> weeklyPlans = [];

        if (activeProfile != null) {
          final plansResult = await _mediator.sendCommand(
            GetWeeklyPlansQuery(activeProfile.id),
          ) as Either<Failure, List<WeeklyPlan>>;

          plansResult.fold(
            (failure) {
              emit(AthleteProfileState.error(_mapFailureToMessage(failure)));
            },
            (plans) {
              weeklyPlans = plans;
            },
          );
        }

        if (state is! AthleteProfileError) {
          emit(AthleteProfileState.loaded(
            profiles: profiles,
            activeProfile: activeProfile,
            weeklyPlans: weeklyPlans,
          ));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.maybeWhen(
      server: (_, msg) => msg,
      network: (msg) => msg ?? 'Network error.',
      unknown: (msg) => msg ?? 'Unknown error.',
      unauthorized: () => 'Unauthorized.',
      orElse: () => 'Unexpected error.',
    );
  }
}
