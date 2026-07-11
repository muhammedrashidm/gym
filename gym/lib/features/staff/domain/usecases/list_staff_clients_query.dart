import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/client_profile.dart';
import '../repositories/staff_repository.dart';

class ListStaffClientsQuery extends ICommand<Future<Either<Failure, List<ClientProfile>>>> {}

@injectable
class ListStaffClientsQueryHandler
    extends ICommandHandler<ListStaffClientsQuery, Future<Either<Failure, List<ClientProfile>>>> {
  final StaffRepository _repository;

  ListStaffClientsQueryHandler(this._repository);

  @override
  Future<Either<Failure, List<ClientProfile>>> handle(ListStaffClientsQuery command) {
    return _repository.listStaffClients();
  }
}
