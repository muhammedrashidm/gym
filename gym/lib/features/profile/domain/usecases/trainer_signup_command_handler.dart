import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/auth_token.dart';
import '../repositories/profile_repository.dart';
import 'trainer_signup_command.dart';

@injectable
class TrainerSignupCommandHandler
    extends ICommandHandler<TrainerSignupCommand, Future<Either<Failure, AuthToken>>> {
  final ProfileRepository _repository;

  TrainerSignupCommandHandler(this._repository);

  @override
  Future<Either<Failure, AuthToken>> handle(TrainerSignupCommand command) =>
      _repository.trainerSignup(
        name: command.name,
        bio: command.bio,
        experienceYears: command.experienceYears,
        specializations: command.specializations,
        certificates: command.certificates,
      );
}
