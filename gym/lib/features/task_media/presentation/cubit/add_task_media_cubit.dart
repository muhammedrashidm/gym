import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_media.dart';
import '../../domain/usecases/manage_task_media.dart';
import 'add_task_media_state.dart';

class AddTaskMediaCubit extends Cubit<AddTaskMediaState> {
  final Mediator _mediator;

  AddTaskMediaCubit(this._mediator) : super(const AddTaskMediaState());

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.media);
    if (result == null || result.files.isEmpty) return;
    emit(state.copyWith(file: result.files.first, error: null));
  }

  void updateName(String value) => emit(state.copyWith(name: value));

  void updateDescription(String value) => emit(state.copyWith(description: value));

  void addKeyword(String raw) {
    final keyword = raw.trim().toLowerCase();
    if (keyword.isEmpty || state.keywords.contains(keyword)) return;
    emit(state.copyWith(keywords: [...state.keywords, keyword]));
  }

  void removeKeyword(String keyword) {
    emit(state.copyWith(
      keywords: state.keywords.where((k) => k != keyword).toList(),
    ));
  }

  void toggleIsPrivate() => emit(state.copyWith(isPrivate: !state.isPrivate));

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(isSubmitting: true, error: null));

    final result = await _mediator.sendCommand(
      CreateTaskMediaCommand(
        file: state.file!,
        name: state.name.trim(),
        description: state.description.trim().isEmpty ? null : state.description.trim(),
        keywords: state.keywords.isEmpty ? null : state.keywords,
        isPrivate: state.isPrivate,
      ),
    ) as Either<Failure, TaskMedia>;

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        error: _mapFailure(failure),
      )),
      (media) => emit(state.copyWith(isSubmitting: false, created: media)),
    );
  }

  String _mapFailure(Failure failure) => failure.maybeWhen(
        server: (_, msg) => msg,
        network: (msg) => msg ?? 'Network error.',
        unknown: (msg) => msg ?? 'Unknown error.',
        unauthorized: () => 'Unauthorized.',
        orElse: () => 'Unexpected error.',
      );
}
