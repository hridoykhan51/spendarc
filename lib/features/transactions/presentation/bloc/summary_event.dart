part of 'summary_bloc.dart';

sealed class SummaryEvent extends Equatable {
  const SummaryEvent();

  @override
  List<Object?> get props => [];
}

class SummaryStarted extends SummaryEvent {
  const SummaryStarted();
}

class SummaryTransactionsChanged extends SummaryEvent {
  const SummaryTransactionsChanged(this.transactions);

  final List<FinanceTransaction> transactions;

  @override
  List<Object?> get props => [transactions];
}
