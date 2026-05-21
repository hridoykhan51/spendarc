import 'package:finance_app/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finance_app/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:finance_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance_app/features/transactions/domain/usecases/add_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/get_transactions.dart';
import 'package:finance_app/features/transactions/domain/usecases/sync_pending_transactions.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  if (sl.isRegistered<TransactionRepository>()) {
    return;
  }

  await Hive.initFlutter();
  final transactionsBox = await Hive.openBox<Map>(
    HiveTransactionLocalDataSource.boxName,
  );

  sl
    ..registerLazySingleton<Box<Map>>(() => transactionsBox)
    ..registerLazySingleton<TransactionLocalDataSource>(
      () => HiveTransactionLocalDataSource(box: sl()),
    )
    ..registerLazySingleton<TransactionRemoteDataSource>(
      FakeTransactionRemoteDataSource.new,
    )
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(local: sl(), remote: sl()),
    )
    ..registerFactory(() => GetTransactions(sl()))
    ..registerFactory(() => AddTransaction(sl()))
    ..registerFactory(() => DeleteTransaction(sl()))
    ..registerFactory(() => SyncPendingTransactions(sl()));
}
