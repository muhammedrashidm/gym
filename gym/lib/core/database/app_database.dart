import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

@singleton
class AppDatabase {
  Database? _db;

  Future<Database> get db async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = p.join(dbFolder.path, 'gym_session.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS session_drafts (
            workout_profile_id TEXT PRIMARY KEY,
            client_profile_id TEXT NOT NULL,
            day_index_at_time INTEGER NOT NULL,
            day_plan_id TEXT,
            day_plan_label TEXT,
            weekly_plan_name TEXT,
            started_at INTEGER NOT NULL,
            session_notes TEXT,
            is_trainer_initiated INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS task_completion_drafts (
            id TEXT PRIMARY KEY,
            workout_profile_id TEXT NOT NULL REFERENCES session_drafts(workout_profile_id),
            task_id TEXT NOT NULL,
            actual_sets INTEGER,
            actual_reps TEXT,
            actual_weight_kg REAL,
            notes TEXT,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  // ─── Session Drafts ───────────────────────────────────────────────────────

  Future<void> upsertSessionDraft({
    required String workoutProfileId,
    required String clientProfileId,
    required int dayIndexAtTime,
    String? dayPlanId,
    String? dayPlanLabel,
    String? weeklyPlanName,
    required DateTime startedAt,
    String? sessionNotes,
    bool isTrainerInitiated = false,
  }) async {
    final database = await db;
    await database.insert(
      'session_drafts',
      {
        'workout_profile_id': workoutProfileId,
        'client_profile_id': clientProfileId,
        'day_index_at_time': dayIndexAtTime,
        'day_plan_id': dayPlanId,
        'day_plan_label': dayPlanLabel,
        'weekly_plan_name': weeklyPlanName,
        'started_at': startedAt.millisecondsSinceEpoch,
        'session_notes': sessionNotes,
        'is_trainer_initiated': isTrainerInitiated ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSessionDraft(
      String workoutProfileId) async {
    final database = await db;
    final rows = await database.query(
      'session_drafts',
      where: 'workout_profile_id = ?',
      whereArgs: [workoutProfileId],
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, dynamic>>> getAllSessionDrafts() async {
    final database = await db;
    return database.query('session_drafts');
  }

  Future<void> deleteSessionDraft(String workoutProfileId) async {
    final database = await db;
    await database.delete(
      'task_completion_drafts',
      where: 'workout_profile_id = ?',
      whereArgs: [workoutProfileId],
    );
    await database.delete(
      'session_drafts',
      where: 'workout_profile_id = ?',
      whereArgs: [workoutProfileId],
    );
  }

  // ─── Task Completion Drafts ────────────────────────────────────────────────

  Future<void> upsertTaskCompletionDraft({
    required String id,
    required String workoutProfileId,
    required String taskId,
    int? actualSets,
    String? actualReps,
    double? actualWeightKg,
    String? notes,
  }) async {
    final database = await db;
    // Try to find existing by workoutProfileId + taskId
    final existing = await database.query(
      'task_completion_drafts',
      where: 'workout_profile_id = ? AND task_id = ?',
      whereArgs: [workoutProfileId, taskId],
    );

    if (existing.isNotEmpty) {
      await database.update(
        'task_completion_drafts',
        {
          'actual_sets': actualSets,
          'actual_reps': actualReps,
          'actual_weight_kg': actualWeightKg,
          'notes': notes,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'workout_profile_id = ? AND task_id = ?',
        whereArgs: [workoutProfileId, taskId],
      );
    } else {
      await database.insert(
        'task_completion_drafts',
        {
          'id': id,
          'workout_profile_id': workoutProfileId,
          'task_id': taskId,
          'actual_sets': actualSets,
          'actual_reps': actualReps,
          'actual_weight_kg': actualWeightKg,
          'notes': notes,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
      );
    }
  }

  Future<List<Map<String, dynamic>>> getTaskCompletionDrafts(
      String workoutProfileId) async {
    final database = await db;
    return database.query(
      'task_completion_drafts',
      where: 'workout_profile_id = ?',
      whereArgs: [workoutProfileId],
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
