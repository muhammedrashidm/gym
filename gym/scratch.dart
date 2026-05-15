import 'package:dartz/dartz.dart';
import 'package:gym/core/error/failures.dart';
import 'package:dart_mediatr/dart_mediatr.dart';

class SendOtpCommand extends ICommand<Future<Either<Failure, Unit>>> {}

void main() async {
  final _mediator = Mediator();
  var res = _mediator.sendCommand(SendOtpCommand());
  print(res.runtimeType);
}
