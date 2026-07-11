import 'package:injectable/injectable.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/value_objects/draft_day_plan.dart';
import '../models/workout_profile_model.dart';
import '../models/weekly_plan_model.dart';
import '../models/day_plan_model.dart';
import '../models/task_model.dart';
import '../../../workout_session/data/models/workout_session_log_model.dart';
import '../../../workout_session/domain/entities/task_completion_draft.dart';

abstract interface class WorkoutRemoteDataSource {
  Future<List<WorkoutProfileModel>> getWorkoutProfiles(String? clientProfileId);

  Future<WorkoutProfileModel> createWorkoutProfile({
    required String clientProfileId,
    required String name,
    required String startDate,
  });

  Future<WorkoutProfileModel> updateWorkoutProfile({
    required String id,
    bool? isActive,
    int? currentDayIndex,
  });

  Future<WeeklyPlanModel> createWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
  });

  Future<WeeklyPlanModel> createFullWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
    bool activateImmediately = false,
    required List<DraftDayPlan> days,
  });

  Future<List<WeeklyPlanModel>> getWeeklyPlans(String workoutProfileId);

  Future<WeeklyPlanModel> getWeeklyPlanDetails(String weeklyPlanId);

  Future<WeeklyPlanModel> activateWeeklyPlan(String weeklyPlanId);

  Future<DayPlanModel> getDayPlanDetails(String dayPlanId);

  Future<DayPlanModel?> getTodayPlan(String workoutProfileId);

  Future<DayPlanModel> updateDayPlan({
    required String dayPlanId,
    String? label,
    bool? isRestDay,
  });

  Future<TaskModel> createTask({
    required String dayPlanId,
    required String name,
    required int sets,
    required String reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    required int sequenceIndex,
  });

  Future<TaskModel> updateTask({
    required String taskId,
    String? name,
    int? sets,
    String? reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    int? sequenceIndex,
  });

  Future<void> deleteTask(String taskId);

  // ─── Session submission ───────────────────────────────────────────────────

  Future<WorkoutSessionLogModel> completeSession(
    String workoutProfileId, {
    List<TaskCompletionInput>? taskCompletions,
    String? notes,
  });

  Future<WorkoutSessionLogModel> skipSession(
    String workoutProfileId, {
    String? reason,
  });

  Future<({List<WorkoutSessionLogModel> logs, int total, int page, int pageSize})> getSessionLogs(
    String workoutProfileId, {
    int page = 1,
    int pageSize = 20,
  });
}

