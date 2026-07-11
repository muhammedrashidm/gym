// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_plan_creator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WeekPlanCreatorState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)
        editing,
    required TResult Function() saving,
    required TResult Function(WeeklyPlan plan) saved,
    required TResult Function(
            String message,
            List<DraftDayPlan> days,
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult? Function()? saving,
    TResult? Function(WeeklyPlan plan)? saved,
    TResult? Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult Function()? saving,
    TResult Function(WeeklyPlan plan)? saved,
    TResult Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeekPlanCreatorEditing value) editing,
    required TResult Function(WeekPlanCreatorSaving value) saving,
    required TResult Function(WeekPlanCreatorSaved value) saved,
    required TResult Function(WeekPlanCreatorError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeekPlanCreatorEditing value)? editing,
    TResult? Function(WeekPlanCreatorSaving value)? saving,
    TResult? Function(WeekPlanCreatorSaved value)? saved,
    TResult? Function(WeekPlanCreatorError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeekPlanCreatorEditing value)? editing,
    TResult Function(WeekPlanCreatorSaving value)? saving,
    TResult Function(WeekPlanCreatorSaved value)? saved,
    TResult Function(WeekPlanCreatorError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeekPlanCreatorStateCopyWith<$Res> {
  factory $WeekPlanCreatorStateCopyWith(WeekPlanCreatorState value,
          $Res Function(WeekPlanCreatorState) then) =
      _$WeekPlanCreatorStateCopyWithImpl<$Res, WeekPlanCreatorState>;
}

/// @nodoc
class _$WeekPlanCreatorStateCopyWithImpl<$Res,
        $Val extends WeekPlanCreatorState>
    implements $WeekPlanCreatorStateCopyWith<$Res> {
  _$WeekPlanCreatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$WeekPlanCreatorEditingImplCopyWith<$Res> {
  factory _$$WeekPlanCreatorEditingImplCopyWith(
          _$WeekPlanCreatorEditingImpl value,
          $Res Function(_$WeekPlanCreatorEditingImpl) then) =
      __$$WeekPlanCreatorEditingImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String planName,
      String planNotes,
      bool activateImmediately,
      int selectedDayIndex,
      List<DraftDayPlan> days});
}

/// @nodoc
class __$$WeekPlanCreatorEditingImplCopyWithImpl<$Res>
    extends _$WeekPlanCreatorStateCopyWithImpl<$Res,
        _$WeekPlanCreatorEditingImpl>
    implements _$$WeekPlanCreatorEditingImplCopyWith<$Res> {
  __$$WeekPlanCreatorEditingImplCopyWithImpl(
      _$WeekPlanCreatorEditingImpl _value,
      $Res Function(_$WeekPlanCreatorEditingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? planName = null,
    Object? planNotes = null,
    Object? activateImmediately = null,
    Object? selectedDayIndex = null,
    Object? days = null,
  }) {
    return _then(_$WeekPlanCreatorEditingImpl(
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      planNotes: null == planNotes
          ? _value.planNotes
          : planNotes // ignore: cast_nullable_to_non_nullable
              as String,
      activateImmediately: null == activateImmediately
          ? _value.activateImmediately
          : activateImmediately // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedDayIndex: null == selectedDayIndex
          ? _value.selectedDayIndex
          : selectedDayIndex // ignore: cast_nullable_to_non_nullable
              as int,
      days: null == days
          ? _value._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<DraftDayPlan>,
    ));
  }
}

/// @nodoc

class _$WeekPlanCreatorEditingImpl implements WeekPlanCreatorEditing {
  const _$WeekPlanCreatorEditingImpl(
      {this.planName = '',
      this.planNotes = '',
      this.activateImmediately = false,
      this.selectedDayIndex = 0,
      required final List<DraftDayPlan> days})
      : _days = days;

