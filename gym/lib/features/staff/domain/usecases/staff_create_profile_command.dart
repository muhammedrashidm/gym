import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_profile.dart';
import '../repositories/staff_repository.dart';

class StaffCreateProfileCommand extends ICommand<Future<Either<Failure, ClientProfile>>> {
  final String phoneNumber;
  final String fullName;
  final int? age;
  final String? sex;
  final String? expLevel;
  final double? weight;
  final double? height;
  final double? muscleMass;
  final double? bodyFatPct;

  StaffCreateProfileCommand({
    required this.phoneNumber,
    required this.fullName,
    this.age,
    this.sex,
    this.expLevel,
    this.weight,
    this.height,
    this.muscleMass,
    this.bodyFatPct,
  });
}

@injectable
class StaffCreateProfileCommandHandler
    extends ICommandHandler<StaffCreateProfileCommand, Future<Either<Failure, ClientProfile>>> {
  final StaffRepository _repository;

  StaffCreateProfileCommandHandler(this._repository);

  @override
  Future<Either<Failure, ClientProfile>> handle(StaffCreateProfileCommand command) {
    return _repository.staffCreateProfile(
      phoneNumber: command.phoneNumber,
      fullName: command.fullName,
      age: command.age,
      sex: command.sex,
      expLevel: command.expLevel,
      weight: command.weight,
      height: command.height,
      muscleMass: command.muscleMass,
      bodyFatPct: command.bodyFatPct,
    );
  }
}
