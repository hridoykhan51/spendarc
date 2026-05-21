import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance_app/features/transactions/domain/usecases/add_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/get_transactions.dart';
import 'package:finance_app/features/transactions/domain/usecases/sync_pending_transactions.dart';
import 'package:finance_app/features/transactions/presentation/bloc/transactions_bloc.dart';

void main() {
  blocTest<TransactionsBloc, TransactionsState>(
    'rolls back optimistic add when use case fails',
    build: () {
      final repository = _RepositoryFake(addFails: true);
      return TransactionsBloc(
        getTransactions: GetTransactions(repository),
        addTransaction: AddTransaction(repository),
        deleteTransaction: DeleteTransaction(repository),
        syncPendingTransactions: SyncPendingTransactions(repository),
        repository: repository,
      );
    },
    act: (bloc) => bloc.add(TransactionAdded(_transaction())),
    expect: () => [
      isA<TransactionsState>()
          .having((state) => state.transactions.length, 'length', 1)
          .having((state) => state.pendingWrites, 'pending writes', 1),
      isA<TransactionsState>()
          .having((state) => state.status, 'status', TransactionsStatus.failure)
          .having((state) => state.transactions, 'transactions', isEmpty)
          .having((state) => state.pendingWrites, 'pending writes', 0),
    ],
  );
}

class _RepositoryFake implements TransactionRepository {
  _RepositoryFake({this.addFails = false});

  final bool addFails;

  @override
  Future<Either<Failure, FinanceTransaction>> addTransaction(
    FinanceTransaction transaction,
  ) async {
    if (addFails) {
      return left(const CacheFailure('write failed'));
    }
    return right(transaction);
  }

  @override
  Future<Either<Failure, FinanceTransaction>> deleteTransaction(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<Either<Failure, List<FinanceTransaction>>> getTransactions() async {
    return right(const []);
  }

  @override
  Future<Either<Failure, int>> syncPending() async {
    return right(0);
  }

  @override
  Stream<List<FinanceTransaction>> watchTransactions() {
    return const Stream.empty();
  }
}

FinanceTransaction _transaction() {
  final now = DateTime(2026, 5, 22);
  return FinanceTransaction(
    id: '1',
    title: 'Coffee',
    category: 'Food',
    amount: 5,
    date: now,
    type: TransactionType.expense,
    updatedAt: now,
  );
}