@Singleton(as: WorkoutRemoteDataSource)
class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final ApiClient _apiClient;

  const WorkoutRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<WorkoutProfileModel>> getWorkoutProfiles(String? clientProfileId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/workout-profiles',
      queryParameters: {
        if (clientProfileId != null) 'clientProfileId': clientProfileId,
      },
    );
    final data = response.data?['profiles'] as List<dynamic>? ?? [];
    return data.map((json) => WorkoutProfileModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<WorkoutProfileModel> createWorkoutProfile({
    required String clientProfileId,
    required String name,
    required String startDate,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/workout-profiles',
      data: {
        'clientProfileId': clientProfileId,
        'name': name,
        'startDate': startDate,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return WorkoutProfileModel.fromJson(data);
  }

  @override
  Future<WorkoutProfileModel> updateWorkoutProfile({
    required String id,
    bool? isActive,
    int? currentDayIndex,
  }) async {
    final Map<String, dynamic> data = {};
    if (isActive != null) data['isActive'] = isActive;
    if (currentDayIndex != null) data['currentDayIndex'] = currentDayIndex;

    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/workout-profiles/$id',
      data: data,
    );
    final responseData = response.data?['data'] as Map<String, dynamic>;
    return WorkoutProfileModel.fromJson(responseData);
  }

  @override
  Future<WeeklyPlanModel> createWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/workout-profiles/$workoutProfileId/weekly-plans',
      data: {
        'name': name,
        if (notes != null) 'notes': notes,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return WeeklyPlanModel.fromJson(data);
  }

  @override
  Future<WeeklyPlanModel> createFullWeeklyPlan({
    required String workoutProfileId,
    required String name,
    String? notes,
    bool activateImmediately = false,
    required List<DraftDayPlan> days,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/workout-profiles/$workoutProfileId/weekly-plans',
      data: {
        'name': name,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'activateImmediately': activateImmediately,
        'days': days.map((d) => d.toJson()).toList(),
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return WeeklyPlanModel.fromJson(data);
  }

  @override
  Future<List<WeeklyPlanModel>> getWeeklyPlans(String workoutProfileId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/workout-profiles/$workoutProfileId/weekly-plans',
    );
    final data = response.data?['plans'] as List<dynamic>? ?? [];
    return data.map((json) => WeeklyPlanModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<WeeklyPlanModel> getWeeklyPlanDetails(String weeklyPlanId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/weekly-plans/$weeklyPlanId',
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return WeeklyPlanModel.fromJson(data);
  }

  @override
  Future<WeeklyPlanModel> activateWeeklyPlan(String weeklyPlanId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/weekly-plans/$weeklyPlanId/activate',
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return WeeklyPlanModel.fromJson(data);
  }

  @override
  Future<DayPlanModel> getDayPlanDetails(String dayPlanId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/day-plans/$dayPlanId',
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return DayPlanModel.fromJson(data);
  }

  @override
  Future<DayPlanModel?> getTodayPlan(String workoutProfileId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/workout-profiles/$workoutProfileId/today',
    );
    final data = response.data?['data'] as Map<String, dynamic>?;
    return data == null ? null : DayPlanModel.fromJson(data);
  }

  @override
  Future<DayPlanModel> updateDayPlan({
    required String dayPlanId,
    String? label,
    bool? isRestDay,
  }) async {
    final Map<String, dynamic> data = {};
    if (label != null) data['label'] = label;
    if (isRestDay != null) data['isRestDay'] = isRestDay;

    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/day-plans/$dayPlanId',
      data: data,
    );
    final responseData = response.data?['data'] as Map<String, dynamic>;
    return DayPlanModel.fromJson(responseData);
  }

  @override
  Future<TaskModel> createTask({
    required String dayPlanId,
    required String name,
    required int sets,
    required String reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    required int sequenceIndex,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/day-plans/$dayPlanId/tasks',
      data: {
        'name': name,
        'sets': sets,
        'reps': reps,
        if (restSeconds != null) 'restSeconds': restSeconds,
        if (tempo != null) 'tempo': tempo,
        if (machineDetails != null) 'machineDetails': machineDetails,
        if (notes != null) 'notes': notes,
        'sequenceIndex': sequenceIndex,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return TaskModel.fromJson(data);
  }

  @override
  Future<TaskModel> updateTask({
    required String taskId,
    String? name,
    int? sets,
    String? reps,
    int? restSeconds,
    String? tempo,
    String? machineDetails,
    String? notes,
    int? sequenceIndex,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (sets != null) data['sets'] = sets;
    if (reps != null) data['reps'] = reps;
    if (restSeconds != null) data['restSeconds'] = restSeconds;
    if (tempo != null) data['tempo'] = tempo;
    if (machineDetails != null) data['machineDetails'] = machineDetails;
    if (notes != null) data['notes'] = notes;
    if (sequenceIndex != null) data['sequenceIndex'] = sequenceIndex;

    final response = await _apiClient.patch<Map<String, dynamic>>(
      '/tasks/$taskId',
      data: data,
    );
    final responseData = response.data?['data'] as Map<String, dynamic>;
    return TaskModel.fromJson(responseData);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _apiClient.delete<Map<String, dynamic>>(
      '/tasks/$taskId',
    );
  }

  // ─── Session submission ───────────────────────────────────────────────────

  @override
  Future<WorkoutSessionLogModel> completeSession(
    String workoutProfileId, {
    List<TaskCompletionInput>? taskCompletions,
    String? notes,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/workout-profiles/$workoutProfileId/sessions/complete',
      data: {
        if (taskCompletions != null)
          'taskCompletions': taskCompletions.map((t) => t.toJson()).toList(),
        if (notes != null) 'notes': notes,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return WorkoutSessionLogModel.fromJson(data);
  }

  @override
  Future<WorkoutSessionLogModel> skipSession(
    String workoutProfileId, {
    String? reason,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/workout-profiles/$workoutProfileId/sessions/skip',
      data: {
        if (reason != null) 'reason': reason,
      },
    );
    final data = response.data?['data'] as Map<String, dynamic>;
    return WorkoutSessionLogModel.fromJson(data);
  }

  @override
  Future<({List<WorkoutSessionLogModel> logs, int total, int page, int pageSize})> getSessionLogs(
    String workoutProfileId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/workout-profiles/$workoutProfileId/sessions',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    final data = response.data!;
    final items = (data['data'] as List<dynamic>? ?? [])
        .map((j) => WorkoutSessionLogModel.fromJson(j as Map<String, dynamic>))
        .toList();
    final meta = data['meta'] as Map<String, dynamic>? ?? {};
    return (
      logs: items,
      total: meta['total'] as int? ?? items.length,
      page: meta['page'] as int? ?? page,
      pageSize: meta['pageSize'] as int? ?? pageSize,
    );
  }
}
