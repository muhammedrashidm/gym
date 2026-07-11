// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WorkoutProfile {
  String get id => throw _privateConstructorUsedError;
  String get clientProfileId => throw _privateConstructorUsedError;
  String get trainerProfileId => throw _privateConstructorUsedError;
  String? get activeWeeklyPlanId => throw _privateConstructorUsedError;
  int get currentDayIndex => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  WeeklyPlan? get activeWeeklyPlan => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WorkoutProfileCopyWith<WorkoutProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutProfileCopyWith<$Res> {
  factory $WorkoutProfileCopyWith(
          WorkoutProfile value, $Res Function(WorkoutProfile) then) =
      _$WorkoutProfileCopyWithImpl<$Res, WorkoutProfile>;
  @useResult
  $Res call(
      {String id,
      String clientProfileId,
      String trainerProfileId,
      String? activeWeeklyPlanId,
      int currentDayIndex,
      bool isActive,
      DateTime createdAt,
      WeeklyPlan? activeWeeklyPlan});

  $WeeklyPlanCopyWith<$Res>? get activeWeeklyPlan;
}

/// @nodoc
class _$WorkoutProfileCopyWithImpl<$Res, $Val extends WorkoutProfile>
    implements $WorkoutProfileCopyWith<$Res> {
  _$WorkoutProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientProfileId = null,
    Object? trainerProfileId = null,
    Object? activeWeeklyPlanId = freezed,
    Object? currentDayIndex = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? activeWeeklyPlan = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clientProfileId: null == clientProfileId
          ? _value.clientProfileId
          : clientProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      trainerProfileId: null == trainerProfileId
          ? _value.trainerProfileId
          : trainerProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      activeWeeklyPlanId: freezed == activeWeeklyPlanId
          ? _value.activeWeeklyPlanId
          : activeWeeklyPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentDayIndex: null == currentDayIndex
          ? _value.currentDayIndex
          : currentDayIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      activeWeeklyPlan: freezed == activeWeeklyPlan
          ? _value.activeWeeklyPlan
          : activeWeeklyPlan // ignore: cast_nullable_to_non_nullable
              as WeeklyPlan?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WeeklyPlanCopyWith<$Res>? get activeWeeklyPlan {
    if (_value.activeWeeklyPlan == null) {
      return null;
    }

    return $WeeklyPlanCopyWith<$Res>(_value.activeWeeklyPlan!, (value) {
      return _then(_value.copyWith(activeWeeklyPlan: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkoutProfileImplCopyWith<$Res>
    implements $WorkoutProfileCopyWith<$Res> {
  factory _$$WorkoutProfileImplCopyWith(_$WorkoutProfileImpl value,
          $Res Function(_$WorkoutProfileImpl) then) =
      __$$WorkoutProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String clientProfileId,
      String trainerProfileId,
      String? activeWeeklyPlanId,
      int currentDayIndex,
      bool isActive,
      DateTime createdAt,
      WeeklyPlan? activeWeeklyPlan});

  @override
  $WeeklyPlanCopyWith<$Res>? get activeWeeklyPlan;
}

/// @nodoc
class __$$WorkoutProfileImplCopyWithImpl<$Res>
    extends _$WorkoutProfileCopyWithImpl<$Res, _$WorkoutProfileImpl>
    implements _$$WorkoutProfileImplCopyWith<$Res> {
  __$$WorkoutProfileImplCopyWithImpl(
      _$WorkoutProfileImpl _value, $Res Function(_$WorkoutProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? clientProfileId = null,
    Object? trainerProfileId = null,
    Object? activeWeeklyPlanId = freezed,
    Object? currentDayIndex = null,
    Object? isActive = null,
    Object? createdAt = null,
    Object? activeWeeklyPlan = freezed,
  }) {
    return _then(_$WorkoutProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      clientProfileId: null == clientProfileId
          ? _value.clientProfileId
          : clientProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      trainerProfileId: null == trainerProfileId
          ? _value.trainerProfileId
          : trainerProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      activeWeeklyPlanId: freezed == activeWeeklyPlanId
          ? _value.activeWeeklyPlanId
          : activeWeeklyPlanId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentDayIndex: null == currentDayIndex
          ? _value.currentDayIndex
          : currentDayIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      activeWeeklyPlan: freezed == activeWeeklyPlan
          ? _value.activeWeeklyPlan
          : activeWeeklyPlan // ignore: cast_nullable_to_non_nullable
              as WeeklyPlan?,
    ));
  }
}

/// @nodoc

class _$WorkoutProfileImpl implements _WorkoutProfile {
  const _$WorkoutProfileImpl(
      {required this.id,
      required this.clientProfileId,
      required this.trainerProfileId,
      this.activeWeeklyPlanId,
      required this.currentDayIndex,
      required this.isActive,
      required this.createdAt,
      this.activeWeeklyPlan});

  @override
  final String id;
  @override
  final String clientProfileId;
  @override
  final String trainerProfileId;
  @override
  final String? activeWeeklyPlanId;
  @override
  final int currentDayIndex;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final WeeklyPlan? activeWeeklyPlan;

  @override
  String toString() {
    return 'WorkoutProfile(id: $id, clientProfileId: $clientProfileId, trainerProfileId: $trainerProfileId, activeWeeklyPlanId: $activeWeeklyPlanId, currentDayIndex: $currentDayIndex, isActive: $isActive, createdAt: $createdAt, activeWeeklyPlan: $activeWeeklyPlan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.clientProfileId, clientProfileId) ||
                other.clientProfileId == clientProfileId) &&
            (identical(other.trainerProfileId, trainerProfileId) ||
                other.trainerProfileId == trainerProfileId) &&
            (identical(other.activeWeeklyPlanId, activeWeeklyPlanId) ||
                other.activeWeeklyPlanId == activeWeeklyPlanId) &&
            (identical(other.currentDayIndex, currentDayIndex) ||
                other.currentDayIndex == currentDayIndex) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.activeWeeklyPlan, activeWeeklyPlan) ||
                other.activeWeeklyPlan == activeWeeklyPlan));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      clientProfileId,
      trainerProfileId,
      activeWeeklyPlanId,
      currentDayIndex,
      isActive,
      createdAt,
      activeWeeklyPlan);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutProfileImplCopyWith<_$WorkoutProfileImpl> get copyWith =>
      __$$WorkoutProfileImplCopyWithImpl<_$WorkoutProfileImpl>(
          this, _$identity);
}

abstract class _WorkoutProfile implements WorkoutProfile {
  const factory _WorkoutProfile(
      {required final String id,
      required final String clientProfileId,
      required final String trainerProfileId,
      final String? activeWeeklyPlanId,
      required final int currentDayIndex,
      required final bool isActive,
      required final DateTime createdAt,
      final WeeklyPlan? activeWeeklyPlan}) = _$WorkoutProfileImpl;

  @override
  String get id;
  @override
  String get clientProfileId;
  @override
  String get trainerProfileId;
  @override
  String? get activeWeeklyPlanId;
  @override
  int get currentDayIndex;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  WeeklyPlan? get activeWeeklyPlan;
  @override
  @JsonKey(ignore: true)
  _$$WorkoutProfileImplCopyWith<_$WorkoutProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