  @override
  @JsonKey()
  final String planName;
  @override
  @JsonKey()
  final String planNotes;
  @override
  @JsonKey()
  final bool activateImmediately;
  @override
  @JsonKey()
  final int selectedDayIndex;
  final List<DraftDayPlan> _days;
  @override
  List<DraftDayPlan> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  String toString() {
    return 'WeekPlanCreatorState.editing(planName: $planName, planNotes: $planNotes, activateImmediately: $activateImmediately, selectedDayIndex: $selectedDayIndex, days: $days)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekPlanCreatorEditingImpl &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.planNotes, planNotes) ||
                other.planNotes == planNotes) &&
            (identical(other.activateImmediately, activateImmediately) ||
                other.activateImmediately == activateImmediately) &&
            (identical(other.selectedDayIndex, selectedDayIndex) ||
                other.selectedDayIndex == selectedDayIndex) &&
            const DeepCollectionEquality().equals(other._days, _days));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      planName,
      planNotes,
      activateImmediately,
      selectedDayIndex,
      const DeepCollectionEquality().hash(_days));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekPlanCreatorEditingImplCopyWith<_$WeekPlanCreatorEditingImpl>
      get copyWith => __$$WeekPlanCreatorEditingImplCopyWithImpl<
          _$WeekPlanCreatorEditingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)
        editing,
    required TResult Function() saving,
    required TResult Function(WeeklyPlan plan) saved,
    required TResult Function(
            String message,
            List<DraftDayPlan> days,
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex)
        error,
  }) {
    return editing(
        planName, planNotes, activateImmediately, selectedDayIndex, days);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult? Function()? saving,
    TResult? Function(WeeklyPlan plan)? saved,
    TResult? Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
  }) {
    return editing?.call(
        planName, planNotes, activateImmediately, selectedDayIndex, days);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult Function()? saving,
    TResult Function(WeeklyPlan plan)? saved,
    TResult Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
    required TResult orElse(),
  }) {
    if (editing != null) {
      return editing(
          planName, planNotes, activateImmediately, selectedDayIndex, days);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeekPlanCreatorEditing value) editing,
    required TResult Function(WeekPlanCreatorSaving value) saving,
    required TResult Function(WeekPlanCreatorSaved value) saved,
    required TResult Function(WeekPlanCreatorError value) error,
  }) {
    return editing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeekPlanCreatorEditing value)? editing,
    TResult? Function(WeekPlanCreatorSaving value)? saving,
    TResult? Function(WeekPlanCreatorSaved value)? saved,
    TResult? Function(WeekPlanCreatorError value)? error,
  }) {
    return editing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeekPlanCreatorEditing value)? editing,
    TResult Function(WeekPlanCreatorSaving value)? saving,
    TResult Function(WeekPlanCreatorSaved value)? saved,
    TResult Function(WeekPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (editing != null) {
      return editing(this);
    }
    return orElse();
  }
}

abstract class WeekPlanCreatorEditing implements WeekPlanCreatorState {
  const factory WeekPlanCreatorEditing(
      {final String planName,
      final String planNotes,
      final bool activateImmediately,
      final int selectedDayIndex,
      required final List<DraftDayPlan> days}) = _$WeekPlanCreatorEditingImpl;

