import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

class SendOtpCommand extends ICommand<Future<Either<Failure, String?>>> {
  final String phoneNumber;
  SendOtpCommand({required this.phoneNumber});
}
