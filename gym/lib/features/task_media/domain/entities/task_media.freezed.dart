// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_media.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TaskMedia {
  String get id =>
      throw _privateConstructorUsedError; // "IMAGE" | "GIF" | "VIDEO"
  String get type => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;
  String get createdById => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskMediaCopyWith<TaskMedia> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskMediaCopyWith<$Res> {
  factory $TaskMediaCopyWith(TaskMedia value, $Res Function(TaskMedia) then) =
      _$TaskMediaCopyWithImpl<$Res, TaskMedia>;
  @useResult
  $Res call(
      {String id,
      String type,
      String name,
      String? description,
      List<String> keywords,
      bool isPrivate,
      String createdById,
      String url,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$TaskMediaCopyWithImpl<$Res, $Val extends TaskMedia>
    implements $TaskMediaCopyWith<$Res> {
  _$TaskMediaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = null,
    Object? description = freezed,
    Object? keywords = null,
    Object? isPrivate = null,
    Object? createdById = null,
    Object? url = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskMediaImplCopyWith<$Res>
    implements $TaskMediaCopyWith<$Res> {
  factory _$$TaskMediaImplCopyWith(
          _$TaskMediaImpl value, $Res Function(_$TaskMediaImpl) then) =
      __$$TaskMediaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      String name,
      String? description,
      List<String> keywords,
      bool isPrivate,
      String createdById,
      String url,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$TaskMediaImplCopyWithImpl<$Res>
    extends _$TaskMediaCopyWithImpl<$Res, _$TaskMediaImpl>
    implements _$$TaskMediaImplCopyWith<$Res> {
  __$$TaskMediaImplCopyWithImpl(
      _$TaskMediaImpl _value, $Res Function(_$TaskMediaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? name = null,
    Object? description = freezed,
    Object? keywords = null,
    Object? isPrivate = null,
    Object? createdById = null,
    Object? url = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$TaskMediaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$TaskMediaImpl implements _TaskMedia {
  const _$TaskMediaImpl(
      {required this.id,
      required this.type,
      required this.name,
      this.description,
      final List<String> keywords = const <String>[],
      this.isPrivate = false,
      required this.createdById,
      required this.url,
      required this.createdAt,
      required this.updatedAt})
      : _keywords = keywords;

  @override
  final String id;
// "IMAGE" | "GIF" | "VIDEO"
  @override
  final String type;
  @override
  final String name;
  @override
  final String? description;
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
  final String createdById;
  @override
  final String url;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'TaskMedia(id: $id, type: $type, name: $name, description: $description, keywords: $keywords, isPrivate: $isPrivate, createdById: $createdById, url: $url, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskMediaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(other.createdById, createdById) ||
                other.createdById == createdById) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      type,
      name,
      description,
      const DeepCollectionEquality().hash(_keywords),
      isPrivate,
      createdById,
      url,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskMediaImplCopyWith<_$TaskMediaImpl> get copyWith =>
      __$$TaskMediaImplCopyWithImpl<_$TaskMediaImpl>(this, _$identity);
}

abstract class _TaskMedia implements TaskMedia {
  const factory _TaskMedia(
      {required final String id,
      required final String type,
      required final String name,
      final String? description,
      final List<String> keywords,
      final bool isPrivate,
      required final String createdById,
      required final String url,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$TaskMediaImpl;

  @override
  String get id;
  @override // "IMAGE" | "GIF" | "VIDEO"
  String get type;
  @override
  String get name;
  @override
  String? get description;
  @override
  List<String> get keywords;
  @override
  bool get isPrivate;
  @override
  String get createdById;
  @override
  String get url;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$TaskMediaImplCopyWith<_$TaskMediaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