  String get planName;
  String get planNotes;
  bool get activateImmediately;
  int get selectedDayIndex;
  List<DraftDayPlan> get days;
  @JsonKey(ignore: true)
  _$$WeekPlanCreatorEditingImplCopyWith<_$WeekPlanCreatorEditingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeekPlanCreatorSavingImplCopyWith<$Res> {
  factory _$$WeekPlanCreatorSavingImplCopyWith(
          _$WeekPlanCreatorSavingImpl value,
          $Res Function(_$WeekPlanCreatorSavingImpl) then) =
      __$$WeekPlanCreatorSavingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$WeekPlanCreatorSavingImplCopyWithImpl<$Res>
    extends _$WeekPlanCreatorStateCopyWithImpl<$Res,
        _$WeekPlanCreatorSavingImpl>
    implements _$$WeekPlanCreatorSavingImplCopyWith<$Res> {
  __$$WeekPlanCreatorSavingImplCopyWithImpl(_$WeekPlanCreatorSavingImpl _value,
      $Res Function(_$WeekPlanCreatorSavingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$WeekPlanCreatorSavingImpl implements WeekPlanCreatorSaving {
  const _$WeekPlanCreatorSavingImpl();

  @override
  String toString() {
    return 'WeekPlanCreatorState.saving()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekPlanCreatorSavingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)
        editing,
    required TResult Function() saving,
    required TResult Function(WeeklyPlan plan) saved,
    required TResult Function(
            String message,
            List<DraftDayPlan> days,
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex)
        error,
  }) {
    return saving();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult? Function()? saving,
    TResult? Function(WeeklyPlan plan)? saved,
    TResult? Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
  }) {
    return saving?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult Function()? saving,
    TResult Function(WeeklyPlan plan)? saved,
    TResult Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
    required TResult orElse(),
  }) {
    if (saving != null) {
      return saving();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeekPlanCreatorEditing value) editing,
    required TResult Function(WeekPlanCreatorSaving value) saving,
    required TResult Function(WeekPlanCreatorSaved value) saved,
    required TResult Function(WeekPlanCreatorError value) error,
  }) {
    return saving(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeekPlanCreatorEditing value)? editing,
    TResult? Function(WeekPlanCreatorSaving value)? saving,
    TResult? Function(WeekPlanCreatorSaved value)? saved,
    TResult? Function(WeekPlanCreatorError value)? error,
  }) {
    return saving?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeekPlanCreatorEditing value)? editing,
    TResult Function(WeekPlanCreatorSaving value)? saving,
    TResult Function(WeekPlanCreatorSaved value)? saved,
    TResult Function(WeekPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (saving != null) {
      return saving(this);
    }
    return orElse();
  }
}

abstract class WeekPlanCreatorSaving implements WeekPlanCreatorState {
  const factory WeekPlanCreatorSaving() = _$WeekPlanCreatorSavingImpl;
}

/// @nodoc
abstract class _$$WeekPlanCreatorSavedImplCopyWith<$Res> {
  factory _$$WeekPlanCreatorSavedImplCopyWith(_$WeekPlanCreatorSavedImpl value,
          $Res Function(_$WeekPlanCreatorSavedImpl) then) =
      __$$WeekPlanCreatorSavedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({WeeklyPlan plan});

  $WeeklyPlanCopyWith<$Res> get plan;
}

