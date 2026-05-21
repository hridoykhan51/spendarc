import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_app/features/transactions/domain/entities/spending_summary.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';

part 'summary_event.dart';
part 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  SummaryBloc({
    required TransactionRepository repository,
    double monthlyBudget = 2500,
  }) : _repository = repository,
       _monthlyBudget = monthlyBudget,
       super(SummaryState.initial(monthlyBudget)) {
    on<SummaryStarted>(_onStarted);
    on<SummaryTransactionsChanged>(_onTransactionsChanged);
  }

  final TransactionRepository _repository;
  final double _monthlyBudget;
  StreamSubscription<List<FinanceTransaction>>? _subscription;

  Future<void> _onStarted(
    SummaryStarted event,
    Emitter<SummaryState> emit,
  ) async {
    await _subscription?.cancel();
    _subscription = _repository.watchTransactions().listen(
      (transactions) => add(SummaryTransactionsChanged(transactions)),
    );
  }

  void _onTransactionsChanged(
    SummaryTransactionsChanged event,
    Emitter<SummaryState> emit,
  ) {
    emit(SummaryState(summary: _summarize(event.transactions)));
  }

  SpendingSummary _summarize(List<FinanceTransaction> transactions) {
    final visible = transactions.where((item) => !item.deleted);
    final income = visible
        .where((item) => item.type == TransactionType.income)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final expenses = visible
        .where((item) => item.type == TransactionType.expense)
        .fold<double>(0, (sum, item) => sum + item.amount);
    final byDay = List<double>.filled(7, 0);
    final now = DateTime.now();
    for (final transaction in visible) {
      if (!transaction.isExpense) {
        continue;
      }
      final diff = now.difference(transaction.date).inDays;
      if (diff >= 0 && diff < byDay.length) {
        byDay[byDay.length - 1 - diff] += transaction.amount;
      }
    }
    return SpendingSummary(
      income: income,
      expenses: expenses,
      budget: _monthlyBudget,
      byDay: byDay,
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
