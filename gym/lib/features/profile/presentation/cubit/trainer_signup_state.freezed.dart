// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_signup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TrainerSignupState {
  List<PlatformFile> get certificates => throw _privateConstructorUsedError;
  List<String> get selectedSpecializations =>
      throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  AuthToken? get token => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<PlatformFile> certificates,
            List<String> selectedSpecializations,
            bool isSubmitting,
            bool isSuccess,
            String? errorMessage,
            AuthToken? token)
        initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            List<PlatformFile> certificates,
            List<String> selectedSpecializations,
            bool isSubmitting,
            bool isSuccess,
            String? errorMessage,
            AuthToken? token)?
        initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            List<PlatformFile> certificates,
            List<String> selectedSpecializations,
            bool isSubmitting,
            bool isSuccess,
            String? errorMessage,
            AuthToken? token)?
        initial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TrainerSignupState value) initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TrainerSignupState value)? initial,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TrainerSignupState value)? initial,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TrainerSignupStateCopyWith<TrainerSignupState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerSignupStateCopyWith<$Res> {
  factory $TrainerSignupStateCopyWith(
          TrainerSignupState value, $Res Function(TrainerSignupState) then) =
      _$TrainerSignupStateCopyWithImpl<$Res, TrainerSignupState>;
  @useResult
  $Res call(
      {List<PlatformFile> certificates,
      List<String> selectedSpecializations,
      bool isSubmitting,
      bool isSuccess,
      String? errorMessage,
      AuthToken? token});

  $AuthTokenCopyWith<$Res>? get token;
}

/// @nodoc
class _$TrainerSignupStateCopyWithImpl<$Res, $Val extends TrainerSignupState>
    implements $TrainerSignupStateCopyWith<$Res> {
  _$TrainerSignupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certificates = null,
    Object? selectedSpecializations = null,
    Object? isSubmitting = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
    Object? token = freezed,
  }) {
    return _then(_value.copyWith(
      certificates: null == certificates
          ? _value.certificates
          : certificates // ignore: cast_nullable_to_non_nullable
              as List<PlatformFile>,
      selectedSpecializations: null == selectedSpecializations
          ? _value.selectedSpecializations
          : selectedSpecializations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as AuthToken?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthTokenCopyWith<$Res>? get token {
    if (_value.token == null) {
      return null;
    }

    return $AuthTokenCopyWith<$Res>(_value.token!, (value) {
      return _then(_value.copyWith(token: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TrainerSignupStateImplCopyWith<$Res>
    implements $TrainerSignupStateCopyWith<$Res> {
  factory _$$TrainerSignupStateImplCopyWith(_$TrainerSignupStateImpl value,
          $Res Function(_$TrainerSignupStateImpl) then) =
      __$$TrainerSignupStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PlatformFile> certificates,
      List<String> selectedSpecializations,
      bool isSubmitting,
      bool isSuccess,
      String? errorMessage,
      AuthToken? token});

  @override
  $AuthTokenCopyWith<$Res>? get token;
}

/// @nodoc
class __$$TrainerSignupStateImplCopyWithImpl<$Res>
    extends _$TrainerSignupStateCopyWithImpl<$Res, _$TrainerSignupStateImpl>
    implements _$$TrainerSignupStateImplCopyWith<$Res> {
  __$$TrainerSignupStateImplCopyWithImpl(_$TrainerSignupStateImpl _value,
      $Res Function(_$TrainerSignupStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certificates = null,
    Object? selectedSpecializations = null,
    Object? isSubmitting = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
    Object? token = freezed,
  }) {
    return _then(_$TrainerSignupStateImpl(
      certificates: null == certificates
          ? _value._certificates
          : certificates // ignore: cast_nullable_to_non_nullable
              as List<PlatformFile>,
      selectedSpecializations: null == selectedSpecializations
          ? _value._selectedSpecializations
          : selectedSpecializations // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      token: freezed == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as AuthToken?,
    ));
  }
}

/// @nodoc

class _$TrainerSignupStateImpl implements _TrainerSignupState {
  const _$TrainerSignupStateImpl(
      {final List<PlatformFile> certificates = const [],
      final List<String> selectedSpecializations = const [],
      this.isSubmitting = false,
      this.isSuccess = false,
      this.errorMessage,
      this.token})
      : _certificates = certificates,
        _selectedSpecializations = selectedSpecializations;

  final List<PlatformFile> _certificates;
  @override
  @JsonKey()
  List<PlatformFile> get certificates {
    if (_certificates is EqualUnmodifiableListView) return _certificates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_certificates);
  }

  final List<String> _selectedSpecializations;
  @override
  @JsonKey()
  List<String> get selectedSpecializations {
    if (_selectedSpecializations is EqualUnmodifiableListView)
      return _selectedSpecializations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedSpecializations);
  }

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final String? errorMessage;
  @override
  final AuthToken? token;

  @override
  String toString() {
    return 'TrainerSignupState.initial(certificates: $certificates, selectedSpecializations: $selectedSpecializations, isSubmitting: $isSubmitting, isSuccess: $isSuccess, errorMessage: $errorMessage, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerSignupStateImpl &&
            const DeepCollectionEquality()
                .equals(other._certificates, _certificates) &&
            const DeepCollectionEquality().equals(
                other._selectedSpecializations, _selectedSpecializations) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.token, token) || other.token == token));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_certificates),
      const DeepCollectionEquality().hash(_selectedSpecializations),
      isSubmitting,
      isSuccess,
      errorMessage,
      token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerSignupStateImplCopyWith<_$TrainerSignupStateImpl> get copyWith =>
      __$$TrainerSignupStateImplCopyWithImpl<_$TrainerSignupStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            List<PlatformFile> certificates,
            List<String> selectedSpecializations,
            bool isSubmitting,
            bool isSuccess,
            String? errorMessage,
            AuthToken? token)
        initial,
  }) {
    return initial(certificates, selectedSpecializations, isSubmitting,
        isSuccess, errorMessage, token);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(
            List<PlatformFile> certificates,
            List<String> selectedSpecializations,
            bool isSubmitting,
            bool isSuccess,
            String? errorMessage,
            AuthToken? token)?
        initial,
  }) {
    return initial?.call(certificates, selectedSpecializations, isSubmitting,
        isSuccess, errorMessage, token);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            List<PlatformFile> certificates,
            List<String> selectedSpecializations,
            bool isSubmitting,
            bool isSuccess,
            String? errorMessage,
            AuthToken? token)?
        initial,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(certificates, selectedSpecializations, isSubmitting,
          isSuccess, errorMessage, token);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_TrainerSignupState value) initial,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_TrainerSignupState value)? initial,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_TrainerSignupState value)? initial,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _TrainerSignupState implements TrainerSignupState {
  const factory _TrainerSignupState(
      {final List<PlatformFile> certificates,
      final List<String> selectedSpecializations,
      final bool isSubmitting,
      final bool isSuccess,
      final String? errorMessage,
      final AuthToken? token}) = _$TrainerSignupStateImpl;

  @override
  List<PlatformFile> get certificates;
  @override
  List<String> get selectedSpecializations;
  @override
  bool get isSubmitting;
  @override
  bool get isSuccess;
  @override
  String? get errorMessage;
  @override
  AuthToken? get token;
  @override
  @JsonKey(ignore: true)
  _$$TrainerSignupStateImplCopyWith<_$TrainerSignupStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
