import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finance_app/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:finance_app/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:finance_app/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance_app/features/transactions/domain/usecases/add_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/get_transactions.dart';
import 'package:finance_app/features/transactions/domain/usecases/sync_pending_transactions.dart';
import 'package:finance_app/features/transactions/presentation/widgets/arc_budget_meter.dart';
import 'package:finance_app/features/transactions/presentation/widgets/spending_line_chart.dart';
import 'package:finance_app/injection_container.dart';
import 'package:finance_app/main.dart';
import 'package:hive/hive.dart';

void main() {
  testWidgets('custom budget and chart widgets render', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ArcBudgetMeter(progress: 0.4, expenses: 400, budget: 1000),
              SpendingLineChart(values: [0, 12, 4, 20, 8, 24, 15]),
            ],
          ),
        ),
      ),
    );

    expect(find.text('\$400'), findsOneWidget);
    expect(find.byType(CustomPaint), findsNWidgets(2));
  });

  testWidgets('SpendArc app shows title and add action', (tester) async {
    final directory = await Directory.systemTemp.createTemp('spendarc_widget');
    Hive.init(directory.path);
    final box = await Hive.openBox<Map>('transactions_widget_test');
    await sl.reset();
    sl
      ..registerLazySingleton<Box<Map>>(() => box)
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

    await tester.pumpWidget(const SpendArcApp());
    await tester.pump();

    expect(find.text('SpendArc'), findsOneWidget);
    expect(find.text('Add money'), findsOneWidget);
    await box.close();
    await directory.delete(recursive: true);
  });

  tearDownAll(() async {
    await sl.reset(dispose: true);
  });
}
