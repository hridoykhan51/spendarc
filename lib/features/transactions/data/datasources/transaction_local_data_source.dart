import 'dart:async';

import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:hive/hive.dart';

abstract interface class TransactionLocalDataSource {
  Stream<List<TransactionModel>> watchTransactions();

  Future<List<TransactionModel>> loadTransactions();

  Future<void> saveTransactions(List<TransactionModel> transactions);

  Future<void> upsert(TransactionModel transaction);

  Future<void> dispose();
}

class HiveTransactionLocalDataSource implements TransactionLocalDataSource {
  HiveTransactionLocalDataSource({required Box<Map> box}) : _box = box;

  static const boxName = 'transactions';

  final Box<Map> _box;
  final _controller = StreamController<List<TransactionModel>>.broadcast();
  List<TransactionModel> _cache = const [];

  @override
  Stream<List<TransactionModel>> watchTransactions() => _controller.stream;

  @override
  Future<List<TransactionModel>> loadTransactions() async {
    if (_box.isEmpty) {
      _cache = _seedTransactions();
      await saveTransactions(_cache);
      return _cache;
    }

    _cache =
        _box.values
            .map((item) => Map<String, dynamic>.from(item))
            .map(TransactionModel.fromJson)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    _controller.add(_cache);
    return _cache;
  }

  @override
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    _cache = [...transactions]..sort((a, b) => b.date.compareTo(a.date));
    await _box.clear();
    await _box.putAll({
      for (final transaction in _cache) transaction.id: transaction.toJson(),
    });
    _controller.add(_cache);
  }

  @override
  Future<void> upsert(TransactionModel transaction) async {
    await _box.put(transaction.id, transaction.toJson());
    await loadTransactions();
  }

  @override
  Future<void> dispose() async {
    await _controller.close();
  }

  List<TransactionModel> _seedTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'seed-rent',
        title: 'Apartment rent',
        category: 'Housing',
        amount: 1200,
        date: now.subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        updatedAt: now,
        synced: true,
      ),
      TransactionModel(
        id: 'seed-salary',
        title: 'Salary',
        category: 'Income',
        amount: 4200,
        date: now.subtract(const Duration(days: 3)),
        type: TransactionType.income,
        updatedAt: now,
        synced: true,
      ),
      TransactionModel(
        id: 'seed-groceries',
        title: 'Groceries',
        category: 'Food',
        amount: 145.45,
        date: now.subtract(const Duration(days: 4)),
        type: TransactionType.expense,
        updatedAt: now,
        synced: true,
      ),
    ];
  }
}
