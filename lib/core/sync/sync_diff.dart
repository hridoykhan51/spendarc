import 'dart:isolate';

import 'package:finance_app/features/transactions/data/models/transaction_model.dart';

class SyncDiffResult {
  const SyncDiffResult({required this.merged, required this.toUpload});

  final List<TransactionModel> merged;
  final List<TransactionModel> toUpload;
}

class SyncDiffInput {
  const SyncDiffInput({required this.local, required this.remote});

  final List<TransactionModel> local;
  final List<TransactionModel> remote;
}

Future<SyncDiffResult> calculateSyncDiff(SyncDiffInput input) {
  // Diffing may grow with transaction count, so keep merge work off the UI isolate.
  return Isolate.run(() => _calculateSyncDiffOnIsolate(input));
}

SyncDiffResult _calculateSyncDiffOnIsolate(SyncDiffInput input) {
  final byId = <String, TransactionModel>{};
  final toUpload = <TransactionModel>[];

  for (final remote in input.remote) {
    byId[remote.id] = remote.copyWith(synced: true);
  }

  for (final local in input.local) {
    final remote = byId[local.id];
    // Last-write-wins conflict resolution based on updatedAt timestamps.
    if (remote == null || local.updatedAt.isAfter(remote.updatedAt)) {
      byId[local.id] = local.copyWith(synced: true);
      final remoteUpdatedAt = remote?.updatedAt ?? DateTime(0);
      if (!local.synced || local.updatedAt.isAfter(remoteUpdatedAt)) {
        toUpload.add(local);
      }
    }
  }

  final merged = byId.values.where((item) => !item.deleted).toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  return SyncDiffResult(merged: merged, toUpload: toUpload);
}
