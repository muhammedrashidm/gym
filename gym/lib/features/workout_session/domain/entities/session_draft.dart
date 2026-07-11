import 'package:freezed_annotation/freezed_annotation.dart';
import 'task_completion_draft.dart';

part 'session_draft.freezed.dart';

@freezed
class SessionDraft with _$SessionDraft {
  const factory SessionDraft({
    required String workoutProfileId,
    required String clientProfileId,
    required int dayIndexAtTime,
    String? dayPlanId,
    String? dayPlanLabel,
    String? weeklyPlanName,
    required DateTime startedAt,
    String? sessionNotes,
    @Default(false) bool isTrainerInitiated,
    @Default([]) List<TaskCompletionDraft> taskDrafts,
  }) = _SessionDraft;
}
