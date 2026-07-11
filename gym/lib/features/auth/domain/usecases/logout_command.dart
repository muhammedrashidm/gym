import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class LogoutCommand extends ICommand<Future<Either<Failure, Unit>>> {
  final String refreshToken;
  LogoutCommand({required this.refreshToken});
}
