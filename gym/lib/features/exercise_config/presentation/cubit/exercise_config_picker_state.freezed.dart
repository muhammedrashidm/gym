// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_config_picker_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ExerciseConfigPickerState {
  String get query => throw _privateConstructorUsedError;
  List<ExerciseConfig> get items =>
      throw _privateConstructorUsedError; // The single currently-selected config — persists across searches and
// pagination, and is null when the user has explicitly cleared it.
  ExerciseConfig? get selected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExerciseConfigPickerStateCopyWith<ExerciseConfigPickerState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseConfigPickerStateCopyWith<$Res> {
  factory $ExerciseConfigPickerStateCopyWith(ExerciseConfigPickerState value,
          $Res Function(ExerciseConfigPickerState) then) =
      _$ExerciseConfigPickerStateCopyWithImpl<$Res, ExerciseConfigPickerState>;
  @useResult
  $Res call(
      {String query,
      List<ExerciseConfig> items,
      ExerciseConfig? selected,
      bool isLoading,
      bool isLoadingMore,
      String? error,
      int page,
      int total});

  $ExerciseConfigCopyWith<$Res>? get selected;
}

/// @nodoc
class _$ExerciseConfigPickerStateCopyWithImpl<$Res,
        $Val extends ExerciseConfigPickerState>
    implements $ExerciseConfigPickerStateCopyWith<$Res> {
  _$ExerciseConfigPickerStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? items = null,
    Object? selected = freezed,
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
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ExerciseConfig>,
      selected: freezed == selected
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as ExerciseConfig?,
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

  @override
  @pragma('vm:prefer-inline')
  $ExerciseConfigCopyWith<$Res>? get selected {
    if (_value.selected == null) {
      return null;
    }

    return $ExerciseConfigCopyWith<$Res>(_value.selected!, (value) {
      return _then(_value.copyWith(selected: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ExerciseConfigPickerStateImplCopyWith<$Res>
    implements $ExerciseConfigPickerStateCopyWith<$Res> {
  factory _$$ExerciseConfigPickerStateImplCopyWith(
          _$ExerciseConfigPickerStateImpl value,
          $Res Function(_$ExerciseConfigPickerStateImpl) then) =
      __$$ExerciseConfigPickerStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      List<ExerciseConfig> items,
      ExerciseConfig? selected,
      bool isLoading,
      bool isLoadingMore,
      String? error,
      int page,
      int total});

  @override
  $ExerciseConfigCopyWith<$Res>? get selected;
}

/// @nodoc
class __$$ExerciseConfigPickerStateImplCopyWithImpl<$Res>
    extends _$ExerciseConfigPickerStateCopyWithImpl<$Res,
        _$ExerciseConfigPickerStateImpl>
    implements _$$ExerciseConfigPickerStateImplCopyWith<$Res> {
  __$$ExerciseConfigPickerStateImplCopyWithImpl(
      _$ExerciseConfigPickerStateImpl _value,
      $Res Function(_$ExerciseConfigPickerStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? items = null,
    Object? selected = freezed,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? error = freezed,
    Object? page = null,
    Object? total = null,
  }) {
    return _then(_$ExerciseConfigPickerStateImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ExerciseConfig>,
      selected: freezed == selected
          ? _value.selected
          : selected // ignore: cast_nullable_to_non_nullable
              as ExerciseConfig?,
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

class _$ExerciseConfigPickerStateImpl extends _ExerciseConfigPickerState {
  const _$ExerciseConfigPickerStateImpl(
      {this.query = '',
      final List<ExerciseConfig> items = const <ExerciseConfig>[],
      this.selected,
      this.isLoading = false,
      this.isLoadingMore = false,
      this.error,
      this.page = 1,
      this.total = 0})
      : _items = items,
        super._();

  @override
  @JsonKey()
  final String query;
  final List<ExerciseConfig> _items;
  @override
  @JsonKey()
  List<ExerciseConfig> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

// The single currently-selected config — persists across searches and
// pagination, and is null when the user has explicitly cleared it.
  @override
  final ExerciseConfig? selected;
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
    return 'ExerciseConfigPickerState(query: $query, items: $items, selected: $selected, isLoading: $isLoading, isLoadingMore: $isLoadingMore, error: $error, page: $page, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseConfigPickerStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.selected, selected) ||
                other.selected == selected) &&
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
      const DeepCollectionEquality().hash(_items),
      selected,
      isLoading,
      isLoadingMore,
      error,
      page,
      total);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseConfigPickerStateImplCopyWith<_$ExerciseConfigPickerStateImpl>
      get copyWith => __$$ExerciseConfigPickerStateImplCopyWithImpl<
          _$ExerciseConfigPickerStateImpl>(this, _$identity);
}

abstract class _ExerciseConfigPickerState extends ExerciseConfigPickerState {
  const factory _ExerciseConfigPickerState(
      {final String query,
      final List<ExerciseConfig> items,
      final ExerciseConfig? selected,
      final bool isLoading,
      final bool isLoadingMore,
      final String? error,
      final int page,
      final int total}) = _$ExerciseConfigPickerStateImpl;
  const _ExerciseConfigPickerState._() : super._();

  @override
  String get query;
  @override
  List<ExerciseConfig> get items;
  @override // The single currently-selected config — persists across searches and
// pagination, and is null when the user has explicitly cleared it.
  ExerciseConfig? get selected;
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
  _$$ExerciseConfigPickerStateImplCopyWith<_$ExerciseConfigPickerStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
