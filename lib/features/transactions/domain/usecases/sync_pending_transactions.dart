import 'package:dartz/dartz.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/core/usecase/usecase.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';

class SyncPendingTransactions implements UseCase<int, NoParams> {
  const SyncPendingTransactions(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) {
    return repository.syncPending();
  }
}
