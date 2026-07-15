// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_session_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WorkoutSessionLog {
  String get id => throw _privateConstructorUsedError;
  String get workoutProfileId => throw _privateConstructorUsedError;
  String? get weeklyPlanId => throw _privateConstructorUsedError;
  String? get weeklyPlanName => throw _privateConstructorUsedError;
  String? get dayPlanId => throw _privateConstructorUsedError;
  String? get dayPlanLabel => throw _privateConstructorUsedError;
  int get dayIndexAtTime => throw _privateConstructorUsedError;
  int get cycleNumberAtTime => throw _privateConstructorUsedError;
  SessionStatus get status => throw _privateConstructorUsedError;
  String? get scheduledDate => throw _privateConstructorUsedError;
  String? get completedDate => throw _privateConstructorUsedError;
  LoggedByRole get loggedByRole => throw _privateConstructorUsedError;
  String get loggedByUserId => throw _privateConstructorUsedError;
  int? get currentDayIndexAfter => throw _privateConstructorUsedError;
  List<TaskCompletionEntry> get taskCompletionLogs =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WorkoutSessionLogCopyWith<WorkoutSessionLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSessionLogCopyWith<$Res> {
  factory $WorkoutSessionLogCopyWith(
          WorkoutSessionLog value, $Res Function(WorkoutSessionLog) then) =
      _$WorkoutSessionLogCopyWithImpl<$Res, WorkoutSessionLog>;
  @useResult
  $Res call(
      {String id,
      String workoutProfileId,
      String? weeklyPlanId,
      String? weeklyPlanName,
      String? dayPlanId,
      String? dayPlanLabel,
      int dayIndexAtTime,
      int cycleNumberAtTime,
      SessionStatus status,
      String? scheduledDate,
      String? completedDate,
      LoggedByRole loggedByRole,
      String loggedByUserId,
      int? currentDayIndexAfter,
      List<TaskCompletionEntry> taskCompletionLogs});
}

/// @nodoc
class _$WorkoutSessionLogCopyWithImpl<$Res, $Val extends WorkoutSessionLog>
    implements $WorkoutSessionLogCopyWith<$Res> {
  _$WorkoutSessionLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutProfileId = null,
    Object? weeklyPlanId = freezed,
    Object? weeklyPlanName = freezed,
    Object? dayPlanId = freezed,
    Object? dayPlanLabel = freezed,
    Object? dayIndexAtTime = null,
    Object? cycleNumberAtTime = null,
    Object? status = null,
    Object? scheduledDate = freezed,
    Object? completedDate = freezed,
    Object? loggedByRole = null,
    Object? loggedByUserId = null,
    Object? currentDayIndexAfter = freezed,
    Object? taskCompletionLogs = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutProfileId: null == workoutProfileId
          ? _value.workoutProfileId
          : workoutProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      weeklyPlanId: freezed == weeklyPlanId
          ? _value.weeklyPlanId
          : weeklyPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      weeklyPlanName: freezed == weeklyPlanName
          ? _value.weeklyPlanName
          : weeklyPlanName // ignore: cast_nullable_to_non_nullable
              as String?,
      dayPlanId: freezed == dayPlanId
          ? _value.dayPlanId
          : dayPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      dayPlanLabel: freezed == dayPlanLabel
          ? _value.dayPlanLabel
          : dayPlanLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      dayIndexAtTime: null == dayIndexAtTime
          ? _value.dayIndexAtTime
          : dayIndexAtTime // ignore: cast_nullable_to_non_nullable
              as int,
      cycleNumberAtTime: null == cycleNumberAtTime
          ? _value.cycleNumberAtTime
          : cycleNumberAtTime // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as String?,
      completedDate: freezed == completedDate
          ? _value.completedDate
          : completedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      loggedByRole: null == loggedByRole
          ? _value.loggedByRole
          : loggedByRole // ignore: cast_nullable_to_non_nullable
              as LoggedByRole,
      loggedByUserId: null == loggedByUserId
          ? _value.loggedByUserId
          : loggedByUserId // ignore: cast_nullable_to_non_nullable
              as String,
      currentDayIndexAfter: freezed == currentDayIndexAfter
          ? _value.currentDayIndexAfter
          : currentDayIndexAfter // ignore: cast_nullable_to_non_nullable
              as int?,
      taskCompletionLogs: null == taskCompletionLogs
          ? _value.taskCompletionLogs
          : taskCompletionLogs // ignore: cast_nullable_to_non_nullable
              as List<TaskCompletionEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSessionLogImplCopyWith<$Res>
    implements $WorkoutSessionLogCopyWith<$Res> {
  factory _$$WorkoutSessionLogImplCopyWith(_$WorkoutSessionLogImpl value,
          $Res Function(_$WorkoutSessionLogImpl) then) =
      __$$WorkoutSessionLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String workoutProfileId,
      String? weeklyPlanId,
      String? weeklyPlanName,
      String? dayPlanId,
      String? dayPlanLabel,
      int dayIndexAtTime,
      int cycleNumberAtTime,
      SessionStatus status,
      String? scheduledDate,
      String? completedDate,
      LoggedByRole loggedByRole,
      String loggedByUserId,
      int? currentDayIndexAfter,
      List<TaskCompletionEntry> taskCompletionLogs});
}

