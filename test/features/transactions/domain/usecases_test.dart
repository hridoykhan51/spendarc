import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance_app/features/transactions/domain/usecases/add_transaction.dart';

void main() {
  test('AddTransaction rejects non-positive amounts', () async {
    final useCase = AddTransaction(_RepositoryFake());
    final now = DateTime(2026);

    final result = await useCase(
      FinanceTransaction(
        id: '1',
        title: 'Invalid',
        category: 'Test',
        amount: 0,
        date: now,
        type: TransactionType.expense,
        updatedAt: now,
      ),
    );

    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Expected validation failure'),
    );
  });
}

class _RepositoryFake implements TransactionRepository {
  @override
  Future<Either<Failure, FinanceTransaction>> addTransaction(
    FinanceTransaction transaction,
  ) async {
    return right(transaction);
  }

  @override
  Future<Either<Failure, FinanceTransaction>> deleteTransaction(String id) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<Either<Failure, List<FinanceTransaction>>> getTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, int>> syncPending() {
    throw UnimplementedError();
  }

  @override
  Stream<List<FinanceTransaction>> watchTransactions() {
    return const Stream.empty();
  }
}
