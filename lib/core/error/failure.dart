import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class SyncFailure extends Failure {
  const SyncFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