/// @nodoc
class __$$WeekPlanCreatorSavedImplCopyWithImpl<$Res>
    extends _$WeekPlanCreatorStateCopyWithImpl<$Res, _$WeekPlanCreatorSavedImpl>
    implements _$$WeekPlanCreatorSavedImplCopyWith<$Res> {
  __$$WeekPlanCreatorSavedImplCopyWithImpl(_$WeekPlanCreatorSavedImpl _value,
      $Res Function(_$WeekPlanCreatorSavedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
  }) {
    return _then(_$WeekPlanCreatorSavedImpl(
      null == plan
          ? _value.plan
          : plan // ignore: cast_nullable_to_non_nullable
              as WeeklyPlan,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $WeeklyPlanCopyWith<$Res> get plan {
    return $WeeklyPlanCopyWith<$Res>(_value.plan, (value) {
      return _then(_value.copyWith(plan: value));
    });
  }
}

/// @nodoc

class _$WeekPlanCreatorSavedImpl implements WeekPlanCreatorSaved {
  const _$WeekPlanCreatorSavedImpl(this.plan);

  @override
  final WeeklyPlan plan;

  @override
  String toString() {
    return 'WeekPlanCreatorState.saved(plan: $plan)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekPlanCreatorSavedImpl &&
            (identical(other.plan, plan) || other.plan == plan));
  }

  @override
  int get hashCode => Object.hash(runtimeType, plan);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekPlanCreatorSavedImplCopyWith<_$WeekPlanCreatorSavedImpl>
      get copyWith =>
          __$$WeekPlanCreatorSavedImplCopyWithImpl<_$WeekPlanCreatorSavedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)
        editing,
    required TResult Function() saving,
    required TResult Function(WeeklyPlan plan) saved,
    required TResult Function(
            String message,
            List<DraftDayPlan> days,
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex)
        error,
  }) {
    return saved(plan);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult? Function()? saving,
    TResult? Function(WeeklyPlan plan)? saved,
    TResult? Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
  }) {
    return saved?.call(plan);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult Function()? saving,
    TResult Function(WeeklyPlan plan)? saved,
    TResult Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved(plan);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeekPlanCreatorEditing value) editing,
    required TResult Function(WeekPlanCreatorSaving value) saving,
    required TResult Function(WeekPlanCreatorSaved value) saved,
    required TResult Function(WeekPlanCreatorError value) error,
  }) {
    return saved(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeekPlanCreatorEditing value)? editing,
    TResult? Function(WeekPlanCreatorSaving value)? saving,
    TResult? Function(WeekPlanCreatorSaved value)? saved,
    TResult? Function(WeekPlanCreatorError value)? error,
  }) {
    return saved?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeekPlanCreatorEditing value)? editing,
    TResult Function(WeekPlanCreatorSaving value)? saving,
    TResult Function(WeekPlanCreatorSaved value)? saved,
    TResult Function(WeekPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (saved != null) {
      return saved(this);
    }
    return orElse();
  }
}

abstract class WeekPlanCreatorSaved implements WeekPlanCreatorState {
  const factory WeekPlanCreatorSaved(final WeeklyPlan plan) =
      _$WeekPlanCreatorSavedImpl;

  WeeklyPlan get plan;
  @JsonKey(ignore: true)
  _$$WeekPlanCreatorSavedImplCopyWith<_$WeekPlanCreatorSavedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WeekPlanCreatorErrorImplCopyWith<$Res> {
  factory _$$WeekPlanCreatorErrorImplCopyWith(_$WeekPlanCreatorErrorImpl value,
          $Res Function(_$WeekPlanCreatorErrorImpl) then) =
      __$$WeekPlanCreatorErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {String message,
      List<DraftDayPlan> days,
      String planName,
      String planNotes,
      bool activateImmediately,
      int selectedDayIndex});
}

