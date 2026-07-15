// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_completion_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TaskCompletionEntry {
  String get taskId => throw _privateConstructorUsedError;
  int? get actualSets => throw _privateConstructorUsedError;
  String? get actualReps => throw _privateConstructorUsedError;
  double? get actualWeightKg => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskCompletionEntryCopyWith<TaskCompletionEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCompletionEntryCopyWith<$Res> {
  factory $TaskCompletionEntryCopyWith(
          TaskCompletionEntry value, $Res Function(TaskCompletionEntry) then) =
      _$TaskCompletionEntryCopyWithImpl<$Res, TaskCompletionEntry>;
  @useResult
  $Res call(
      {String taskId,
      int? actualSets,
      String? actualReps,
      double? actualWeightKg,
      String? notes});
}

/// @nodoc
class _$TaskCompletionEntryCopyWithImpl<$Res, $Val extends TaskCompletionEntry>
    implements $TaskCompletionEntryCopyWith<$Res> {
  _$TaskCompletionEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? actualSets = freezed,
    Object? actualReps = freezed,
    Object? actualWeightKg = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      actualSets: freezed == actualSets
          ? _value.actualSets
          : actualSets // ignore: cast_nullable_to_non_nullable
              as int?,
      actualReps: freezed == actualReps
          ? _value.actualReps
          : actualReps // ignore: cast_nullable_to_non_nullable
              as String?,
      actualWeightKg: freezed == actualWeightKg
          ? _value.actualWeightKg
          : actualWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskCompletionEntryImplCopyWith<$Res>
    implements $TaskCompletionEntryCopyWith<$Res> {
  factory _$$TaskCompletionEntryImplCopyWith(_$TaskCompletionEntryImpl value,
          $Res Function(_$TaskCompletionEntryImpl) then) =
      __$$TaskCompletionEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String taskId,
      int? actualSets,
      String? actualReps,
      double? actualWeightKg,
      String? notes});
}

/// @nodoc
class __$$TaskCompletionEntryImplCopyWithImpl<$Res>
    extends _$TaskCompletionEntryCopyWithImpl<$Res, _$TaskCompletionEntryImpl>
    implements _$$TaskCompletionEntryImplCopyWith<$Res> {
  __$$TaskCompletionEntryImplCopyWithImpl(_$TaskCompletionEntryImpl _value,
      $Res Function(_$TaskCompletionEntryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? taskId = null,
    Object? actualSets = freezed,
    Object? actualReps = freezed,
    Object? actualWeightKg = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$TaskCompletionEntryImpl(
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      actualSets: freezed == actualSets
          ? _value.actualSets
          : actualSets // ignore: cast_nullable_to_non_nullable
              as int?,
      actualReps: freezed == actualReps
          ? _value.actualReps
          : actualReps // ignore: cast_nullable_to_non_nullable
              as String?,
      actualWeightKg: freezed == actualWeightKg
          ? _value.actualWeightKg
          : actualWeightKg // ignore: cast_nullable_to_non_nullable
              as double?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TaskCompletionEntryImpl implements _TaskCompletionEntry {
  const _$TaskCompletionEntryImpl(
      {required this.taskId,
      this.actualSets,
      this.actualReps,
      this.actualWeightKg,
      this.notes});

  @override
  final String taskId;
  @override
  final int? actualSets;
  @override
  final String? actualReps;
  @override
  final double? actualWeightKg;
  @override
  final String? notes;

  @override
  String toString() {
    return 'TaskCompletionEntry(taskId: $taskId, actualSets: $actualSets, actualReps: $actualReps, actualWeightKg: $actualWeightKg, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskCompletionEntryImpl &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.actualSets, actualSets) ||
                other.actualSets == actualSets) &&
            (identical(other.actualReps, actualReps) ||
                other.actualReps == actualReps) &&
            (identical(other.actualWeightKg, actualWeightKg) ||
                other.actualWeightKg == actualWeightKg) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, taskId, actualSets, actualReps, actualWeightKg, notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskCompletionEntryImplCopyWith<_$TaskCompletionEntryImpl> get copyWith =>
      __$$TaskCompletionEntryImplCopyWithImpl<_$TaskCompletionEntryImpl>(
          this, _$identity);
}

abstract class _TaskCompletionEntry implements TaskCompletionEntry {
  const factory _TaskCompletionEntry(
      {required final String taskId,
      final int? actualSets,
      final String? actualReps,
      final double? actualWeightKg,
      final String? notes}) = _$TaskCompletionEntryImpl;

  @override
  String get taskId;
  @override
  int? get actualSets;
  @override
  String? get actualReps;
  @override
  double? get actualWeightKg;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$TaskCompletionEntryImplCopyWith<_$TaskCompletionEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
