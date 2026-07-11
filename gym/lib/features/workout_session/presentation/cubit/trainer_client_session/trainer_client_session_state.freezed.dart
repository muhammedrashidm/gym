// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_client_session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrainerClientSessionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerClientSessionStateCopyWith<$Res> {
  factory $TrainerClientSessionStateCopyWith(TrainerClientSessionState value,
          $Res Function(TrainerClientSessionState) then) =
      _$TrainerClientSessionStateCopyWithImpl<$Res, TrainerClientSessionState>;
}

/// @nodoc
class _$TrainerClientSessionStateCopyWithImpl<$Res,
        $Val extends TrainerClientSessionState>
    implements $TrainerClientSessionStateCopyWith<$Res> {
  _$TrainerClientSessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$TrainerSessionInitialImplCopyWith<$Res> {
  factory _$$TrainerSessionInitialImplCopyWith(
          _$TrainerSessionInitialImpl value,
          $Res Function(_$TrainerSessionInitialImpl) then) =
      __$$TrainerSessionInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TrainerSessionInitialImplCopyWithImpl<$Res>
    extends _$TrainerClientSessionStateCopyWithImpl<$Res,
        _$TrainerSessionInitialImpl>
    implements _$$TrainerSessionInitialImplCopyWith<$Res> {
  __$$TrainerSessionInitialImplCopyWithImpl(_$TrainerSessionInitialImpl _value,
      $Res Function(_$TrainerSessionInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$TrainerSessionInitialImpl implements TrainerSessionInitial {
  const _$TrainerSessionInitialImpl();

  @override
  String toString() {
    return 'TrainerClientSessionState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSessionInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
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
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class TrainerSessionInitial implements TrainerClientSessionState {
  const factory TrainerSessionInitial() = _$TrainerSessionInitialImpl;
}

/// @nodoc
abstract class _$$TrainerSessionLoadingImplCopyWith<$Res> {
  factory _$$TrainerSessionLoadingImplCopyWith(
          _$TrainerSessionLoadingImpl value,
          $Res Function(_$TrainerSessionLoadingImpl) then) =
      __$$TrainerSessionLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$TrainerSessionLoadingImplCopyWithImpl<$Res>
    extends _$TrainerClientSessionStateCopyWithImpl<$Res,
        _$TrainerSessionLoadingImpl>
    implements _$$TrainerSessionLoadingImplCopyWith<$Res> {
  __$$TrainerSessionLoadingImplCopyWithImpl(_$TrainerSessionLoadingImpl _value,
      $Res Function(_$TrainerSessionLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$TrainerSessionLoadingImpl implements TrainerSessionLoading {
  const _$TrainerSessionLoadingImpl();

  @override
  String toString() {
    return 'TrainerClientSessionState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSessionLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
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
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class TrainerSessionLoading implements TrainerClientSessionState {
  const factory TrainerSessionLoading() = _$TrainerSessionLoadingImpl;
}

/// @nodoc
abstract class _$$TrainerSessionLoadedImplCopyWith<$Res> {
  factory _$$TrainerSessionLoadedImplCopyWith(_$TrainerSessionLoadedImpl value,
          $Res Function(_$TrainerSessionLoadedImpl) then) =
      __$$TrainerSessionLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {WorkoutProfile profile,
      DayPlan dayPlan,
      SessionDraft draft,
      String clientName});

  $WorkoutProfileCopyWith<$Res> get profile;
  $DayPlanCopyWith<$Res> get dayPlan;
  $SessionDraftCopyWith<$Res> get draft;
}

/// @nodoc
class __$$TrainerSessionLoadedImplCopyWithImpl<$Res>
    extends _$TrainerClientSessionStateCopyWithImpl<$Res,
        _$TrainerSessionLoadedImpl>
    implements _$$TrainerSessionLoadedImplCopyWith<$Res> {
  __$$TrainerSessionLoadedImplCopyWithImpl(_$TrainerSessionLoadedImpl _value,
      $Res Function(_$TrainerSessionLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? dayPlan = null,
    Object? draft = null,
    Object? clientName = null,
  }) {
    return _then(_$TrainerSessionLoadedImpl(
      profile: null == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as WorkoutProfile,
      dayPlan: null == dayPlan
          ? _value.dayPlan
          : dayPlan // ignore: cast_nullable_to_non_nullable
              as DayPlan,
      draft: null == draft
          ? _value.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as SessionDraft,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutProfileCopyWith<$Res> get profile {
    return $WorkoutProfileCopyWith<$Res>(_value.profile, (value) {
      return _then(_value.copyWith(profile: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DayPlanCopyWith<$Res> get dayPlan {
    return $DayPlanCopyWith<$Res>(_value.dayPlan, (value) {
      return _then(_value.copyWith(dayPlan: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SessionDraftCopyWith<$Res> get draft {
    return $SessionDraftCopyWith<$Res>(_value.draft, (value) {
      return _then(_value.copyWith(draft: value));
    });
  }
}

/// @nodoc

class _$TrainerSessionLoadedImpl implements TrainerSessionLoaded {
  const _$TrainerSessionLoadedImpl(
      {required this.profile,
      required this.dayPlan,
      required this.draft,
      required this.clientName});

  @override
  final WorkoutProfile profile;
  @override
  final DayPlan dayPlan;
  @override
  final SessionDraft draft;
  @override
  final String clientName;

  @override
  String toString() {
    return 'TrainerClientSessionState.loaded(profile: $profile, dayPlan: $dayPlan, draft: $draft, clientName: $clientName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSessionLoadedImpl &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.dayPlan, dayPlan) || other.dayPlan == dayPlan) &&
            (identical(other.draft, draft) || other.draft == draft) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, profile, dayPlan, draft, clientName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerSessionLoadedImplCopyWith<_$TrainerSessionLoadedImpl>
      get copyWith =>
          __$$TrainerSessionLoadedImplCopyWithImpl<_$TrainerSessionLoadedImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) {
    return loaded(profile, dayPlan, draft, clientName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) {
    return loaded?.call(profile, dayPlan, draft, clientName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(profile, dayPlan, draft, clientName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class TrainerSessionLoaded implements TrainerClientSessionState {
  const factory TrainerSessionLoaded(
      {required final WorkoutProfile profile,
      required final DayPlan dayPlan,
      required final SessionDraft draft,
      required final String clientName}) = _$TrainerSessionLoadedImpl;

  WorkoutProfile get profile;
  DayPlan get dayPlan;
  SessionDraft get draft;
  String get clientName;
  @JsonKey(ignore: true)
  _$$TrainerSessionLoadedImplCopyWith<_$TrainerSessionLoadedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerSessionNoPlanImplCopyWith<$Res> {
  factory _$$TrainerSessionNoPlanImplCopyWith(_$TrainerSessionNoPlanImpl value,
          $Res Function(_$TrainerSessionNoPlanImpl) then) =
      __$$TrainerSessionNoPlanImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String clientName});
}

/// @nodoc
class __$$TrainerSessionNoPlanImplCopyWithImpl<$Res>
    extends _$TrainerClientSessionStateCopyWithImpl<$Res,
        _$TrainerSessionNoPlanImpl>
    implements _$$TrainerSessionNoPlanImplCopyWith<$Res> {
  __$$TrainerSessionNoPlanImplCopyWithImpl(_$TrainerSessionNoPlanImpl _value,
      $Res Function(_$TrainerSessionNoPlanImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientName = null,
  }) {
    return _then(_$TrainerSessionNoPlanImpl(
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TrainerSessionNoPlanImpl implements TrainerSessionNoPlan {
  const _$TrainerSessionNoPlanImpl({required this.clientName});

  @override
  final String clientName;

  @override
  String toString() {
    return 'TrainerClientSessionState.noPlan(clientName: $clientName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSessionNoPlanImpl &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName));
  }

  @override
  int get hashCode => Object.hash(runtimeType, clientName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerSessionNoPlanImplCopyWith<_$TrainerSessionNoPlanImpl>
      get copyWith =>
          __$$TrainerSessionNoPlanImplCopyWithImpl<_$TrainerSessionNoPlanImpl>(
              this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) {
    return noPlan(clientName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) {
    return noPlan?.call(clientName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
    required TResult orElse(),
  }) {
    if (noPlan != null) {
      return noPlan(clientName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) {
    return noPlan(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) {
    return noPlan?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) {
    if (noPlan != null) {
      return noPlan(this);
    }
    return orElse();
  }
}

abstract class TrainerSessionNoPlan implements TrainerClientSessionState {
  const factory TrainerSessionNoPlan({required final String clientName}) =
      _$TrainerSessionNoPlanImpl;

  String get clientName;
  @JsonKey(ignore: true)
  _$$TrainerSessionNoPlanImplCopyWith<_$TrainerSessionNoPlanImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerSessionSubmittingImplCopyWith<$Res> {
  factory _$$TrainerSessionSubmittingImplCopyWith(
          _$TrainerSessionSubmittingImpl value,
          $Res Function(_$TrainerSessionSubmittingImpl) then) =
      __$$TrainerSessionSubmittingImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {WorkoutProfile profile,
      DayPlan dayPlan,
      SessionDraft draft,
      String clientName});

  $WorkoutProfileCopyWith<$Res> get profile;
  $DayPlanCopyWith<$Res> get dayPlan;
  $SessionDraftCopyWith<$Res> get draft;
}

/// @nodoc
class __$$TrainerSessionSubmittingImplCopyWithImpl<$Res>
    extends _$TrainerClientSessionStateCopyWithImpl<$Res,
        _$TrainerSessionSubmittingImpl>
    implements _$$TrainerSessionSubmittingImplCopyWith<$Res> {
  __$$TrainerSessionSubmittingImplCopyWithImpl(
      _$TrainerSessionSubmittingImpl _value,
      $Res Function(_$TrainerSessionSubmittingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profile = null,
    Object? dayPlan = null,
    Object? draft = null,
    Object? clientName = null,
  }) {
    return _then(_$TrainerSessionSubmittingImpl(
      profile: null == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as WorkoutProfile,
      dayPlan: null == dayPlan
          ? _value.dayPlan
          : dayPlan // ignore: cast_nullable_to_non_nullable
              as DayPlan,
      draft: null == draft
          ? _value.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as SessionDraft,
      clientName: null == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutProfileCopyWith<$Res> get profile {
    return $WorkoutProfileCopyWith<$Res>(_value.profile, (value) {
      return _then(_value.copyWith(profile: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DayPlanCopyWith<$Res> get dayPlan {
    return $DayPlanCopyWith<$Res>(_value.dayPlan, (value) {
      return _then(_value.copyWith(dayPlan: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SessionDraftCopyWith<$Res> get draft {
    return $SessionDraftCopyWith<$Res>(_value.draft, (value) {
      return _then(_value.copyWith(draft: value));
    });
  }
}

/// @nodoc

class _$TrainerSessionSubmittingImpl implements TrainerSessionSubmitting {
  const _$TrainerSessionSubmittingImpl(
      {required this.profile,
      required this.dayPlan,
      required this.draft,
      required this.clientName});

  @override
  final WorkoutProfile profile;
  @override
  final DayPlan dayPlan;
  @override
  final SessionDraft draft;
  @override
  final String clientName;

  @override
  String toString() {
    return 'TrainerClientSessionState.submitting(profile: $profile, dayPlan: $dayPlan, draft: $draft, clientName: $clientName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSessionSubmittingImpl &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.dayPlan, dayPlan) || other.dayPlan == dayPlan) &&
            (identical(other.draft, draft) || other.draft == draft) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, profile, dayPlan, draft, clientName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerSessionSubmittingImplCopyWith<_$TrainerSessionSubmittingImpl>
      get copyWith => __$$TrainerSessionSubmittingImplCopyWithImpl<
          _$TrainerSessionSubmittingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) {
    return submitting(profile, dayPlan, draft, clientName);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) {
    return submitting?.call(profile, dayPlan, draft, clientName);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting(profile, dayPlan, draft, clientName);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) {
    return submitting(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) {
    return submitting?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) {
    if (submitting != null) {
      return submitting(this);
    }
    return orElse();
  }
}

abstract class TrainerSessionSubmitting implements TrainerClientSessionState {
  const factory TrainerSessionSubmitting(
      {required final WorkoutProfile profile,
      required final DayPlan dayPlan,
      required final SessionDraft draft,
      required final String clientName}) = _$TrainerSessionSubmittingImpl;

  WorkoutProfile get profile;
  DayPlan get dayPlan;
  SessionDraft get draft;
  String get clientName;
  @JsonKey(ignore: true)
  _$$TrainerSessionSubmittingImplCopyWith<_$TrainerSessionSubmittingImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerSessionSubmittedImplCopyWith<$Res> {
  factory _$$TrainerSessionSubmittedImplCopyWith(
          _$TrainerSessionSubmittedImpl value,
          $Res Function(_$TrainerSessionSubmittedImpl) then) =
      __$$TrainerSessionSubmittedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({WorkoutSessionLog sessionLog});

  $WorkoutSessionLogCopyWith<$Res> get sessionLog;
}

/// @nodoc
class __$$TrainerSessionSubmittedImplCopyWithImpl<$Res>
    extends _$TrainerClientSessionStateCopyWithImpl<$Res,
        _$TrainerSessionSubmittedImpl>
    implements _$$TrainerSessionSubmittedImplCopyWith<$Res> {
  __$$TrainerSessionSubmittedImplCopyWithImpl(
      _$TrainerSessionSubmittedImpl _value,
      $Res Function(_$TrainerSessionSubmittedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionLog = null,
  }) {
    return _then(_$TrainerSessionSubmittedImpl(
      sessionLog: null == sessionLog
          ? _value.sessionLog
          : sessionLog // ignore: cast_nullable_to_non_nullable
              as WorkoutSessionLog,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutSessionLogCopyWith<$Res> get sessionLog {
    return $WorkoutSessionLogCopyWith<$Res>(_value.sessionLog, (value) {
      return _then(_value.copyWith(sessionLog: value));
    });
  }
}

/// @nodoc

class _$TrainerSessionSubmittedImpl implements TrainerSessionSubmitted {
  const _$TrainerSessionSubmittedImpl({required this.sessionLog});

  @override
  final WorkoutSessionLog sessionLog;

  @override
  String toString() {
    return 'TrainerClientSessionState.submitted(sessionLog: $sessionLog)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSessionSubmittedImpl &&
            (identical(other.sessionLog, sessionLog) ||
                other.sessionLog == sessionLog));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionLog);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerSessionSubmittedImplCopyWith<_$TrainerSessionSubmittedImpl>
      get copyWith => __$$TrainerSessionSubmittedImplCopyWithImpl<
          _$TrainerSessionSubmittedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) {
    return submitted(sessionLog);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) {
    return submitted?.call(sessionLog);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
    required TResult orElse(),
  }) {
    if (submitted != null) {
      return submitted(sessionLog);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) {
    return submitted(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) {
    return submitted?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) {
    if (submitted != null) {
      return submitted(this);
    }
    return orElse();
  }
}

abstract class TrainerSessionSubmitted implements TrainerClientSessionState {
  const factory TrainerSessionSubmitted(
          {required final WorkoutSessionLog sessionLog}) =
      _$TrainerSessionSubmittedImpl;

  WorkoutSessionLog get sessionLog;
  @JsonKey(ignore: true)
  _$$TrainerSessionSubmittedImplCopyWith<_$TrainerSessionSubmittedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$TrainerSessionErrorImplCopyWith<$Res> {
  factory _$$TrainerSessionErrorImplCopyWith(_$TrainerSessionErrorImpl value,
          $Res Function(_$TrainerSessionErrorImpl) then) =
      __$$TrainerSessionErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {Failure failure,
      String? clientName,
      WorkoutProfile? profile,
      DayPlan? dayPlan,
      SessionDraft? draft});

  $FailureCopyWith<$Res> get failure;
  $WorkoutProfileCopyWith<$Res>? get profile;
  $DayPlanCopyWith<$Res>? get dayPlan;
  $SessionDraftCopyWith<$Res>? get draft;
}

/// @nodoc
class __$$TrainerSessionErrorImplCopyWithImpl<$Res>
    extends _$TrainerClientSessionStateCopyWithImpl<$Res,
        _$TrainerSessionErrorImpl>
    implements _$$TrainerSessionErrorImplCopyWith<$Res> {
  __$$TrainerSessionErrorImplCopyWithImpl(_$TrainerSessionErrorImpl _value,
      $Res Function(_$TrainerSessionErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
    Object? clientName = freezed,
    Object? profile = freezed,
    Object? dayPlan = freezed,
    Object? draft = freezed,
  }) {
    return _then(_$TrainerSessionErrorImpl(
      failure: null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
      clientName: freezed == clientName
          ? _value.clientName
          : clientName // ignore: cast_nullable_to_non_nullable
              as String?,
      profile: freezed == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as WorkoutProfile?,
      dayPlan: freezed == dayPlan
          ? _value.dayPlan
          : dayPlan // ignore: cast_nullable_to_non_nullable
              as DayPlan?,
      draft: freezed == draft
          ? _value.draft
          : draft // ignore: cast_nullable_to_non_nullable
              as SessionDraft?,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res> get failure {
    return $FailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkoutProfileCopyWith<$Res>? get profile {
    if (_value.profile == null) {
      return null;
    }

    return $WorkoutProfileCopyWith<$Res>(_value.profile!, (value) {
      return _then(_value.copyWith(profile: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $DayPlanCopyWith<$Res>? get dayPlan {
    if (_value.dayPlan == null) {
      return null;
    }

    return $DayPlanCopyWith<$Res>(_value.dayPlan!, (value) {
      return _then(_value.copyWith(dayPlan: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $SessionDraftCopyWith<$Res>? get draft {
    if (_value.draft == null) {
      return null;
    }

    return $SessionDraftCopyWith<$Res>(_value.draft!, (value) {
      return _then(_value.copyWith(draft: value));
    });
  }
}

/// @nodoc

class _$TrainerSessionErrorImpl implements TrainerSessionError {
  const _$TrainerSessionErrorImpl(
      {required this.failure,
      this.clientName,
      this.profile,
      this.dayPlan,
      this.draft});

  @override
  final Failure failure;
  @override
  final String? clientName;
  @override
  final WorkoutProfile? profile;
  @override
  final DayPlan? dayPlan;
  @override
  final SessionDraft? draft;

  @override
  String toString() {
    return 'TrainerClientSessionState.error(failure: $failure, clientName: $clientName, profile: $profile, dayPlan: $dayPlan, draft: $draft)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSessionErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure) &&
            (identical(other.clientName, clientName) ||
                other.clientName == clientName) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.dayPlan, dayPlan) || other.dayPlan == dayPlan) &&
            (identical(other.draft, draft) || other.draft == draft));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, failure, clientName, profile, dayPlan, draft);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerSessionErrorImplCopyWith<_$TrainerSessionErrorImpl> get copyWith =>
      __$$TrainerSessionErrorImplCopyWithImpl<_$TrainerSessionErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        loaded,
    required TResult Function(String clientName) noPlan,
    required TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)
        submitting,
    required TResult Function(WorkoutSessionLog sessionLog) submitted,
    required TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)
        error,
  }) {
    return error(failure, clientName, profile, dayPlan, draft);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult? Function(String clientName)? noPlan,
    TResult? Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult? Function(WorkoutSessionLog sessionLog)? submitted,
    TResult? Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
  }) {
    return error?.call(failure, clientName, profile, dayPlan, draft);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        loaded,
    TResult Function(String clientName)? noPlan,
    TResult Function(WorkoutProfile profile, DayPlan dayPlan,
            SessionDraft draft, String clientName)?
        submitting,
    TResult Function(WorkoutSessionLog sessionLog)? submitted,
    TResult Function(Failure failure, String? clientName,
            WorkoutProfile? profile, DayPlan? dayPlan, SessionDraft? draft)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure, clientName, profile, dayPlan, draft);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TrainerSessionInitial value) initial,
    required TResult Function(TrainerSessionLoading value) loading,
    required TResult Function(TrainerSessionLoaded value) loaded,
    required TResult Function(TrainerSessionNoPlan value) noPlan,
    required TResult Function(TrainerSessionSubmitting value) submitting,
    required TResult Function(TrainerSessionSubmitted value) submitted,
    required TResult Function(TrainerSessionError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(TrainerSessionInitial value)? initial,
    TResult? Function(TrainerSessionLoading value)? loading,
    TResult? Function(TrainerSessionLoaded value)? loaded,
    TResult? Function(TrainerSessionNoPlan value)? noPlan,
    TResult? Function(TrainerSessionSubmitting value)? submitting,
    TResult? Function(TrainerSessionSubmitted value)? submitted,
    TResult? Function(TrainerSessionError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TrainerSessionInitial value)? initial,
    TResult Function(TrainerSessionLoading value)? loading,
    TResult Function(TrainerSessionLoaded value)? loaded,
    TResult Function(TrainerSessionNoPlan value)? noPlan,
    TResult Function(TrainerSessionSubmitting value)? submitting,
    TResult Function(TrainerSessionSubmitted value)? submitted,
    TResult Function(TrainerSessionError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class TrainerSessionError implements TrainerClientSessionState {
  const factory TrainerSessionError(
      {required final Failure failure,
      final String? clientName,
      final WorkoutProfile? profile,
      final DayPlan? dayPlan,
      final SessionDraft? draft}) = _$TrainerSessionErrorImpl;

  Failure get failure;
  String? get clientName;
  WorkoutProfile? get profile;
  DayPlan? get dayPlan;
  SessionDraft? get draft;
  @JsonKey(ignore: true)
  _$$TrainerSessionErrorImplCopyWith<_$TrainerSessionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
