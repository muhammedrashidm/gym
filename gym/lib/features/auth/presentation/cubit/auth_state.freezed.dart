// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthStateCopyWith<$Res> {
  factory $AuthStateCopyWith(AuthState value, $Res Function(AuthState) then) =
      _$AuthStateCopyWithImpl<$Res, AuthState>;
}

/// @nodoc
class _$AuthStateCopyWithImpl<$Res, $Val extends AuthState>
    implements $AuthStateCopyWith<$Res> {
  _$AuthStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AuthInitialImplCopyWith<$Res> {
  factory _$$AuthInitialImplCopyWith(
          _$AuthInitialImpl value, $Res Function(_$AuthInitialImpl) then) =
      __$$AuthInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthInitialImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthInitialImpl>
    implements _$$AuthInitialImplCopyWith<$Res> {
  __$$AuthInitialImplCopyWithImpl(
      _$AuthInitialImpl _value, $Res Function(_$AuthInitialImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthInitialImpl implements AuthInitial {
  const _$AuthInitialImpl();

  @override
  String toString() {
    return 'AuthState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
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
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class AuthInitial implements AuthState {
  const factory AuthInitial() = _$AuthInitialImpl;
}

/// @nodoc
abstract class _$$AuthCheckingTokenImplCopyWith<$Res> {
  factory _$$AuthCheckingTokenImplCopyWith(_$AuthCheckingTokenImpl value,
          $Res Function(_$AuthCheckingTokenImpl) then) =
      __$$AuthCheckingTokenImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthCheckingTokenImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthCheckingTokenImpl>
    implements _$$AuthCheckingTokenImplCopyWith<$Res> {
  __$$AuthCheckingTokenImplCopyWithImpl(_$AuthCheckingTokenImpl _value,
      $Res Function(_$AuthCheckingTokenImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthCheckingTokenImpl implements AuthCheckingToken {
  const _$AuthCheckingTokenImpl();

  @override
  String toString() {
    return 'AuthState.checkingToken()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthCheckingTokenImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) {
    return checkingToken();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) {
    return checkingToken?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
    required TResult orElse(),
  }) {
    if (checkingToken != null) {
      return checkingToken();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) {
    return checkingToken(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) {
    return checkingToken?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (checkingToken != null) {
      return checkingToken(this);
    }
    return orElse();
  }
}

abstract class AuthCheckingToken implements AuthState {
  const factory AuthCheckingToken() = _$AuthCheckingTokenImpl;
}

/// @nodoc
abstract class _$$AuthLoadingImplCopyWith<$Res> {
  factory _$$AuthLoadingImplCopyWith(
          _$AuthLoadingImpl value, $Res Function(_$AuthLoadingImpl) then) =
      __$$AuthLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AuthLoadingImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthLoadingImpl>
    implements _$$AuthLoadingImplCopyWith<$Res> {
  __$$AuthLoadingImplCopyWithImpl(
      _$AuthLoadingImpl _value, $Res Function(_$AuthLoadingImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AuthLoadingImpl implements AuthLoading {
  const _$AuthLoadingImpl();

  @override
  String toString() {
    return 'AuthState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AuthLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
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
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class AuthLoading implements AuthState {
  const factory AuthLoading() = _$AuthLoadingImpl;
}

/// @nodoc
abstract class _$$AuthOtpSentImplCopyWith<$Res> {
  factory _$$AuthOtpSentImplCopyWith(
          _$AuthOtpSentImpl value, $Res Function(_$AuthOtpSentImpl) then) =
      __$$AuthOtpSentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String phoneNumber, String? debugCode});
}

/// @nodoc
class __$$AuthOtpSentImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthOtpSentImpl>
    implements _$$AuthOtpSentImplCopyWith<$Res> {
  __$$AuthOtpSentImplCopyWithImpl(
      _$AuthOtpSentImpl _value, $Res Function(_$AuthOtpSentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumber = null,
    Object? debugCode = freezed,
  }) {
    return _then(_$AuthOtpSentImpl(
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      debugCode: freezed == debugCode
          ? _value.debugCode
          : debugCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AuthOtpSentImpl implements AuthOtpSent {
  const _$AuthOtpSentImpl({required this.phoneNumber, this.debugCode});

  @override
  final String phoneNumber;
  @override
  final String? debugCode;

  @override
  String toString() {
    return 'AuthState.otpSent(phoneNumber: $phoneNumber, debugCode: $debugCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthOtpSentImpl &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.debugCode, debugCode) ||
                other.debugCode == debugCode));
  }

  @override
  int get hashCode => Object.hash(runtimeType, phoneNumber, debugCode);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthOtpSentImplCopyWith<_$AuthOtpSentImpl> get copyWith =>
      __$$AuthOtpSentImplCopyWithImpl<_$AuthOtpSentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) {
    return otpSent(phoneNumber, debugCode);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) {
    return otpSent?.call(phoneNumber, debugCode);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
    required TResult orElse(),
  }) {
    if (otpSent != null) {
      return otpSent(phoneNumber, debugCode);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) {
    return otpSent(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) {
    return otpSent?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (otpSent != null) {
      return otpSent(this);
    }
    return orElse();
  }
}

abstract class AuthOtpSent implements AuthState {
  const factory AuthOtpSent(
      {required final String phoneNumber,
      final String? debugCode}) = _$AuthOtpSentImpl;

  String get phoneNumber;
  String? get debugCode;
  @JsonKey(ignore: true)
  _$$AuthOtpSentImplCopyWith<_$AuthOtpSentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthUnauthenticatedImplCopyWith<$Res> {
  factory _$$AuthUnauthenticatedImplCopyWith(_$AuthUnauthenticatedImpl value,
          $Res Function(_$AuthUnauthenticatedImpl) then) =
      __$$AuthUnauthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call({bool sessionExpired});
}

/// @nodoc
class __$$AuthUnauthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthUnauthenticatedImpl>
    implements _$$AuthUnauthenticatedImplCopyWith<$Res> {
  __$$AuthUnauthenticatedImplCopyWithImpl(_$AuthUnauthenticatedImpl _value,
      $Res Function(_$AuthUnauthenticatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionExpired = null,
  }) {
    return _then(_$AuthUnauthenticatedImpl(
      sessionExpired: null == sessionExpired
          ? _value.sessionExpired
          : sessionExpired // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AuthUnauthenticatedImpl implements AuthUnauthenticated {
  const _$AuthUnauthenticatedImpl({this.sessionExpired = false});

  @override
  @JsonKey()
  final bool sessionExpired;

  @override
  String toString() {
    return 'AuthState.unauthenticated(sessionExpired: $sessionExpired)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthUnauthenticatedImpl &&
            (identical(other.sessionExpired, sessionExpired) ||
                other.sessionExpired == sessionExpired));
  }

  @override
  int get hashCode => Object.hash(runtimeType, sessionExpired);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthUnauthenticatedImplCopyWith<_$AuthUnauthenticatedImpl> get copyWith =>
      __$$AuthUnauthenticatedImplCopyWithImpl<_$AuthUnauthenticatedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) {
    return unauthenticated(sessionExpired);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) {
    return unauthenticated?.call(sessionExpired);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(sessionExpired);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) {
    return unauthenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) {
    return unauthenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (unauthenticated != null) {
      return unauthenticated(this);
    }
    return orElse();
  }
}

abstract class AuthUnauthenticated implements AuthState {
  const factory AuthUnauthenticated({final bool sessionExpired}) =
      _$AuthUnauthenticatedImpl;

  bool get sessionExpired;
  @JsonKey(ignore: true)
  _$$AuthUnauthenticatedImplCopyWith<_$AuthUnauthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthErrorImplCopyWith<$Res> {
  factory _$$AuthErrorImplCopyWith(
          _$AuthErrorImpl value, $Res Function(_$AuthErrorImpl) then) =
      __$$AuthErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AuthErrorImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthErrorImpl>
    implements _$$AuthErrorImplCopyWith<$Res> {
  __$$AuthErrorImplCopyWithImpl(
      _$AuthErrorImpl _value, $Res Function(_$AuthErrorImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AuthErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$AuthErrorImpl implements AuthError {
  const _$AuthErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AuthState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthErrorImplCopyWith<_$AuthErrorImpl> get copyWith =>
      __$$AuthErrorImplCopyWithImpl<_$AuthErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
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
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class AuthError implements AuthState {
  const factory AuthError({required final String message}) = _$AuthErrorImpl;

  String get message;
  @JsonKey(ignore: true)
  _$$AuthErrorImplCopyWith<_$AuthErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthAuthenticatedImplCopyWith<$Res> {
  factory _$$AuthAuthenticatedImplCopyWith(_$AuthAuthenticatedImpl value,
          $Res Function(_$AuthAuthenticatedImpl) then) =
      __$$AuthAuthenticatedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {AuthToken token, List<UserRole> availableRoles, UserRole activeRole});

  $AuthTokenCopyWith<$Res> get token;
  $UserRoleCopyWith<$Res> get activeRole;
}

/// @nodoc
class __$$AuthAuthenticatedImplCopyWithImpl<$Res>
    extends _$AuthStateCopyWithImpl<$Res, _$AuthAuthenticatedImpl>
    implements _$$AuthAuthenticatedImplCopyWith<$Res> {
  __$$AuthAuthenticatedImplCopyWithImpl(_$AuthAuthenticatedImpl _value,
      $Res Function(_$AuthAuthenticatedImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? availableRoles = null,
    Object? activeRole = null,
  }) {
    return _then(_$AuthAuthenticatedImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as AuthToken,
      availableRoles: null == availableRoles
          ? _value._availableRoles
          : availableRoles // ignore: cast_nullable_to_non_nullable
              as List<UserRole>,
      activeRole: null == activeRole
          ? _value.activeRole
          : activeRole // ignore: cast_nullable_to_non_nullable
              as UserRole,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthTokenCopyWith<$Res> get token {
    return $AuthTokenCopyWith<$Res>(_value.token, (value) {
      return _then(_value.copyWith(token: value));
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $UserRoleCopyWith<$Res> get activeRole {
    return $UserRoleCopyWith<$Res>(_value.activeRole, (value) {
      return _then(_value.copyWith(activeRole: value));
    });
  }
}

/// @nodoc

class _$AuthAuthenticatedImpl implements AuthAuthenticated {
  const _$AuthAuthenticatedImpl(
      {required this.token,
      required final List<UserRole> availableRoles,
      required this.activeRole})
      : _availableRoles = availableRoles;

  @override
  final AuthToken token;
  final List<UserRole> _availableRoles;
  @override
  List<UserRole> get availableRoles {
    if (_availableRoles is EqualUnmodifiableListView) return _availableRoles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableRoles);
  }

  @override
  final UserRole activeRole;

  @override
  String toString() {
    return 'AuthState.authenticated(token: $token, availableRoles: $availableRoles, activeRole: $activeRole)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthAuthenticatedImpl &&
            (identical(other.token, token) || other.token == token) &&
            const DeepCollectionEquality()
                .equals(other._availableRoles, _availableRoles) &&
            (identical(other.activeRole, activeRole) ||
                other.activeRole == activeRole));
  }

  @override
  int get hashCode => Object.hash(runtimeType, token,
      const DeepCollectionEquality().hash(_availableRoles), activeRole);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthAuthenticatedImplCopyWith<_$AuthAuthenticatedImpl> get copyWith =>
      __$$AuthAuthenticatedImplCopyWithImpl<_$AuthAuthenticatedImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() checkingToken,
    required TResult Function() loading,
    required TResult Function(String phoneNumber, String? debugCode) otpSent,
    required TResult Function(bool sessionExpired) unauthenticated,
    required TResult Function(String message) error,
    required TResult Function(
            AuthToken token, List<UserRole> availableRoles, UserRole activeRole)
        authenticated,
  }) {
    return authenticated(token, availableRoles, activeRole);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? checkingToken,
    TResult? Function()? loading,
    TResult? Function(String phoneNumber, String? debugCode)? otpSent,
    TResult? Function(bool sessionExpired)? unauthenticated,
    TResult? Function(String message)? error,
    TResult? Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
  }) {
    return authenticated?.call(token, availableRoles, activeRole);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? checkingToken,
    TResult Function()? loading,
    TResult Function(String phoneNumber, String? debugCode)? otpSent,
    TResult Function(bool sessionExpired)? unauthenticated,
    TResult Function(String message)? error,
    TResult Function(AuthToken token, List<UserRole> availableRoles,
            UserRole activeRole)?
        authenticated,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(token, availableRoles, activeRole);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AuthInitial value) initial,
    required TResult Function(AuthCheckingToken value) checkingToken,
    required TResult Function(AuthLoading value) loading,
    required TResult Function(AuthOtpSent value) otpSent,
    required TResult Function(AuthUnauthenticated value) unauthenticated,
    required TResult Function(AuthError value) error,
    required TResult Function(AuthAuthenticated value) authenticated,
  }) {
    return authenticated(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(AuthInitial value)? initial,
    TResult? Function(AuthCheckingToken value)? checkingToken,
    TResult? Function(AuthLoading value)? loading,
    TResult? Function(AuthOtpSent value)? otpSent,
    TResult? Function(AuthUnauthenticated value)? unauthenticated,
    TResult? Function(AuthError value)? error,
    TResult? Function(AuthAuthenticated value)? authenticated,
  }) {
    return authenticated?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AuthInitial value)? initial,
    TResult Function(AuthCheckingToken value)? checkingToken,
    TResult Function(AuthLoading value)? loading,
    TResult Function(AuthOtpSent value)? otpSent,
    TResult Function(AuthUnauthenticated value)? unauthenticated,
    TResult Function(AuthError value)? error,
    TResult Function(AuthAuthenticated value)? authenticated,
    required TResult orElse(),
  }) {
    if (authenticated != null) {
      return authenticated(this);
    }
    return orElse();
  }
}

abstract class AuthAuthenticated implements AuthState {
  const factory AuthAuthenticated(
      {required final AuthToken token,
      required final List<UserRole> availableRoles,
      required final UserRole activeRole}) = _$AuthAuthenticatedImpl;

  AuthToken get token;
  List<UserRole> get availableRoles;
  UserRole get activeRole;
  @JsonKey(ignore: true)
  _$$AuthAuthenticatedImplCopyWith<_$AuthAuthenticatedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
