import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/auth_token.dart';
import '../entities/trainer_connection.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, AuthToken>> trainerSignup({
    required String name,
    required String bio,
    required int experienceYears,
    required List<String> specializations,
    required List<PlatformFile> certificates,
  });

  Future<Either<Failure, TrainerConnection>> connectToTrainer({
    required String qrToken,
  });
}
