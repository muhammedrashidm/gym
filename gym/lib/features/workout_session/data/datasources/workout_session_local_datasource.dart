import 'dart:async';
import 'package:injectable/injectable.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/session_draft.dart';
import '../../domain/entities/task_completion_draft.dart';

/// Local staging store for in-progress workout sessions, backed by
/// [AppDatabase] (sqflite). Plain sqflite has no built-in change
/// notification, so this class fires a broadcast signal after every write
/// and `watchDraft`/`watchAllActiveDrafts` re-query on each signal — a
/// standard "poll-on-write" reactivity pattern for a non-reactive local DB.
@singleton
class WorkoutSessionLocalDataSource {
  final AppDatabase _db;
  final _changes = StreamController<void>.broadcast();

  WorkoutSessionLocalDataSource(this._db);

  /// Upsert session header row. Idempotent — reopening an in-progress session resumes.
  Future<void> startOrResumeDraft(SessionDraft draft) async {
    await _db.upsertSessionDraft(
      workoutProfileId: draft.workoutProfileId,
      clientProfileId: draft.clientProfileId,
      dayIndexAtTime: draft.dayIndexAtTime,
      dayPlanId: draft.dayPlanId,
      dayPlanLabel: draft.dayPlanLabel,
      weeklyPlanName: draft.weeklyPlanName,
      startedAt: draft.startedAt,
      sessionNotes: draft.sessionNotes,
      isTrainerInitiated: draft.isTrainerInitiated,
    );
    _changes.add(null);
  }

  /// Save or update a single task's actuals (called on every field change).
  Future<void> upsertTaskCompletion(TaskCompletionDraft draft) async {
    await _db.upsertTaskCompletionDraft(
      id: draft.id,
      workoutProfileId: draft.workoutProfileId,
      taskId: draft.taskId,
      actualSets: draft.actualSets,
      actualReps: draft.actualReps,
      actualWeightKg: draft.actualWeightKg,
      notes: draft.notes,
    );
    _changes.add(null);
  }

  /// Stream of a single profile's draft + all its task completions.
  Stream<SessionDraft?> watchDraft(String workoutProfileId) async* {
    yield await _loadDraft(workoutProfileId);
    yield* _changes.stream.asyncMap((_) => _loadDraft(workoutProfileId));
  }

  /// Stream of ALL in-progress drafts on this device (trainer use).
  Stream<List<SessionDraft>> watchAllActiveDrafts() async* {
    yield await _loadAllDrafts();
    yield* _changes.stream.asyncMap((_) => _loadAllDrafts());
  }

  /// Delete header + cascade task drafts after successful submit.
  Future<void> clearDraft(String workoutProfileId) async {
    await _db.deleteSessionDraft(workoutProfileId);
    _changes.add(null);
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<SessionDraft?> _loadDraft(String workoutProfileId) async {
    final row = await _db.getSessionDraft(workoutProfileId);
    if (row == null) return null;
    final tasks = await _db.getTaskCompletionDrafts(workoutProfileId);
    return _rowToDomain(row, tasks);
  }

  Future<List<SessionDraft>> _loadAllDrafts() async {
    final rows = await _db.getAllSessionDrafts();
    final result = <SessionDraft>[];
    for (final row in rows) {
      final tasks = await _db
          .getTaskCompletionDrafts(row['workout_profile_id'] as String);
      result.add(_rowToDomain(row, tasks));
    }
    return result;
  }

  SessionDraft _rowToDomain(
    Map<String, dynamic> row,
    List<Map<String, dynamic>> tasks,
  ) {
    return SessionDraft(
      workoutProfileId: row['workout_profile_id'] as String,
      clientProfileId: row['client_profile_id'] as String,
      dayIndexAtTime: row['day_index_at_time'] as int,
      dayPlanId: row['day_plan_id'] as String?,
      dayPlanLabel: row['day_plan_label'] as String?,
      weeklyPlanName: row['weekly_plan_name'] as String?,
      startedAt: DateTime.fromMillisecondsSinceEpoch(row['started_at'] as int),
      sessionNotes: row['session_notes'] as String?,
      isTrainerInitiated: (row['is_trainer_initiated'] as int) == 1,
      taskDrafts: tasks
          .map(
            (t) => TaskCompletionDraft(
              id: t['id'] as String,
              workoutProfileId: t['workout_profile_id'] as String,
              taskId: t['task_id'] as String,
              actualSets: t['actual_sets'] as int?,
              actualReps: t['actual_reps'] as String?,
              actualWeightKg: (t['actual_weight_kg'] as num?)?.toDouble(),
              notes: t['notes'] as String?,
              updatedAt: t['updated_at'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(t['updated_at'] as int)
                  : null,
            ),
          )
          .toList(),
    );
  }

  Future<void> dispose() => _changes.close();
}
