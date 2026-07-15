// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Task {
  String get id => throw _privateConstructorUsedError;
  String get dayPlanId => throw _privateConstructorUsedError;
  int get sequenceIndex => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get machineDetails => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;
  String get reps => throw _privateConstructorUsedError;
  int? get restSeconds => throw _privateConstructorUsedError;
  String? get tempo => throw _privateConstructorUsedError;
  List<TaskAttachment> get attachments => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskCopyWith<Task> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskCopyWith<$Res> {
  factory $TaskCopyWith(Task value, $Res Function(Task) then) =
      _$TaskCopyWithImpl<$Res, Task>;
  @useResult
  $Res call(
      {String id,
      String dayPlanId,
      int sequenceIndex,
      String name,
      String? description,
      String? machineDetails,
      String? notes,
      int sets,
      String reps,
      int? restSeconds,
      String? tempo,
      List<TaskAttachment> attachments});
}

/// @nodoc
class _$TaskCopyWithImpl<$Res, $Val extends Task>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayPlanId = null,
    Object? sequenceIndex = null,
    Object? name = null,
    Object? description = freezed,
    Object? machineDetails = freezed,
    Object? notes = freezed,
    Object? sets = null,
    Object? reps = null,
    Object? restSeconds = freezed,
    Object? tempo = freezed,
    Object? attachments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dayPlanId: null == dayPlanId
          ? _value.dayPlanId
          : dayPlanId // ignore: cast_nullable_to_non_nullable
              as String,
      sequenceIndex: null == sequenceIndex
          ? _value.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      machineDetails: freezed == machineDetails
          ? _value.machineDetails
          : machineDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: freezed == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      tempo: freezed == tempo
          ? _value.tempo
          : tempo // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<TaskAttachment>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskImplCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$$TaskImplCopyWith(
          _$TaskImpl value, $Res Function(_$TaskImpl) then) =
      __$$TaskImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String dayPlanId,
      int sequenceIndex,
      String name,
      String? description,
      String? machineDetails,
      String? notes,
      int sets,
      String reps,
      int? restSeconds,
      String? tempo,
      List<TaskAttachment> attachments});
}

/// @nodoc
class __$$TaskImplCopyWithImpl<$Res>
    extends _$TaskCopyWithImpl<$Res, _$TaskImpl>
    implements _$$TaskImplCopyWith<$Res> {
  __$$TaskImplCopyWithImpl(_$TaskImpl _value, $Res Function(_$TaskImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dayPlanId = null,
    Object? sequenceIndex = null,
    Object? name = null,
    Object? description = freezed,
    Object? machineDetails = freezed,
    Object? notes = freezed,
    Object? sets = null,
    Object? reps = null,
    Object? restSeconds = freezed,
    Object? tempo = freezed,
    Object? attachments = null,
  }) {
    return _then(_$TaskImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      dayPlanId: null == dayPlanId
          ? _value.dayPlanId
          : dayPlanId // ignore: cast_nullable_to_non_nullable
              as String,
      sequenceIndex: null == sequenceIndex
          ? _value.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      machineDetails: freezed == machineDetails
          ? _value.machineDetails
          : machineDetails // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      sets: null == sets
          ? _value.sets
          : sets // ignore: cast_nullable_to_non_nullable
              as int,
      reps: null == reps
          ? _value.reps
          : reps // ignore: cast_nullable_to_non_nullable
              as String,
      restSeconds: freezed == restSeconds
          ? _value.restSeconds
          : restSeconds // ignore: cast_nullable_to_non_nullable
              as int?,
      tempo: freezed == tempo
          ? _value.tempo
          : tempo // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<TaskAttachment>,
    ));
  }
}

/// @nodoc

class _$TaskImpl implements _Task {
  const _$TaskImpl(
      {required this.id,
      required this.dayPlanId,
      required this.sequenceIndex,
      required this.name,
      this.description,
      this.machineDetails,
      this.notes,
      required this.sets,
      required this.reps,
      this.restSeconds,
      this.tempo,
      final List<TaskAttachment> attachments = const <TaskAttachment>[]})
      : _attachments = attachments;

  @override
  final String id;
  @override
  final String dayPlanId;
  @override
  final int sequenceIndex;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? machineDetails;
  @override
  final String? notes;
  @override
  final int sets;
  @override
  final String reps;
  @override
  final int? restSeconds;
  @override
  final String? tempo;
  final List<TaskAttachment> _attachments;
  @override
  @JsonKey()
  List<TaskAttachment> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  String toString() {
    return 'Task(id: $id, dayPlanId: $dayPlanId, sequenceIndex: $sequenceIndex, name: $name, description: $description, machineDetails: $machineDetails, notes: $notes, sets: $sets, reps: $reps, restSeconds: $restSeconds, tempo: $tempo, attachments: $attachments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.dayPlanId, dayPlanId) ||
                other.dayPlanId == dayPlanId) &&
            (identical(other.sequenceIndex, sequenceIndex) ||
                other.sequenceIndex == sequenceIndex) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.machineDetails, machineDetails) ||
                other.machineDetails == machineDetails) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.tempo, tempo) || other.tempo == tempo) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      dayPlanId,
      sequenceIndex,
      name,
      description,
      machineDetails,
      notes,
      sets,
      reps,
      restSeconds,
      tempo,
      const DeepCollectionEquality().hash(_attachments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      __$$TaskImplCopyWithImpl<_$TaskImpl>(this, _$identity);
}

abstract class _Task implements Task {
  const factory _Task(
      {required final String id,
      required final String dayPlanId,
      required final int sequenceIndex,
      required final String name,
      final String? description,
      final String? machineDetails,
      final String? notes,
      required final int sets,
      required final String reps,
      final int? restSeconds,
      final String? tempo,
      final List<TaskAttachment> attachments}) = _$TaskImpl;

  @override
  String get id;
  @override
  String get dayPlanId;
  @override
  int get sequenceIndex;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get machineDetails;
  @override
  String? get notes;
  @override
  int get sets;
  @override
  String get reps;
  @override
  int? get restSeconds;
  @override
  String? get tempo;
  @override
  List<TaskAttachment> get attachments;
  @override
  @JsonKey(ignore: true)
  _$$TaskImplCopyWith<_$TaskImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
