import 'package:dartz/dartz.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/core/usecase/usecase.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';

class AddTransaction
    implements UseCase<FinanceTransaction, FinanceTransaction> {
  const AddTransaction(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, FinanceTransaction>> call(FinanceTransaction params) {
    if (params.amount <= 0) {
      return Future.value(
        left(const ValidationFailure('Amount must be greater than zero')),
      );
    }
    return repository.addTransaction(params);
  }
}
