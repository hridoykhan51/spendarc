import 'package:dartz/dartz.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';

abstract interface class TransactionRepository {
  Stream<List<FinanceTransaction>> watchTransactions();

  Future<Either<Failure, List<FinanceTransaction>>> getTransactions();

  Future<Either<Failure, FinanceTransaction>> addTransaction(
    FinanceTransaction transaction,
  );

  Future<Either<Failure, FinanceTransaction>> deleteTransaction(String id);

  Future<Either<Failure, int>> syncPending();

  Future<void> dispose();
}
