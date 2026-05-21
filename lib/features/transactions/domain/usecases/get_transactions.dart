import 'package:dartz/dartz.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/core/usecase/usecase.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactions implements UseCase<List<FinanceTransaction>, NoParams> {
  const GetTransactions(this.repository);

  final TransactionRepository repository;

  @override
  Future<Either<Failure, List<FinanceTransaction>>> call(NoParams params) {
    return repository.getTransactions();
  }
}
