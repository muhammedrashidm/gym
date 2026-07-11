import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/qr_token.dart';
import '../repositories/staff_repository.dart';

class GetQrTokenQuery extends ICommand<Future<Either<Failure, QrToken>>> {}

@injectable
class GetQrTokenQueryHandler
    extends ICommandHandler<GetQrTokenQuery, Future<Either<Failure, QrToken>>> {
  final StaffRepository _repository;

  GetQrTokenQueryHandler(this._repository);

  @override
  Future<Either<Failure, QrToken>> handle(GetQrTokenQuery command) {
    return _repository.getQrToken();
  }
}
