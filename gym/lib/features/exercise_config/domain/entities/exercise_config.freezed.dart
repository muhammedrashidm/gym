// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ExerciseConfig {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description =>
      throw _privateConstructorUsedError; // "DYNAMIC_REP" | "STATIC_HOLD" | "COMPOUND_MOVEMENT" | "CARDIO_MOVEMENT"
  String get analyzerType => throw _privateConstructorUsedError;
  Map<String, dynamic> get aiConfigJson => throw _privateConstructorUsedError;
  List<String> get keywords => throw _privateConstructorUsedError;
  String get mediaUrl => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExerciseConfigCopyWith<ExerciseConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseConfigCopyWith<$Res> {
  factory $ExerciseConfigCopyWith(
          ExerciseConfig value, $Res Function(ExerciseConfig) then) =
      _$ExerciseConfigCopyWithImpl<$Res, ExerciseConfig>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String analyzerType,
      Map<String, dynamic> aiConfigJson,
      List<String> keywords,
      String mediaUrl});
}

/// @nodoc
class _$ExerciseConfigCopyWithImpl<$Res, $Val extends ExerciseConfig>
    implements $ExerciseConfigCopyWith<$Res> {
  _$ExerciseConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? analyzerType = null,
    Object? aiConfigJson = null,
    Object? keywords = null,
    Object? mediaUrl = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      analyzerType: null == analyzerType
          ? _value.analyzerType
          : analyzerType // ignore: cast_nullable_to_non_nullable
              as String,
      aiConfigJson: null == aiConfigJson
          ? _value.aiConfigJson
          : aiConfigJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      keywords: null == keywords
          ? _value.keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExerciseConfigImplCopyWith<$Res>
    implements $ExerciseConfigCopyWith<$Res> {
  factory _$$ExerciseConfigImplCopyWith(_$ExerciseConfigImpl value,
          $Res Function(_$ExerciseConfigImpl) then) =
      __$$ExerciseConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String analyzerType,
      Map<String, dynamic> aiConfigJson,
      List<String> keywords,
      String mediaUrl});
}

/// @nodoc
class __$$ExerciseConfigImplCopyWithImpl<$Res>
    extends _$ExerciseConfigCopyWithImpl<$Res, _$ExerciseConfigImpl>
    implements _$$ExerciseConfigImplCopyWith<$Res> {
  __$$ExerciseConfigImplCopyWithImpl(
      _$ExerciseConfigImpl _value, $Res Function(_$ExerciseConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? analyzerType = null,
    Object? aiConfigJson = null,
    Object? keywords = null,
    Object? mediaUrl = null,
  }) {
    return _then(_$ExerciseConfigImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      analyzerType: null == analyzerType
          ? _value.analyzerType
          : analyzerType // ignore: cast_nullable_to_non_nullable
              as String,
      aiConfigJson: null == aiConfigJson
          ? _value._aiConfigJson
          : aiConfigJson // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      keywords: null == keywords
          ? _value._keywords
          : keywords // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mediaUrl: null == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ExerciseConfigImpl implements _ExerciseConfig {
  const _$ExerciseConfigImpl(
      {required this.id,
      required this.name,
      this.description,
      required this.analyzerType,
      required final Map<String, dynamic> aiConfigJson,
      final List<String> keywords = const <String>[],
      required this.mediaUrl})
      : _aiConfigJson = aiConfigJson,
        _keywords = keywords;

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
// "DYNAMIC_REP" | "STATIC_HOLD" | "COMPOUND_MOVEMENT" | "CARDIO_MOVEMENT"
  @override
  final String analyzerType;
  final Map<String, dynamic> _aiConfigJson;
  @override
  Map<String, dynamic> get aiConfigJson {
    if (_aiConfigJson is EqualUnmodifiableMapView) return _aiConfigJson;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_aiConfigJson);
  }

  final List<String> _keywords;
  @override
  @JsonKey()
  List<String> get keywords {
    if (_keywords is EqualUnmodifiableListView) return _keywords;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_keywords);
  }

  @override
  final String mediaUrl;

  @override
  String toString() {
    return 'ExerciseConfig(id: $id, name: $name, description: $description, analyzerType: $analyzerType, aiConfigJson: $aiConfigJson, keywords: $keywords, mediaUrl: $mediaUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseConfigImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.analyzerType, analyzerType) ||
                other.analyzerType == analyzerType) &&
            const DeepCollectionEquality()
                .equals(other._aiConfigJson, _aiConfigJson) &&
            const DeepCollectionEquality().equals(other._keywords, _keywords) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      analyzerType,
      const DeepCollectionEquality().hash(_aiConfigJson),
      const DeepCollectionEquality().hash(_keywords),
      mediaUrl);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseConfigImplCopyWith<_$ExerciseConfigImpl> get copyWith =>
      __$$ExerciseConfigImplCopyWithImpl<_$ExerciseConfigImpl>(
          this, _$identity);
}

abstract class _ExerciseConfig implements ExerciseConfig {
  const factory _ExerciseConfig(
      {required final String id,
      required final String name,
      final String? description,
      required final String analyzerType,
      required final Map<String, dynamic> aiConfigJson,
      final List<String> keywords,
      required final String mediaUrl}) = _$ExerciseConfigImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override // "DYNAMIC_REP" | "STATIC_HOLD" | "COMPOUND_MOVEMENT" | "CARDIO_MOVEMENT"
  String get analyzerType;
  @override
  Map<String, dynamic> get aiConfigJson;
  @override
  List<String> get keywords;
  @override
  String get mediaUrl;
  @override
  @JsonKey(ignore: true)
  _$$ExerciseConfigImplCopyWith<_$ExerciseConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
