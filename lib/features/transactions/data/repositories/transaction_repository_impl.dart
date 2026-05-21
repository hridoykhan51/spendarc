import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:finance_app/core/error/failure.dart';
import 'package:finance_app/core/sync/sync_diff.dart';
import 'package:finance_app/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finance_app/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:finance_app/features/transactions/data/models/transaction_model.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({
    required TransactionLocalDataSource local,
    required TransactionRemoteDataSource remote,
  }) : _local = local,
       _remote = remote;

  final TransactionLocalDataSource _local;
  final TransactionRemoteDataSource _remote;

  @override
  Stream<List<FinanceTransaction>> watchTransactions() {
    return _local.watchTransactions();
  }

  @override
  Future<Either<Failure, List<FinanceTransaction>>> getTransactions() async {
    try {
      final local = await _local.loadTransactions();
      unawaited(syncPending());
      return right(local.where((item) => !item.deleted).toList());
    } on Object catch (error) {
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, FinanceTransaction>> addTransaction(
    FinanceTransaction transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(
        transaction,
      ).copyWith(synced: false, deleted: false);
      await _local.upsert(model);
      unawaited(syncPending());
      return right(model);
    } on Object catch (error) {
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, FinanceTransaction>> deleteTransaction(
    String id,
  ) async {
    try {
      final local = await _local.loadTransactions();
      final transaction = local.firstWhere((item) => item.id == id);
      final deleted = transaction.copyWith(
        deleted: true,
        synced: false,
        updatedAt: DateTime.now(),
      );
      await _local.upsert(deleted);
      unawaited(syncPending());
      return right(deleted);
    } on Object catch (error) {
      return left(CacheFailure(error.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> syncPending() async {
    try {
      final local = await _local.loadTransactions();
      final remote = await _remote.fetchTransactions();
      final diff = await calculateSyncDiff(
        SyncDiffInput(local: local, remote: remote),
      );
      if (diff.toUpload.isNotEmpty) {
        await _remote.pushTransactions(diff.toUpload);
      }
      await _local.saveTransactions(diff.merged);
      return right(diff.toUpload.length);
    } on Object catch (error) {
      return left(SyncFailure(error.toString()));
    }
  }

  @override
  Future<void> dispose() => _local.dispose();
}
