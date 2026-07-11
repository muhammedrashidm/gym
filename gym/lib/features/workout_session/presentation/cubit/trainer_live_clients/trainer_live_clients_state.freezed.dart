// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_live_clients_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrainerLiveClientsState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)
        loaded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LiveClientsInitial value) initial,
    required TResult Function(LiveClientsLoading value) loading,
    required TResult Function(LiveClientsLoaded value) loaded,
    required TResult Function(LiveClientsError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LiveClientsInitial value)? initial,
    TResult? Function(LiveClientsLoading value)? loading,
    TResult? Function(LiveClientsLoaded value)? loaded,
    TResult? Function(LiveClientsError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LiveClientsInitial value)? initial,
    TResult Function(LiveClientsLoading value)? loading,
    TResult Function(LiveClientsLoaded value)? loaded,
    TResult Function(LiveClientsError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerLiveClientsStateCopyWith<$Res> {
  factory $TrainerLiveClientsStateCopyWith(TrainerLiveClientsState value,
          $Res Function(TrainerLiveClientsState) then) =
      _$TrainerLiveClientsStateCopyWithImpl<$Res, TrainerLiveClientsState>;
}

/// @nodoc
class _$TrainerLiveClientsStateCopyWithImpl<$Res,
        $Val extends TrainerLiveClientsState>
    implements $TrainerLiveClientsStateCopyWith<$Res> {
  _$TrainerLiveClientsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$LiveClientsInitialImplCopyWith<$Res> {
  factory _$$LiveClientsInitialImplCopyWith(_$LiveClientsInitialImpl value,
          $Res Function(_$LiveClientsInitialImpl) then) =
      __$$LiveClientsInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LiveClientsInitialImplCopyWithImpl<$Res>
    extends _$TrainerLiveClientsStateCopyWithImpl<$Res,
        _$LiveClientsInitialImpl>
    implements _$$LiveClientsInitialImplCopyWith<$Res> {
  __$$LiveClientsInitialImplCopyWithImpl(_$LiveClientsInitialImpl _value,
      $Res Function(_$LiveClientsInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LiveClientsInitialImpl implements LiveClientsInitial {
  const _$LiveClientsInitialImpl();

  @override
  String toString() {
    return 'TrainerLiveClientsState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LiveClientsInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult Function(Failure failure)? error,
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
    required TResult Function(LiveClientsInitial value) initial,
    required TResult Function(LiveClientsLoading value) loading,
    required TResult Function(LiveClientsLoaded value) loaded,
    required TResult Function(LiveClientsError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LiveClientsInitial value)? initial,
    TResult? Function(LiveClientsLoading value)? loading,
    TResult? Function(LiveClientsLoaded value)? loaded,
    TResult? Function(LiveClientsError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LiveClientsInitial value)? initial,
    TResult Function(LiveClientsLoading value)? loading,
    TResult Function(LiveClientsLoaded value)? loaded,
    TResult Function(LiveClientsError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class LiveClientsInitial implements TrainerLiveClientsState {
  const factory LiveClientsInitial() = _$LiveClientsInitialImpl;
}

/// @nodoc
abstract class _$$LiveClientsLoadingImplCopyWith<$Res> {
  factory _$$LiveClientsLoadingImplCopyWith(_$LiveClientsLoadingImpl value,
          $Res Function(_$LiveClientsLoadingImpl) then) =
      __$$LiveClientsLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LiveClientsLoadingImplCopyWithImpl<$Res>
    extends _$TrainerLiveClientsStateCopyWithImpl<$Res,
        _$LiveClientsLoadingImpl>
    implements _$$LiveClientsLoadingImplCopyWith<$Res> {
  __$$LiveClientsLoadingImplCopyWithImpl(_$LiveClientsLoadingImpl _value,
      $Res Function(_$LiveClientsLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$LiveClientsLoadingImpl implements LiveClientsLoading {
  const _$LiveClientsLoadingImpl();

  @override
  String toString() {
    return 'TrainerLiveClientsState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LiveClientsLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult Function(Failure failure)? error,
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
    required TResult Function(LiveClientsInitial value) initial,
    required TResult Function(LiveClientsLoading value) loading,
    required TResult Function(LiveClientsLoaded value) loaded,
    required TResult Function(LiveClientsError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LiveClientsInitial value)? initial,
    TResult? Function(LiveClientsLoading value)? loading,
    TResult? Function(LiveClientsLoaded value)? loaded,
    TResult? Function(LiveClientsError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LiveClientsInitial value)? initial,
    TResult Function(LiveClientsLoading value)? loading,
    TResult Function(LiveClientsLoaded value)? loaded,
    TResult Function(LiveClientsError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class LiveClientsLoading implements TrainerLiveClientsState {
  const factory LiveClientsLoading() = _$LiveClientsLoadingImpl;
}

/// @nodoc
abstract class _$$LiveClientsLoadedImplCopyWith<$Res> {
  factory _$$LiveClientsLoadedImplCopyWith(_$LiveClientsLoadedImpl value,
          $Res Function(_$LiveClientsLoadedImpl) then) =
      __$$LiveClientsLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<ClientWithSessionStatus> activeClients,
      List<ClientWithSessionStatus> idleClients});
}

/// @nodoc
class __$$LiveClientsLoadedImplCopyWithImpl<$Res>
    extends _$TrainerLiveClientsStateCopyWithImpl<$Res, _$LiveClientsLoadedImpl>
    implements _$$LiveClientsLoadedImplCopyWith<$Res> {
  __$$LiveClientsLoadedImplCopyWithImpl(_$LiveClientsLoadedImpl _value,
      $Res Function(_$LiveClientsLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeClients = null,
    Object? idleClients = null,
  }) {
    return _then(_$LiveClientsLoadedImpl(
      activeClients: null == activeClients
          ? _value._activeClients
          : activeClients // ignore: cast_nullable_to_non_nullable
              as List<ClientWithSessionStatus>,
      idleClients: null == idleClients
          ? _value._idleClients
          : idleClients // ignore: cast_nullable_to_non_nullable
              as List<ClientWithSessionStatus>,
    ));
  }
}

/// @nodoc

class _$LiveClientsLoadedImpl implements LiveClientsLoaded {
  const _$LiveClientsLoadedImpl(
      {required final List<ClientWithSessionStatus> activeClients,
      required final List<ClientWithSessionStatus> idleClients})
      : _activeClients = activeClients,
        _idleClients = idleClients;

  final List<ClientWithSessionStatus> _activeClients;
  @override
  List<ClientWithSessionStatus> get activeClients {
    if (_activeClients is EqualUnmodifiableListView) return _activeClients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activeClients);
  }

  final List<ClientWithSessionStatus> _idleClients;
  @override
  List<ClientWithSessionStatus> get idleClients {
    if (_idleClients is EqualUnmodifiableListView) return _idleClients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_idleClients);
  }

  @override
  String toString() {
    return 'TrainerLiveClientsState.loaded(activeClients: $activeClients, idleClients: $idleClients)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveClientsLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._activeClients, _activeClients) &&
            const DeepCollectionEquality()
                .equals(other._idleClients, _idleClients));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_activeClients),
      const DeepCollectionEquality().hash(_idleClients));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveClientsLoadedImplCopyWith<_$LiveClientsLoadedImpl> get copyWith =>
      __$$LiveClientsLoadedImplCopyWithImpl<_$LiveClientsLoadedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(activeClients, idleClients);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(activeClients, idleClients);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(activeClients, idleClients);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LiveClientsInitial value) initial,
    required TResult Function(LiveClientsLoading value) loading,
    required TResult Function(LiveClientsLoaded value) loaded,
    required TResult Function(LiveClientsError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LiveClientsInitial value)? initial,
    TResult? Function(LiveClientsLoading value)? loading,
    TResult? Function(LiveClientsLoaded value)? loaded,
    TResult? Function(LiveClientsError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LiveClientsInitial value)? initial,
    TResult Function(LiveClientsLoading value)? loading,
    TResult Function(LiveClientsLoaded value)? loaded,
    TResult Function(LiveClientsError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class LiveClientsLoaded implements TrainerLiveClientsState {
  const factory LiveClientsLoaded(
          {required final List<ClientWithSessionStatus> activeClients,
          required final List<ClientWithSessionStatus> idleClients}) =
      _$LiveClientsLoadedImpl;

  List<ClientWithSessionStatus> get activeClients;
  List<ClientWithSessionStatus> get idleClients;
  @JsonKey(ignore: true)
  _$$LiveClientsLoadedImplCopyWith<_$LiveClientsLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$LiveClientsErrorImplCopyWith<$Res> {
  factory _$$LiveClientsErrorImplCopyWith(_$LiveClientsErrorImpl value,
          $Res Function(_$LiveClientsErrorImpl) then) =
      __$$LiveClientsErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});

  $FailureCopyWith<$Res> get failure;
}

/// @nodoc
class __$$LiveClientsErrorImplCopyWithImpl<$Res>
    extends _$TrainerLiveClientsStateCopyWithImpl<$Res, _$LiveClientsErrorImpl>
    implements _$$LiveClientsErrorImplCopyWith<$Res> {
  __$$LiveClientsErrorImplCopyWithImpl(_$LiveClientsErrorImpl _value,
      $Res Function(_$LiveClientsErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$LiveClientsErrorImpl(
      failure: null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $FailureCopyWith<$Res> get failure {
    return $FailureCopyWith<$Res>(_value.failure, (value) {
      return _then(_value.copyWith(failure: value));
    });
  }
}

/// @nodoc

class _$LiveClientsErrorImpl implements LiveClientsError {
  const _$LiveClientsErrorImpl({required this.failure});

  @override
  final Failure failure;

  @override
  String toString() {
    return 'TrainerLiveClientsState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LiveClientsErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LiveClientsErrorImplCopyWith<_$LiveClientsErrorImpl> get copyWith =>
      __$$LiveClientsErrorImplCopyWithImpl<_$LiveClientsErrorImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(List<ClientWithSessionStatus> activeClients,
            List<ClientWithSessionStatus> idleClients)?
        loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(LiveClientsInitial value) initial,
    required TResult Function(LiveClientsLoading value) loading,
    required TResult Function(LiveClientsLoaded value) loaded,
    required TResult Function(LiveClientsError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(LiveClientsInitial value)? initial,
    TResult? Function(LiveClientsLoading value)? loading,
    TResult? Function(LiveClientsLoaded value)? loaded,
    TResult? Function(LiveClientsError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(LiveClientsInitial value)? initial,
    TResult Function(LiveClientsLoading value)? loading,
    TResult Function(LiveClientsLoaded value)? loaded,
    TResult Function(LiveClientsError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class LiveClientsError implements TrainerLiveClientsState {
  const factory LiveClientsError({required final Failure failure}) =
      _$LiveClientsErrorImpl;

  Failure get failure;
  @JsonKey(ignore: true)
  _$$LiveClientsErrorImplCopyWith<_$LiveClientsErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
