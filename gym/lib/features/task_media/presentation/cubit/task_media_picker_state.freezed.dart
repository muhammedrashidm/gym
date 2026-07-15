// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_media_picker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TaskMediaPickerState {
  String get query => throw _privateConstructorUsedError;
  bool get mineOnly => throw _privateConstructorUsedError;
  List<TaskMedia> get items =>
      throw _privateConstructorUsedError; // All currently-selected media, keyed by id — persists across searches,
// pagination, and filter toggles so the final ATTACH list is complete.
  Map<String, TaskMedia> get selected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TaskMediaPickerStateCopyWith<TaskMediaPickerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TaskMediaPickerStateCopyWith<$Res> {
  factory $TaskMediaPickerStateCopyWith(TaskMediaPickerState value,
          $Res Function(TaskMediaPickerState) then) =
      _$TaskMediaPickerStateCopyWithImpl<$Res, TaskMediaPickerState>;
  @useResult
  $Res call(
      {String query,
      bool mineOnly,
      List<TaskMedia> items,
      Map<String, TaskMedia> selected,
      bool isLoading,
      bool isLoadingMore,
      String? error,
      int page,
      int total});
}

/// @nodoc
class _$TaskMediaPickerStateCopyWithImpl<$Res,
        $Val extends TaskMediaPickerState>
    implements $TaskMediaPickerStateCopyWith<$Res> {
  _$TaskMediaPickerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? mineOnly = null,
    Object? items = null,
    Object? selected = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? error = freezed,
    Object? page = null,
    Object? total = null,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      mineOnly: null == mineOnly
          ? _value.mineOnly
          : mineOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TaskMedia>,
      selected: null == selected
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as Map<String, TaskMedia>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TaskMediaPickerStateImplCopyWith<$Res>
    implements $TaskMediaPickerStateCopyWith<$Res> {
  factory _$$TaskMediaPickerStateImplCopyWith(_$TaskMediaPickerStateImpl value,
          $Res Function(_$TaskMediaPickerStateImpl) then) =
      __$$TaskMediaPickerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      bool mineOnly,
      List<TaskMedia> items,
      Map<String, TaskMedia> selected,
      bool isLoading,
      bool isLoadingMore,
      String? error,
      int page,
      int total});
}

/// @nodoc
class __$$TaskMediaPickerStateImplCopyWithImpl<$Res>
    extends _$TaskMediaPickerStateCopyWithImpl<$Res, _$TaskMediaPickerStateImpl>
    implements _$$TaskMediaPickerStateImplCopyWith<$Res> {
  __$$TaskMediaPickerStateImplCopyWithImpl(_$TaskMediaPickerStateImpl _value,
      $Res Function(_$TaskMediaPickerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? mineOnly = null,
    Object? items = null,
    Object? selected = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? error = freezed,
    Object? page = null,
    Object? total = null,
  }) {
    return _then(_$TaskMediaPickerStateImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      mineOnly: null == mineOnly
          ? _value.mineOnly
          : mineOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<TaskMedia>,
      selected: null == selected
          ? _value._selected
          : selected // ignore: cast_nullable_to_non_nullable
              as Map<String, TaskMedia>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$TaskMediaPickerStateImpl extends _TaskMediaPickerState {
  const _$TaskMediaPickerStateImpl(
      {this.query = '',
      this.mineOnly = false,
      final List<TaskMedia> items = const <TaskMedia>[],
      final Map<String, TaskMedia> selected = const <String, TaskMedia>{},
      this.isLoading = false,
      this.isLoadingMore = false,
      this.error,
      this.page = 1,
      this.total = 0})
      : _items = items,
        _selected = selected,
        super._();

  @override
  @JsonKey()
  final String query;
  @override
  @JsonKey()
  final bool mineOnly;
  final List<TaskMedia> _items;
  @override
  @JsonKey()
  List<TaskMedia> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

// All currently-selected media, keyed by id — persists across searches,
// pagination, and filter toggles so the final ATTACH list is complete.
  final Map<String, TaskMedia> _selected;
// All currently-selected media, keyed by id — persists across searches,
// pagination, and filter toggles so the final ATTACH list is complete.
  @override
  @JsonKey()
  Map<String, TaskMedia> get selected {
    if (_selected is EqualUnmodifiableMapView) return _selected;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_selected);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  final String? error;
  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int total;

  @override
  String toString() {
    return 'TaskMediaPickerState(query: $query, mineOnly: $mineOnly, items: $items, selected: $selected, isLoading: $isLoading, isLoadingMore: $isLoadingMore, error: $error, page: $page, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TaskMediaPickerStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.mineOnly, mineOnly) ||
                other.mineOnly == mineOnly) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            const DeepCollectionEquality().equals(other._selected, _selected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      mineOnly,
      const DeepCollectionEquality().hash(_items),
      const DeepCollectionEquality().hash(_selected),
      isLoading,
      isLoadingMore,
      error,
      page,
      total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TaskMediaPickerStateImplCopyWith<_$TaskMediaPickerStateImpl>
      get copyWith =>
          __$$TaskMediaPickerStateImplCopyWithImpl<_$TaskMediaPickerStateImpl>(
              this, _$identity);
}

abstract class _TaskMediaPickerState extends TaskMediaPickerState {
  const factory _TaskMediaPickerState(
      {final String query,
      final bool mineOnly,
      final List<TaskMedia> items,
      final Map<String, TaskMedia> selected,
      final bool isLoading,
      final bool isLoadingMore,
      final String? error,
      final int page,
      final int total}) = _$TaskMediaPickerStateImpl;
  const _TaskMediaPickerState._() : super._();

  @override
  String get query;
  @override
  bool get mineOnly;
  @override
  List<TaskMedia> get items;
  @override // All currently-selected media, keyed by id — persists across searches,
// pagination, and filter toggles so the final ATTACH list is complete.
  Map<String, TaskMedia> get selected;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  String? get error;
  @override
  int get page;
  @override
  int get total;
  @override
  @JsonKey(ignore: true)
  _$$TaskMediaPickerStateImplCopyWith<_$TaskMediaPickerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
