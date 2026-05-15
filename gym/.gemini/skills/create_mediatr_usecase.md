# Skill: Create dart_mediatr Command/Query and Handler

## Context
We use `dart_mediatr` for implementing the CQRS pattern (Commands and Queries) in our Clean Architecture Flutter application. We also use `dartz` (`Either`) for functional error handling, and `injectable` for dependency injection.

Whenever you are asked to "Create a new use case", "Create a command", or "Create a query", follow these exact conventions.

## 1. Command / Query Definition

Create a class that extends `ICommand` (for mutations/actions) or `IQuery` (for fetching data). 

**CRITICAL RULES:**
1. The generic return type must ALWAYS be wrapped in a `Future<Either<Failure, ReturnType>>` because our handlers execute asynchronously and return `Either` for error handling.
2. Do NOT use `const` constructors for the Command/Query if it extends `ICommand` or `IQuery` because the base classes in `dart_mediatr` do not have const constructors.

**Template (`example_command.dart`):**
```dart
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
// Import your return type entity here

class ExampleCommand extends ICommand<Future<Either<Failure, Unit>>> {
  final String param1;
  final int param2;

  // NO const constructor
  ExampleCommand({required this.param1, required this.param2});
}
```

## 2. Handler Definition

Create a handler class that extends `ICommandHandler` (or `IQueryHandler`).

**CRITICAL RULES:**
1. Annotate the handler with `@injectable` so it can be resolved by GetIt.
2. The signature must strictly match: `extends ICommandHandler<ExampleCommand, Future<Either<Failure, ReturnType>>>`.
3. Do NOT use a `const` constructor for the handler, as `ICommandHandler` does not support it.
4. Inject the necessary Repository interface via the constructor.

**Template (`example_command_handler.dart`):**
```dart
import 'package:dart_mediatr/dart_mediatr.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import 'example_command.dart';
// Import your repository here

@injectable
class ExampleCommandHandler extends ICommandHandler<ExampleCommand, Future<Either<Failure, Unit>>> {
  final ExampleRepository _repository;

  ExampleCommandHandler(this._repository);

  @override
  Future<Either<Failure, Unit>> handle(ExampleCommand command) async {
    // Call the repository and return the Either result
    return await _repository.doSomething(
      param1: command.param1, 
      param2: command.param2,
    );
  }
}
```

## 3. Invoking the Command/Query in a Cubit/Bloc

Because `dart_mediatr`'s `sendCommand` uses generics that Dart often struggles to infer when wrapped in `Future<Either<...>>`, you must safely cast and await the result to avoid runtime `TypeError` or `undefined_method 'fold'` errors.

**CRITICAL RULES for Invocation:**
1. Always await the `sendCommand` call to get the result from the Mediator.
2. Cast the result to the explicit `Future<Either<Failure, ReturnType>>` to satisfy the compiler.
3. Await the casted result again to unwrap the `Future` and access the `Either`.

**Template:**
```dart
  Future<void> executeExample(String param1, int param2) async {
    emit(const MyState.loading());
    
    // 1. Send command
    final commandResult = await _mediator.sendCommand(
      ExampleCommand(param1: param1, param2: param2)
    );
    
    // 2. Cast and await the nested Future
    final result = await (commandResult as Future<Either<Failure, Unit>>);
    
    // 3. Fold the Either
    result.fold(
      (failure) => emit(MyState.error(message: failure.toString())),
      (success) => emit(const MyState.success()),
    );
  }
```

## Checklist for AI:
- [ ] Is the generic type `Future<Either<Failure, T>>`?
- [ ] Did I remove `const` constructors from the Command and Handler?
- [ ] Is the Handler annotated with `@injectable`?
- [ ] Did I implement the double await/cast pattern when invoking `_mediator.sendCommand()`?