/// @nodoc
class __$$WorkoutSessionLogImplCopyWithImpl<$Res>
    extends _$WorkoutSessionLogCopyWithImpl<$Res, _$WorkoutSessionLogImpl>
    implements _$$WorkoutSessionLogImplCopyWith<$Res> {
  __$$WorkoutSessionLogImplCopyWithImpl(_$WorkoutSessionLogImpl _value,
      $Res Function(_$WorkoutSessionLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutProfileId = null,
    Object? weeklyPlanId = freezed,
    Object? weeklyPlanName = freezed,
    Object? dayPlanId = freezed,
    Object? dayPlanLabel = freezed,
    Object? dayIndexAtTime = null,
    Object? cycleNumberAtTime = null,
    Object? status = null,
    Object? scheduledDate = freezed,
    Object? completedDate = freezed,
    Object? loggedByRole = null,
    Object? loggedByUserId = null,
    Object? currentDayIndexAfter = freezed,
    Object? taskCompletionLogs = null,
  }) {
    return _then(_$WorkoutSessionLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutProfileId: null == workoutProfileId
          ? _value.workoutProfileId
          : workoutProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      weeklyPlanId: freezed == weeklyPlanId
          ? _value.weeklyPlanId
          : weeklyPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      weeklyPlanName: freezed == weeklyPlanName
          ? _value.weeklyPlanName
          : weeklyPlanName // ignore: cast_nullable_to_non_nullable
              as String?,
      dayPlanId: freezed == dayPlanId
          ? _value.dayPlanId
          : dayPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      dayPlanLabel: freezed == dayPlanLabel
          ? _value.dayPlanLabel
          : dayPlanLabel // ignore: cast_nullable_to_non_nullable
              as String?,
      dayIndexAtTime: null == dayIndexAtTime
          ? _value.dayIndexAtTime
          : dayIndexAtTime // ignore: cast_nullable_to_non_nullable
              as int,
      cycleNumberAtTime: null == cycleNumberAtTime
          ? _value.cycleNumberAtTime
          : cycleNumberAtTime // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      scheduledDate: freezed == scheduledDate
          ? _value.scheduledDate
          : scheduledDate // ignore: cast_nullable_to_non_nullable
              as String?,
      completedDate: freezed == completedDate
          ? _value.completedDate
          : completedDate // ignore: cast_nullable_to_non_nullable
              as String?,
      loggedByRole: null == loggedByRole
          ? _value.loggedByRole
          : loggedByRole // ignore: cast_nullable_to_non_nullable
              as LoggedByRole,
      loggedByUserId: null == loggedByUserId
          ? _value.loggedByUserId
          : loggedByUserId // ignore: cast_nullable_to_non_nullable
              as String,
      currentDayIndexAfter: freezed == currentDayIndexAfter
          ? _value.currentDayIndexAfter
          : currentDayIndexAfter // ignore: cast_nullable_to_non_nullable
              as int?,
      taskCompletionLogs: null == taskCompletionLogs
          ? _value._taskCompletionLogs
          : taskCompletionLogs // ignore: cast_nullable_to_non_nullable
              as List<TaskCompletionEntry>,
    ));
  }
}

/// @nodoc

class _$WorkoutSessionLogImpl implements _WorkoutSessionLog {
  const _$WorkoutSessionLogImpl(
      {required this.id,
      required this.workoutProfileId,
      this.weeklyPlanId,
      this.weeklyPlanName,
      this.dayPlanId,
      this.dayPlanLabel,
      required this.dayIndexAtTime,
      required this.cycleNumberAtTime,
      required this.status,
      this.scheduledDate,
      this.completedDate,
      required this.loggedByRole,
      required this.loggedByUserId,
      this.currentDayIndexAfter,
      final List<TaskCompletionEntry> taskCompletionLogs =
          const <TaskCompletionEntry>[]})
      : _taskCompletionLogs = taskCompletionLogs;

