// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SessionState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(
            List<UserRole> availableRoles, UserRole? activeRole)
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<UserRole> availableRoles, UserRole? activeRole)?
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<UserRole> availableRoles, UserRole? activeRole)?
        loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SessionInitial value) initial,
    required TResult Function(SessionLoaded value) loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SessionInitial value)? initial,
    TResult? Function(SessionLoaded value)? loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SessionInitial value)? initial,
    TResult Function(SessionLoaded value)? loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SessionStateCopyWith<$Res> {
  factory $SessionStateCopyWith(
          SessionState value, $Res Function(SessionState) then) =
      _$SessionStateCopyWithImpl<$Res, SessionState>;
}

/// @nodoc
class _$SessionStateCopyWithImpl<$Res, $Val extends SessionState>
    implements $SessionStateCopyWith<$Res> {
  _$SessionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$SessionInitialImplCopyWith<$Res> {
  factory _$$SessionInitialImplCopyWith(_$SessionInitialImpl value,
          $Res Function(_$SessionInitialImpl) then) =
      __$$SessionInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$SessionInitialImplCopyWithImpl<$Res>
    extends _$SessionStateCopyWithImpl<$Res, _$SessionInitialImpl>
    implements _$$SessionInitialImplCopyWith<$Res> {
  __$$SessionInitialImplCopyWithImpl(
      _$SessionInitialImpl _value, $Res Function(_$SessionInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$SessionInitialImpl implements SessionInitial {
  const _$SessionInitialImpl();

  @override
  String toString() {
    return 'SessionState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$SessionInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(
            List<UserRole> availableRoles, UserRole? activeRole)
        loaded,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<UserRole> availableRoles, UserRole? activeRole)?
        loaded,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<UserRole> availableRoles, UserRole? activeRole)?
        loaded,
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
    required TResult Function(SessionInitial value) initial,
    required TResult Function(SessionLoaded value) loaded,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SessionInitial value)? initial,
    TResult? Function(SessionLoaded value)? loaded,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SessionInitial value)? initial,
    TResult Function(SessionLoaded value)? loaded,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class SessionInitial implements SessionState {
  const factory SessionInitial() = _$SessionInitialImpl;
}

/// @nodoc
abstract class _$$SessionLoadedImplCopyWith<$Res> {
  factory _$$SessionLoadedImplCopyWith(
          _$SessionLoadedImpl value, $Res Function(_$SessionLoadedImpl) then) =
      __$$SessionLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<UserRole> availableRoles, UserRole? activeRole});

  $UserRoleCopyWith<$Res>? get activeRole;
}

/// @nodoc
class __$$SessionLoadedImplCopyWithImpl<$Res>
    extends _$SessionStateCopyWithImpl<$Res, _$SessionLoadedImpl>
    implements _$$SessionLoadedImplCopyWith<$Res> {
  __$$SessionLoadedImplCopyWithImpl(
      _$SessionLoadedImpl _value, $Res Function(_$SessionLoadedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? availableRoles = null,
    Object? activeRole = freezed,
  }) {
    return _then(_$SessionLoadedImpl(
      availableRoles: null == availableRoles
          ? _value._availableRoles
          : availableRoles // ignore: cast_nullable_to_non_nullable
              as List<UserRole>,
      activeRole: freezed == activeRole
          ? _value.activeRole
          : activeRole // ignore: cast_nullable_to_non_nullable
              as UserRole?,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $UserRoleCopyWith<$Res>? get activeRole {
    if (_value.activeRole == null) {
      return null;
    }

    return $UserRoleCopyWith<$Res>(_value.activeRole!, (value) {
      return _then(_value.copyWith(activeRole: value));
    });
  }
}

/// @nodoc

class _$SessionLoadedImpl implements SessionLoaded {
  const _$SessionLoadedImpl(
      {required final List<UserRole> availableRoles, this.activeRole})
      : _availableRoles = availableRoles;

  final List<UserRole> _availableRoles;
  @override
  List<UserRole> get availableRoles {
    if (_availableRoles is EqualUnmodifiableListView) return _availableRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableRoles);
  }

  @override
  final UserRole? activeRole;

  @override
  String toString() {
    return 'SessionState.loaded(availableRoles: $availableRoles, activeRole: $activeRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionLoadedImpl &&
            const DeepCollectionEquality()
                .equals(other._availableRoles, _availableRoles) &&
            (identical(other.activeRole, activeRole) ||
                other.activeRole == activeRole));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_availableRoles), activeRole);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionLoadedImplCopyWith<_$SessionLoadedImpl> get copyWith =>
      __$$SessionLoadedImplCopyWithImpl<_$SessionLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(
            List<UserRole> availableRoles, UserRole? activeRole)
        loaded,
  }) {
    return loaded(availableRoles, activeRole);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(List<UserRole> availableRoles, UserRole? activeRole)?
        loaded,
  }) {
    return loaded?.call(availableRoles, activeRole);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(List<UserRole> availableRoles, UserRole? activeRole)?
        loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(availableRoles, activeRole);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(SessionInitial value) initial,
    required TResult Function(SessionLoaded value) loaded,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(SessionInitial value)? initial,
    TResult? Function(SessionLoaded value)? loaded,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(SessionInitial value)? initial,
    TResult Function(SessionLoaded value)? loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class SessionLoaded implements SessionState {
  const factory SessionLoaded(
      {required final List<UserRole> availableRoles,
      final UserRole? activeRole}) = _$SessionLoadedImpl;

  List<UserRole> get availableRoles;
  UserRole? get activeRole;
  @JsonKey(ignore: true)
  _$$SessionLoadedImplCopyWith<_$SessionLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