/// @nodoc
class __$$WeekPlanCreatorErrorImplCopyWithImpl<$Res>
    extends _$WeekPlanCreatorStateCopyWithImpl<$Res, _$WeekPlanCreatorErrorImpl>
    implements _$$WeekPlanCreatorErrorImplCopyWith<$Res> {
  __$$WeekPlanCreatorErrorImplCopyWithImpl(_$WeekPlanCreatorErrorImpl _value,
      $Res Function(_$WeekPlanCreatorErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? days = null,
    Object? planName = null,
    Object? planNotes = null,
    Object? activateImmediately = null,
    Object? selectedDayIndex = null,
  }) {
    return _then(_$WeekPlanCreatorErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      days: null == days
          ? _value._days
          : days // ignore: cast_nullable_to_non_nullable
              as List<DraftDayPlan>,
      planName: null == planName
          ? _value.planName
          : planName // ignore: cast_nullable_to_non_nullable
              as String,
      planNotes: null == planNotes
          ? _value.planNotes
          : planNotes // ignore: cast_nullable_to_non_nullable
              as String,
      activateImmediately: null == activateImmediately
          ? _value.activateImmediately
          : activateImmediately // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedDayIndex: null == selectedDayIndex
          ? _value.selectedDayIndex
          : selectedDayIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$WeekPlanCreatorErrorImpl implements WeekPlanCreatorError {
  const _$WeekPlanCreatorErrorImpl(
      {required this.message,
      required final List<DraftDayPlan> days,
      this.planName = '',
      this.planNotes = '',
      this.activateImmediately = false,
      this.selectedDayIndex = 0})
      : _days = days;

  @override
  final String message;
// Carry editing state so UI can restore without losing data
  final List<DraftDayPlan> _days;
// Carry editing state so UI can restore without losing data
  @override
  List<DraftDayPlan> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  @JsonKey()
  final String planName;
  @override
  @JsonKey()
  final String planNotes;
  @override
  @JsonKey()
  final bool activateImmediately;
  @override
  @JsonKey()
  final int selectedDayIndex;

  @override
  String toString() {
    return 'WeekPlanCreatorState.error(message: $message, days: $days, planName: $planName, planNotes: $planNotes, activateImmediately: $activateImmediately, selectedDayIndex: $selectedDayIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeekPlanCreatorErrorImpl &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            (identical(other.planName, planName) ||
                other.planName == planName) &&
            (identical(other.planNotes, planNotes) ||
                other.planNotes == planNotes) &&
            (identical(other.activateImmediately, activateImmediately) ||
                other.activateImmediately == activateImmediately) &&
            (identical(other.selectedDayIndex, selectedDayIndex) ||
                other.selectedDayIndex == selectedDayIndex));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      message,
      const DeepCollectionEquality().hash(_days),
      planName,
      planNotes,
      activateImmediately,
      selectedDayIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WeekPlanCreatorErrorImplCopyWith<_$WeekPlanCreatorErrorImpl>
      get copyWith =>
          __$$WeekPlanCreatorErrorImplCopyWithImpl<_$WeekPlanCreatorErrorImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)
        editing,
    required TResult Function() saving,
    required TResult Function(WeeklyPlan plan) saved,
    required TResult Function(
            String message,
            List<DraftDayPlan> days,
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex)
        error,
  }) {
    return error(message, days, planName, planNotes, activateImmediately,
        selectedDayIndex);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult? Function()? saving,
    TResult? Function(WeeklyPlan plan)? saved,
    TResult? Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
  }) {
    return error?.call(message, days, planName, planNotes, activateImmediately,
        selectedDayIndex);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String planName,
            String planNotes,
            bool activateImmediately,
            int selectedDayIndex,
            List<DraftDayPlan> days)?
        editing,
    TResult Function()? saving,
    TResult Function(WeeklyPlan plan)? saved,
    TResult Function(String message, List<DraftDayPlan> days, String planName,
            String planNotes, bool activateImmediately, int selectedDayIndex)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message, days, planName, planNotes, activateImmediately,
          selectedDayIndex);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(WeekPlanCreatorEditing value) editing,
    required TResult Function(WeekPlanCreatorSaving value) saving,
    required TResult Function(WeekPlanCreatorSaved value) saved,
    required TResult Function(WeekPlanCreatorError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(WeekPlanCreatorEditing value)? editing,
    TResult? Function(WeekPlanCreatorSaving value)? saving,
    TResult? Function(WeekPlanCreatorSaved value)? saved,
    TResult? Function(WeekPlanCreatorError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(WeekPlanCreatorEditing value)? editing,
    TResult Function(WeekPlanCreatorSaving value)? saving,
    TResult Function(WeekPlanCreatorSaved value)? saved,
    TResult Function(WeekPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class WeekPlanCreatorError implements WeekPlanCreatorState {
  const factory WeekPlanCreatorError(
      {required final String message,
      required final List<DraftDayPlan> days,
      final String planName,
      final String planNotes,
      final bool activateImmediately,
      final int selectedDayIndex}) = _$WeekPlanCreatorErrorImpl;

  String
      get message; // Carry editing state so UI can restore without losing data
  List<DraftDayPlan> get days;
  String get planName;
  String get planNotes;
  bool get activateImmediately;
  int get selectedDayIndex;
  @JsonKey(ignore: true)
  _$$WeekPlanCreatorErrorImplCopyWith<_$WeekPlanCreatorErrorImpl>
      get copyWith => throw _privateConstructorUsedError;
}
