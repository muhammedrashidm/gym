import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/auth_token.dart';

class TrainerSignupCommand extends ICommand<Future<Either<Failure, AuthToken>>> {
  final String name;
  final String bio;
  final int experienceYears;
  final List<String> specializations;
  final List<PlatformFile> certificates;

  TrainerSignupCommand({
    required this.name,
    required this.bio,
    required this.experienceYears,
    required this.specializations,
    required this.certificates,
  });
}
