import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_app/core/error/failure.dart';

abstract interface class UseCase<Result, Params> {
  Future<Either<Failure, Result>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
