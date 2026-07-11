// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weekly_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WeeklyPlan {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get workoutProfileId => throw _privateConstructorUsedError;
  String get status =>
      throw _privateConstructorUsedError; // ACTIVE, UPCOMING, ARCHIVED
  String? get notes => throw _privateConstructorUsedError;
  List<DayPlan> get dayPlans => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WeeklyPlanCopyWith<WeeklyPlan> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyPlanCopyWith<$Res> {
  factory $WeeklyPlanCopyWith(
          WeeklyPlan value, $Res Function(WeeklyPlan) then) =
      _$WeeklyPlanCopyWithImpl<$Res, WeeklyPlan>;
  @useResult
  $Res call(
      {String id,
      String name,
      String workoutProfileId,
      String status,
      String? notes,
      List<DayPlan> dayPlans});
}

/// @nodoc
class _$WeeklyPlanCopyWithImpl<$Res, $Val extends WeeklyPlan>
    implements $WeeklyPlanCopyWith<$Res> {
  _$WeeklyPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? workoutProfileId = null,
    Object? status = null,
    Object? notes = freezed,
    Object? dayPlans = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      workoutProfileId: null == workoutProfileId
          ? _value.workoutProfileId
          : workoutProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      dayPlans: null == dayPlans
          ? _value.dayPlans
          : dayPlans // ignore: cast_nullable_to_non_nullable
              as List<DayPlan>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WeeklyPlanImplCopyWith<$Res>
    implements $WeeklyPlanCopyWith<$Res> {
  factory _$$WeeklyPlanImplCopyWith(
          _$WeeklyPlanImpl value, $Res Function(_$WeeklyPlanImpl) then) =
      __$$WeeklyPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String workoutProfileId,
      String status,
      String? notes,
      List<DayPlan> dayPlans});
}

/// @nodoc
class __$$WeeklyPlanImplCopyWithImpl<$Res>
    extends _$WeeklyPlanCopyWithImpl<$Res, _$WeeklyPlanImpl>
    implements _$$WeeklyPlanImplCopyWith<$Res> {
  __$$WeeklyPlanImplCopyWithImpl(
      _$WeeklyPlanImpl _value, $Res Function(_$WeeklyPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? workoutProfileId = null,
    Object? status = null,
    Object? notes = freezed,
    Object? dayPlans = null,
  }) {
    return _then(_$WeeklyPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      workoutProfileId: null == workoutProfileId
          ? _value.workoutProfileId
          : workoutProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      dayPlans: null == dayPlans
          ? _value._dayPlans
          : dayPlans // ignore: cast_nullable_to_non_nullable
              as List<DayPlan>,
    ));
  }
}

/// @nodoc

class _$WeeklyPlanImpl implements _WeeklyPlan {
  const _$WeeklyPlanImpl(
      {required this.id,
      required this.name,
      required this.workoutProfileId,
      required this.status,
      this.notes,
      required final List<DayPlan> dayPlans})
      : _dayPlans = dayPlans;

  @override
  final String id;
  @override
  final String name;
  @override
  final String workoutProfileId;
  @override
  final String status;
// ACTIVE, UPCOMING, ARCHIVED
  @override
  final String? notes;
  final List<DayPlan> _dayPlans;
  @override
  List<DayPlan> get dayPlans {
    if (_dayPlans is EqualUnmodifiableListView) return _dayPlans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dayPlans);
  }

  @override
  String toString() {
    return 'WeeklyPlan(id: $id, name: $name, workoutProfileId: $workoutProfileId, status: $status, notes: $notes, dayPlans: $dayPlans)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.workoutProfileId, workoutProfileId) ||
                other.workoutProfileId == workoutProfileId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._dayPlans, _dayPlans));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, workoutProfileId,
      status, notes, const DeepCollectionEquality().hash(_dayPlans));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyPlanImplCopyWith<_$WeeklyPlanImpl> get copyWith =>
      __$$WeeklyPlanImplCopyWithImpl<_$WeeklyPlanImpl>(this, _$identity);
}

abstract class _WeeklyPlan implements WeeklyPlan {
  const factory _WeeklyPlan(
      {required final String id,
      required final String name,
      required final String workoutProfileId,
      required final String status,
      final String? notes,
      required final List<DayPlan> dayPlans}) = _$WeeklyPlanImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get workoutProfileId;
  @override
  String get status;
  @override // ACTIVE, UPCOMING, ARCHIVED
  String? get notes;
  @override
  List<DayPlan> get dayPlans;
  @override
  @JsonKey(ignore: true)
  _$$WeeklyPlanImplCopyWith<_$WeeklyPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
