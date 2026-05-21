import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/core/sync/sync_diff.dart';
import 'package:finance_app/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finance_app/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:hive/hive.dart';

void main() {
  test('TransactionModel maps to and from JSON', () {
    final now = DateTime(2026, 5, 22);
    final model = TransactionModel(
      id: 'txn',
      title: 'Lunch',
      category: 'Food',
      amount: 18.5,
      date: now,
      type: TransactionType.expense,
      updatedAt: now,
      synced: true,
    );

    final restored = TransactionModel.fromJson(model.toJson());

    expect(restored, model);
  });

  test('local data source persists transactions and emits updates', () async {
    final directory = await Directory.systemTemp.createTemp('spendarc_test');
    Hive.init(directory.path);
    final box = await Hive.openBox<Map>('transactions_test');
    final source = HiveTransactionLocalDataSource(box: box);
    final now = DateTime(2026, 5, 22);
    final model = TransactionModel(
      id: '1',
      title: 'Taxi',
      category: 'Transport',
      amount: 9,
      date: now,
      type: TransactionType.expense,
      updatedAt: now,
    );

    final emission = expectLater(
      source.watchTransactions(),
      emits(contains(model)),
    );
    await source.saveTransactions([model]);
    final loaded = await source.loadTransactions();

    expect(loaded, [model]);
    await emission;
    await source.dispose();
    await box.close();
    await directory.delete(recursive: true);
  });

  test(
    'sync diff prefers newer local changes and marks upload queue',
    () async {
      final older = DateTime(2026, 5, 21);
      final newer = DateTime(2026, 5, 22);
      final remote = _model(
        id: '1',
        amount: 20,
        updatedAt: older,
        synced: true,
      );
      final local = _model(id: '1', amount: 25, updatedAt: newer);

      final diff = await calculateSyncDiff(
        SyncDiffInput(local: [local], remote: [remote]),
      );

      expect(diff.merged.single.amount, 25);
      expect(diff.toUpload.single.id, '1');
    },
  );

  test('repository returns local data before remote sync completes', () async {
    final directory = await Directory.systemTemp.createTemp('spendarc_repo');
    Hive.init(directory.path);
    final box = await Hive.openBox<Map>('transactions_repo_test');
    final local = HiveTransactionLocalDataSource(box: box);
    final remote = FakeTransactionRemoteDataSource();
    final repository = TransactionRepositoryImpl(local: local, remote: remote);
    final model = _model(id: 'local', amount: 10, updatedAt: DateTime(2026));
    await local.saveTransactions([model]);

    final result = await repository.getTransactions();

    expect(result.getOrElse(() => []), [model]);
    await repository.dispose();
    await box.close();
    await directory.delete(recursive: true);
  });
}

TransactionModel _model({
  required String id,
  required double amount,
  required DateTime updatedAt,
  bool synced = false,
}) {
  return TransactionModel(
    id: id,
    title: 'Item $id',
    category: 'General',
    amount: amount,
    date: updatedAt,
    type: TransactionType.expense,
    updatedAt: updatedAt,
    synced: synced,
  );
}
