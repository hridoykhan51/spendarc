import 'package:dartz/dartz.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/core/usecase/usecase.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransaction implements UseCase<FinanceTransaction, String> {
  const DeleteTransaction(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, FinanceTransaction>> call(String params) {
    return repository.deleteTransaction(params);
  }
}