  @override
  final String id;
  @override
  final String workoutProfileId;
  @override
  final String? weeklyPlanId;
  @override
  final String? weeklyPlanName;
  @override
  final String? dayPlanId;
  @override
  final String? dayPlanLabel;
  @override
  final int dayIndexAtTime;
  @override
  final int cycleNumberAtTime;
  @override
  final SessionStatus status;
  @override
  final String? scheduledDate;
  @override
  final String? completedDate;
  @override
  final LoggedByRole loggedByRole;
  @override
  final String loggedByUserId;
  @override
  final int? currentDayIndexAfter;
  final List<TaskCompletionEntry> _taskCompletionLogs;
  @override
  @JsonKey()
  List<TaskCompletionEntry> get taskCompletionLogs {
    if (_taskCompletionLogs is EqualUnmodifiableListView)
      return _taskCompletionLogs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_taskCompletionLogs);
  }

  @override
  String toString() {
    return 'WorkoutSessionLog(id: $id, workoutProfileId: $workoutProfileId, weeklyPlanId: $weeklyPlanId, weeklyPlanName: $weeklyPlanName, dayPlanId: $dayPlanId, dayPlanLabel: $dayPlanLabel, dayIndexAtTime: $dayIndexAtTime, cycleNumberAtTime: $cycleNumberAtTime, status: $status, scheduledDate: $scheduledDate, completedDate: $completedDate, loggedByRole: $loggedByRole, loggedByUserId: $loggedByUserId, currentDayIndexAfter: $currentDayIndexAfter, taskCompletionLogs: $taskCompletionLogs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSessionLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workoutProfileId, workoutProfileId) ||
                other.workoutProfileId == workoutProfileId) &&
            (identical(other.weeklyPlanId, weeklyPlanId) ||
                other.weeklyPlanId == weeklyPlanId) &&
            (identical(other.weeklyPlanName, weeklyPlanName) ||
                other.weeklyPlanName == weeklyPlanName) &&
            (identical(other.dayPlanId, dayPlanId) ||
                other.dayPlanId == dayPlanId) &&
            (identical(other.dayPlanLabel, dayPlanLabel) ||
                other.dayPlanLabel == dayPlanLabel) &&
            (identical(other.dayIndexAtTime, dayIndexAtTime) ||
                other.dayIndexAtTime == dayIndexAtTime) &&
            (identical(other.cycleNumberAtTime, cycleNumberAtTime) ||
                other.cycleNumberAtTime == cycleNumberAtTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scheduledDate, scheduledDate) ||
                other.scheduledDate == scheduledDate) &&
            (identical(other.completedDate, completedDate) ||
                other.completedDate == completedDate) &&
            (identical(other.loggedByRole, loggedByRole) ||
                other.loggedByRole == loggedByRole) &&
            (identical(other.loggedByUserId, loggedByUserId) ||
                other.loggedByUserId == loggedByUserId) &&
            (identical(other.currentDayIndexAfter, currentDayIndexAfter) ||
                other.currentDayIndexAfter == currentDayIndexAfter) &&
            const DeepCollectionEquality()
                .equals(other._taskCompletionLogs, _taskCompletionLogs));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      workoutProfileId,
      weeklyPlanId,
      weeklyPlanName,
      dayPlanId,
      dayPlanLabel,
      dayIndexAtTime,
      cycleNumberAtTime,
      status,
      scheduledDate,
      completedDate,
      loggedByRole,
      loggedByUserId,
      currentDayIndexAfter,
      const DeepCollectionEquality().hash(_taskCompletionLogs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSessionLogImplCopyWith<_$WorkoutSessionLogImpl> get copyWith =>
      __$$WorkoutSessionLogImplCopyWithImpl<_$WorkoutSessionLogImpl>(
          this, _$identity);
}

abstract class _WorkoutSessionLog implements WorkoutSessionLog {
  const factory _WorkoutSessionLog(
          {required final String id,
          required final String workoutProfileId,
          final String? weeklyPlanId,
          final String? weeklyPlanName,
          final String? dayPlanId,
          final String? dayPlanLabel,
          required final int dayIndexAtTime,
          required final int cycleNumberAtTime,
          required final SessionStatus status,
          final String? scheduledDate,
          final String? completedDate,
          required final LoggedByRole loggedByRole,
          required final String loggedByUserId,
          final int? currentDayIndexAfter,
          final List<TaskCompletionEntry> taskCompletionLogs}) =
      _$WorkoutSessionLogImpl;

  @override
  String get id;
  @override
  String get workoutProfileId;
  @override
  String? get weeklyPlanId;
  @override
  String? get weeklyPlanName;
  @override
  String? get dayPlanId;
  @override
  String? get dayPlanLabel;
  @override
  int get dayIndexAtTime;
  @override
  int get cycleNumberAtTime;
  @override
  SessionStatus get status;
  @override
  String? get scheduledDate;
  @override
  String? get completedDate;
  @override
  LoggedByRole get loggedByRole;
  @override
  String get loggedByUserId;
  @override
  int? get currentDayIndexAfter;
  @override
  List<TaskCompletionEntry> get taskCompletionLogs;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutSessionLogImplCopyWith<_$WorkoutSessionLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
