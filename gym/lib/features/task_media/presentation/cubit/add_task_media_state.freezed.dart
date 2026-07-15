// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_task_media_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AddTaskMediaState {
  PlatformFile? get file => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  String? get error =>
      throw _privateConstructorUsedError; // Non-null once the upload succeeds — the page listens and pops with it.
  TaskMedia? get created => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AddTaskMediaStateCopyWith<AddTaskMediaState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddTaskMediaStateCopyWith<$Res> {
  factory $AddTaskMediaStateCopyWith(
          AddTaskMediaState value, $Res Function(AddTaskMediaState) then) =
      _$AddTaskMediaStateCopyWithImpl<$Res, AddTaskMediaState>;
  @useResult
  $Res call(
      {PlatformFile? file,
      String name,
      String description,
      List<String> keywords,
      bool isPrivate,
      bool isSubmitting,
      String? error,
      TaskMedia? created});

  $TaskMediaCopyWith<$Res>? get created;
}

/// @nodoc
class _$AddTaskMediaStateCopyWithImpl<$Res, $Val extends AddTaskMediaState>
    implements $AddTaskMediaStateCopyWith<$Res> {
  _$AddTaskMediaStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? file = freezed,
    Object? name = null,
    Object? description = null,
    Object? keywords = null,
    Object? isPrivate = null,
    Object? isSubmitting = null,
    Object? error = freezed,
    Object? created = freezed,
  }) {
    return _then(_value.copyWith(
      file: freezed == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as PlatformFile?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      created: freezed == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as TaskMedia?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TaskMediaCopyWith<$Res>? get created {
    if (_value.created == null) {
      return null;
    }

    return $TaskMediaCopyWith<$Res>(_value.created!, (value) {
      return _then(_value.copyWith(created: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AddTaskMediaStateImplCopyWith<$Res>
    implements $AddTaskMediaStateCopyWith<$Res> {
  factory _$$AddTaskMediaStateImplCopyWith(_$AddTaskMediaStateImpl value,
          $Res Function(_$AddTaskMediaStateImpl) then) =
      __$$AddTaskMediaStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {PlatformFile? file,
      String name,
      String description,
      List<String> keywords,
      bool isPrivate,
      bool isSubmitting,
      String? error,
      TaskMedia? created});

  @override
  $TaskMediaCopyWith<$Res>? get created;
}

/// @nodoc
class __$$AddTaskMediaStateImplCopyWithImpl<$Res>
    extends _$AddTaskMediaStateCopyWithImpl<$Res, _$AddTaskMediaStateImpl>
    implements _$$AddTaskMediaStateImplCopyWith<$Res> {
  __$$AddTaskMediaStateImplCopyWithImpl(_$AddTaskMediaStateImpl _value,
      $Res Function(_$AddTaskMediaStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? file = freezed,
    Object? name = null,
    Object? description = null,
    Object? keywords = null,
    Object? isPrivate = null,
    Object? isSubmitting = null,
    Object? error = freezed,
    Object? created = freezed,
  }) {
    return _then(_$AddTaskMediaStateImpl(
      file: freezed == file
          ? _value.file
          : file // ignore: cast_nullable_to_non_nullable
              as PlatformFile?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      created: freezed == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as TaskMedia?,
    ));
  }
}

/// @nodoc

class _$AddTaskMediaStateImpl extends _AddTaskMediaState {
  const _$AddTaskMediaStateImpl(
      {this.file,
      this.name = '',
      this.description = '',
      final List<String> keywords = const <String>[],
      this.isPrivate = false,
      this.isSubmitting = false,
      this.error,
      this.created})
      : _keywords = keywords,
        super._();

  @override
  final PlatformFile? file;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
  final List<String> _keywords;
  @override
  @JsonKey()
  List<String> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  final String? error;
// Non-null once the upload succeeds — the page listens and pops with it.
  @override
  final TaskMedia? created;

  @override
  String toString() {
    return 'AddTaskMediaState(file: $file, name: $name, description: $description, keywords: $keywords, isPrivate: $isPrivate, isSubmitting: $isSubmitting, error: $error, created: $created)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddTaskMediaStateImpl &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.created, created) || other.created == created));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      file,
      name,
      description,
      const DeepCollectionEquality().hash(_keywords),
      isPrivate,
      isSubmitting,
      error,
      created);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddTaskMediaStateImplCopyWith<_$AddTaskMediaStateImpl> get copyWith =>
      __$$AddTaskMediaStateImplCopyWithImpl<_$AddTaskMediaStateImpl>(
          this, _$identity);
}

abstract class _AddTaskMediaState extends AddTaskMediaState {
  const factory _AddTaskMediaState(
      {final PlatformFile? file,
      final String name,
      final String description,
      final List<String> keywords,
      final bool isPrivate,
      final bool isSubmitting,
      final String? error,
      final TaskMedia? created}) = _$AddTaskMediaStateImpl;
  const _AddTaskMediaState._() : super._();

  @override
  PlatformFile? get file;
  @override
  String get name;
  @override
  String get description;
  @override
  List<String> get keywords;
  @override
  bool get isPrivate;
  @override
  bool get isSubmitting;
  @override
  String? get error;
  @override // Non-null once the upload succeeds — the page listens and pops with it.
  TaskMedia? get created;
  @override
  @JsonKey(ignore: true)
  _$$AddTaskMediaStateImplCopyWith<_$AddTaskMediaStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
