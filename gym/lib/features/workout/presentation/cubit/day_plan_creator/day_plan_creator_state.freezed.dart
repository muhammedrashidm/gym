// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_plan_creator_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DayPlanCreatorState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)
        loaded,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(DayPlanCreatorLoaded value) loaded,
    required TResult Function(DayPlanCreatorError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(DayPlanCreatorLoaded value)? loaded,
    TResult? Function(DayPlanCreatorError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(DayPlanCreatorLoaded value)? loaded,
    TResult Function(DayPlanCreatorError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayPlanCreatorStateCopyWith<$Res> {
  factory $DayPlanCreatorStateCopyWith(
          DayPlanCreatorState value, $Res Function(DayPlanCreatorState) then) =
      _$DayPlanCreatorStateCopyWithImpl<$Res, DayPlanCreatorState>;
}

/// @nodoc
class _$DayPlanCreatorStateCopyWithImpl<$Res, $Val extends DayPlanCreatorState>
    implements $DayPlanCreatorStateCopyWith<$Res> {
  _$DayPlanCreatorStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$DayPlanCreatorStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'DayPlanCreatorState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)
        loaded,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(DayPlanCreatorLoaded value) loaded,
    required TResult Function(DayPlanCreatorError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(DayPlanCreatorLoaded value)? loaded,
    TResult? Function(DayPlanCreatorError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(DayPlanCreatorLoaded value)? loaded,
    TResult Function(DayPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements DayPlanCreatorState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$DayPlanCreatorStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'DayPlanCreatorState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(DayPlanCreatorLoaded value) loaded,
    required TResult Function(DayPlanCreatorError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(DayPlanCreatorLoaded value)? loaded,
    TResult? Function(DayPlanCreatorError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(DayPlanCreatorLoaded value)? loaded,
    TResult Function(DayPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements DayPlanCreatorState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$DayPlanCreatorLoadedImplCopyWith<$Res> {
  factory _$$DayPlanCreatorLoadedImplCopyWith(_$DayPlanCreatorLoadedImpl value,
          $Res Function(_$DayPlanCreatorLoadedImpl) then) =
      __$$DayPlanCreatorLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({WeeklyPlan weeklyPlan, int selectedDayIndex});

  $WeeklyPlanCopyWith<$Res> get weeklyPlan;
}

/// @nodoc
class __$$DayPlanCreatorLoadedImplCopyWithImpl<$Res>
    extends _$DayPlanCreatorStateCopyWithImpl<$Res, _$DayPlanCreatorLoadedImpl>
    implements _$$DayPlanCreatorLoadedImplCopyWith<$Res> {
  __$$DayPlanCreatorLoadedImplCopyWithImpl(_$DayPlanCreatorLoadedImpl _value,
      $Res Function(_$DayPlanCreatorLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weeklyPlan = null,
    Object? selectedDayIndex = null,
  }) {
    return _then(_$DayPlanCreatorLoadedImpl(
      weeklyPlan: null == weeklyPlan
          ? _value.weeklyPlan
          : weeklyPlan // ignore: cast_nullable_to_non_nullable
              as WeeklyPlan,
      selectedDayIndex: null == selectedDayIndex
          ? _value.selectedDayIndex
          : selectedDayIndex // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $WeeklyPlanCopyWith<$Res> get weeklyPlan {
    return $WeeklyPlanCopyWith<$Res>(_value.weeklyPlan, (value) {
      return _then(_value.copyWith(weeklyPlan: value));
    });
  }
}

/// @nodoc

class _$DayPlanCreatorLoadedImpl implements DayPlanCreatorLoaded {
  const _$DayPlanCreatorLoadedImpl(
      {required this.weeklyPlan, required this.selectedDayIndex});

  @override
  final WeeklyPlan weeklyPlan;
  @override
  final int selectedDayIndex;

  @override
  String toString() {
    return 'DayPlanCreatorState.loaded(weeklyPlan: $weeklyPlan, selectedDayIndex: $selectedDayIndex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayPlanCreatorLoadedImpl &&
            (identical(other.weeklyPlan, weeklyPlan) ||
                other.weeklyPlan == weeklyPlan) &&
            (identical(other.selectedDayIndex, selectedDayIndex) ||
                other.selectedDayIndex == selectedDayIndex));
  }

  @override
  int get hashCode => Object.hash(runtimeType, weeklyPlan, selectedDayIndex);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DayPlanCreatorLoadedImplCopyWith<_$DayPlanCreatorLoadedImpl>
      get copyWith =>
          __$$DayPlanCreatorLoadedImplCopyWithImpl<_$DayPlanCreatorLoadedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)
        loaded,
    required TResult Function(String message) error,
  }) {
    return loaded(weeklyPlan, selectedDayIndex);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult? Function(String message)? error,
  }) {
    return loaded?.call(weeklyPlan, selectedDayIndex);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(weeklyPlan, selectedDayIndex);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(DayPlanCreatorLoaded value) loaded,
    required TResult Function(DayPlanCreatorError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(DayPlanCreatorLoaded value)? loaded,
    TResult? Function(DayPlanCreatorError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(DayPlanCreatorLoaded value)? loaded,
    TResult Function(DayPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class DayPlanCreatorLoaded implements DayPlanCreatorState {
  const factory DayPlanCreatorLoaded(
      {required final WeeklyPlan weeklyPlan,
      required final int selectedDayIndex}) = _$DayPlanCreatorLoadedImpl;

  WeeklyPlan get weeklyPlan;
  int get selectedDayIndex;
  @JsonKey(ignore: true)
  _$$DayPlanCreatorLoadedImplCopyWith<_$DayPlanCreatorLoadedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DayPlanCreatorErrorImplCopyWith<$Res> {
  factory _$$DayPlanCreatorErrorImplCopyWith(_$DayPlanCreatorErrorImpl value,
          $Res Function(_$DayPlanCreatorErrorImpl) then) =
      __$$DayPlanCreatorErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$DayPlanCreatorErrorImplCopyWithImpl<$Res>
    extends _$DayPlanCreatorStateCopyWithImpl<$Res, _$DayPlanCreatorErrorImpl>
    implements _$$DayPlanCreatorErrorImplCopyWith<$Res> {
  __$$DayPlanCreatorErrorImplCopyWithImpl(_$DayPlanCreatorErrorImpl _value,
      $Res Function(_$DayPlanCreatorErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$DayPlanCreatorErrorImpl(
      null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$DayPlanCreatorErrorImpl implements DayPlanCreatorError {
  const _$DayPlanCreatorErrorImpl(this.message);

  @override
  final String message;

  @override
  String toString() {
    return 'DayPlanCreatorState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayPlanCreatorErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DayPlanCreatorErrorImplCopyWith<_$DayPlanCreatorErrorImpl> get copyWith =>
      __$$DayPlanCreatorErrorImplCopyWithImpl<_$DayPlanCreatorErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)
        loaded,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WeeklyPlan weeklyPlan, int selectedDayIndex)? loaded,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(DayPlanCreatorLoaded value) loaded,
    required TResult Function(DayPlanCreatorError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(DayPlanCreatorLoaded value)? loaded,
    TResult? Function(DayPlanCreatorError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(DayPlanCreatorLoaded value)? loaded,
    TResult Function(DayPlanCreatorError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class DayPlanCreatorError implements DayPlanCreatorState {
  const factory DayPlanCreatorError(final String message) =
      _$DayPlanCreatorErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$DayPlanCreatorErrorImplCopyWith<_$DayPlanCreatorErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
