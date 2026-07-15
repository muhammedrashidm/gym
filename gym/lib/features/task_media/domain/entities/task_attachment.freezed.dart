// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_attachment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TaskAttachment {
  String get id => throw _privateConstructorUsedError;
  String get taskId => throw _privateConstructorUsedError;
  String get taskMediaId => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  int get sequenceIndex => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  TaskMedia get taskMedia => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskAttachmentCopyWith<TaskAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskAttachmentCopyWith<$Res> {
  factory $TaskAttachmentCopyWith(
          TaskAttachment value, $Res Function(TaskAttachment) then) =
      _$TaskAttachmentCopyWithImpl<$Res, TaskAttachment>;
  @useResult
  $Res call(
      {String id,
      String taskId,
      String taskMediaId,
      String? caption,
      int sequenceIndex,
      DateTime createdAt,
      TaskMedia taskMedia});

  $TaskMediaCopyWith<$Res> get taskMedia;
}

/// @nodoc
class _$TaskAttachmentCopyWithImpl<$Res, $Val extends TaskAttachment>
    implements $TaskAttachmentCopyWith<$Res> {
  _$TaskAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? taskMediaId = null,
    Object? caption = freezed,
    Object? sequenceIndex = null,
    Object? createdAt = null,
    Object? taskMedia = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      taskMediaId: null == taskMediaId
          ? _value.taskMediaId
          : taskMediaId // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      sequenceIndex: null == sequenceIndex
          ? _value.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      taskMedia: null == taskMedia
          ? _value.taskMedia
          : taskMedia // ignore: cast_nullable_to_non_nullable
              as TaskMedia,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TaskMediaCopyWith<$Res> get taskMedia {
    return $TaskMediaCopyWith<$Res>(_value.taskMedia, (value) {
      return _then(_value.copyWith(taskMedia: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TaskAttachmentImplCopyWith<$Res>
    implements $TaskAttachmentCopyWith<$Res> {
  factory _$$TaskAttachmentImplCopyWith(_$TaskAttachmentImpl value,
          $Res Function(_$TaskAttachmentImpl) then) =
      __$$TaskAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String taskId,
      String taskMediaId,
      String? caption,
      int sequenceIndex,
      DateTime createdAt,
      TaskMedia taskMedia});

  @override
  $TaskMediaCopyWith<$Res> get taskMedia;
}

/// @nodoc
class __$$TaskAttachmentImplCopyWithImpl<$Res>
    extends _$TaskAttachmentCopyWithImpl<$Res, _$TaskAttachmentImpl>
    implements _$$TaskAttachmentImplCopyWith<$Res> {
  __$$TaskAttachmentImplCopyWithImpl(
      _$TaskAttachmentImpl _value, $Res Function(_$TaskAttachmentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? taskId = null,
    Object? taskMediaId = null,
    Object? caption = freezed,
    Object? sequenceIndex = null,
    Object? createdAt = null,
    Object? taskMedia = null,
  }) {
    return _then(_$TaskAttachmentImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      taskId: null == taskId
          ? _value.taskId
          : taskId // ignore: cast_nullable_to_non_nullable
              as String,
      taskMediaId: null == taskMediaId
          ? _value.taskMediaId
          : taskMediaId // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      sequenceIndex: null == sequenceIndex
          ? _value.sequenceIndex
          : sequenceIndex // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      taskMedia: null == taskMedia
          ? _value.taskMedia
          : taskMedia // ignore: cast_nullable_to_non_nullable
              as TaskMedia,
    ));
  }
}

/// @nodoc

class _$TaskAttachmentImpl implements _TaskAttachment {
  const _$TaskAttachmentImpl(
      {required this.id,
      required this.taskId,
      required this.taskMediaId,
      this.caption,
      required this.sequenceIndex,
      required this.createdAt,
      required this.taskMedia});

  @override
  final String id;
  @override
  final String taskId;
  @override
  final String taskMediaId;
  @override
  final String? caption;
  @override
  final int sequenceIndex;
  @override
  final DateTime createdAt;
  @override
  final TaskMedia taskMedia;

  @override
  String toString() {
    return 'TaskAttachment(id: $id, taskId: $taskId, taskMediaId: $taskMediaId, caption: $caption, sequenceIndex: $sequenceIndex, createdAt: $createdAt, taskMedia: $taskMedia)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskAttachmentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.taskId, taskId) || other.taskId == taskId) &&
            (identical(other.taskMediaId, taskMediaId) ||
                other.taskMediaId == taskMediaId) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.sequenceIndex, sequenceIndex) ||
                other.sequenceIndex == sequenceIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.taskMedia, taskMedia) ||
                other.taskMedia == taskMedia));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, taskId, taskMediaId, caption,
      sequenceIndex, createdAt, taskMedia);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskAttachmentImplCopyWith<_$TaskAttachmentImpl> get copyWith =>
      __$$TaskAttachmentImplCopyWithImpl<_$TaskAttachmentImpl>(
          this, _$identity);
}

abstract class _TaskAttachment implements TaskAttachment {
  const factory _TaskAttachment(
      {required final String id,
      required final String taskId,
      required final String taskMediaId,
      final String? caption,
      required final int sequenceIndex,
      required final DateTime createdAt,
      required final TaskMedia taskMedia}) = _$TaskAttachmentImpl;

  @override
  String get id;
  @override
  String get taskId;
  @override
  String get taskMediaId;
  @override
  String? get caption;
  @override
  int get sequenceIndex;
  @override
  DateTime get createdAt;
  @override
  TaskMedia get taskMedia;
  @override
  @JsonKey(ignore: true)
  _$$TaskAttachmentImplCopyWith<_$TaskAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
