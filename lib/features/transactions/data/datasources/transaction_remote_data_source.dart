import 'dart:async';

import 'package:finance_app/features/transactions/data/models/transaction_model.dart';

abstract interface class TransactionRemoteDataSource {
  Future<List<TransactionModel>> fetchTransactions();

  Future<void> pushTransactions(List<TransactionModel> transactions);
}

class FakeTransactionRemoteDataSource implements TransactionRemoteDataSource {
  FakeTransactionRemoteDataSource({
    List<TransactionModel> seed = const [],
    this.shouldFail = false,
  }) : _remote = [...seed];

  final bool shouldFail;
  final List<TransactionModel> _remote;

  @override
  Future<List<TransactionModel>> fetchTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (shouldFail) {
      throw TimeoutException('Remote service unavailable');
    }
    return [..._remote];
  }

  @override
  Future<void> pushTransactions(List<TransactionModel> transactions) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (shouldFail) {
      throw TimeoutException('Remote service unavailable');
    }
    for (final transaction in transactions) {
      final index = _remote.indexWhere((item) => item.id == transaction.id);
      if (index == -1) {
        _remote.add(transaction.copyWith(synced: true));
      } else {
        _remote[index] = transaction.copyWith(synced: true);
      }
    }
  }
}
