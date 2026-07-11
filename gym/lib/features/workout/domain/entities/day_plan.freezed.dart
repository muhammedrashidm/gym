// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DayPlan {
  String get id => throw _privateConstructorUsedError;
  String get weeklyPlanId => throw _privateConstructorUsedError;
  int get dayIndex => throw _privateConstructorUsedError;
  String? get label => throw _privateConstructorUsedError;
  bool get isRestDay => throw _privateConstructorUsedError;
  List<Task> get tasks => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DayPlanCopyWith<DayPlan> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayPlanCopyWith<$Res> {
  factory $DayPlanCopyWith(DayPlan value, $Res Function(DayPlan) then) =
      _$DayPlanCopyWithImpl<$Res, DayPlan>;
  @useResult
  $Res call(
      {String id,
      String weeklyPlanId,
      int dayIndex,
      String? label,
      bool isRestDay,
      List<Task> tasks});
}

/// @nodoc
class _$DayPlanCopyWithImpl<$Res, $Val extends DayPlan>
    implements $DayPlanCopyWith<$Res> {
  _$DayPlanCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? weeklyPlanId = null,
    Object? dayIndex = null,
    Object? label = freezed,
    Object? isRestDay = null,
    Object? tasks = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      weeklyPlanId: null == weeklyPlanId
          ? _value.weeklyPlanId
          : weeklyPlanId // ignore: cast_nullable_to_non_nullable
              as String,
      dayIndex: null == dayIndex
          ? _value.dayIndex
          : dayIndex // ignore: cast_nullable_to_non_nullable
              as int,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      isRestDay: null == isRestDay
          ? _value.isRestDay
          : isRestDay // ignore: cast_nullable_to_non_nullable
              as bool,
      tasks: null == tasks
          ? _value.tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<Task>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DayPlanImplCopyWith<$Res> implements $DayPlanCopyWith<$Res> {
  factory _$$DayPlanImplCopyWith(
          _$DayPlanImpl value, $Res Function(_$DayPlanImpl) then) =
      __$$DayPlanImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String weeklyPlanId,
      int dayIndex,
      String? label,
      bool isRestDay,
      List<Task> tasks});
}

/// @nodoc
class __$$DayPlanImplCopyWithImpl<$Res>
    extends _$DayPlanCopyWithImpl<$Res, _$DayPlanImpl>
    implements _$$DayPlanImplCopyWith<$Res> {
  __$$DayPlanImplCopyWithImpl(
      _$DayPlanImpl _value, $Res Function(_$DayPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? weeklyPlanId = null,
    Object? dayIndex = null,
    Object? label = freezed,
    Object? isRestDay = null,
    Object? tasks = null,
  }) {
    return _then(_$DayPlanImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      weeklyPlanId: null == weeklyPlanId
          ? _value.weeklyPlanId
          : weeklyPlanId // ignore: cast_nullable_to_non_nullable
              as String,
      dayIndex: null == dayIndex
          ? _value.dayIndex
          : dayIndex // ignore: cast_nullable_to_non_nullable
              as int,
      label: freezed == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String?,
      isRestDay: null == isRestDay
          ? _value.isRestDay
          : isRestDay // ignore: cast_nullable_to_non_nullable
              as bool,
      tasks: null == tasks
          ? _value._tasks
          : tasks // ignore: cast_nullable_to_non_nullable
              as List<Task>,
    ));
  }
}

/// @nodoc

class _$DayPlanImpl implements _DayPlan {
  const _$DayPlanImpl(
      {required this.id,
      required this.weeklyPlanId,
      required this.dayIndex,
      this.label,
      required this.isRestDay,
      required final List<Task> tasks})
      : _tasks = tasks;

  @override
  final String id;
  @override
  final String weeklyPlanId;
  @override
  final int dayIndex;
  @override
  final String? label;
  @override
  final bool isRestDay;
  final List<Task> _tasks;
  @override
  List<Task> get tasks {
    if (_tasks is EqualUnmodifiableListView) return _tasks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tasks);
  }

  @override
  String toString() {
    return 'DayPlan(id: $id, weeklyPlanId: $weeklyPlanId, dayIndex: $dayIndex, label: $label, isRestDay: $isRestDay, tasks: $tasks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayPlanImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.weeklyPlanId, weeklyPlanId) ||
                other.weeklyPlanId == weeklyPlanId) &&
            (identical(other.dayIndex, dayIndex) ||
                other.dayIndex == dayIndex) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.isRestDay, isRestDay) ||
                other.isRestDay == isRestDay) &&
            const DeepCollectionEquality().equals(other._tasks, _tasks));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, weeklyPlanId, dayIndex,
      label, isRestDay, const DeepCollectionEquality().hash(_tasks));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DayPlanImplCopyWith<_$DayPlanImpl> get copyWith =>
      __$$DayPlanImplCopyWithImpl<_$DayPlanImpl>(this, _$identity);
}

abstract class _DayPlan implements DayPlan {
  const factory _DayPlan(
      {required final String id,
      required final String weeklyPlanId,
      required final int dayIndex,
      final String? label,
      required final bool isRestDay,
      required final List<Task> tasks}) = _$DayPlanImpl;

  @override
  String get id;
  @override
  String get weeklyPlanId;
  @override
  int get dayIndex;
  @override
  String? get label;
  @override
  bool get isRestDay;
  @override
  List<Task> get tasks;
  @override
  @JsonKey(ignore: true)
  _$$DayPlanImplCopyWith<_$DayPlanImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
