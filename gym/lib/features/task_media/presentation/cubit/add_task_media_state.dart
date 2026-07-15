import 'package:file_picker/file_picker.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/task_media.dart';

part 'add_task_media_state.freezed.dart';

@freezed
class AddTaskMediaState with _$AddTaskMediaState {
  const AddTaskMediaState._();

  const factory AddTaskMediaState({
    PlatformFile? file,
    @Default('') String name,
    @Default('') String description,
    @Default(<String>[]) List<String> keywords,
    @Default(false) bool isPrivate,
    @Default(false) bool isSubmitting,
    String? error,
    // Non-null once the upload succeeds — the page listens and pops with it.
    TaskMedia? created,
  }) = _AddTaskMediaState;

  bool get canSubmit => file != null && name.trim().isNotEmpty && !isSubmitting;
}
