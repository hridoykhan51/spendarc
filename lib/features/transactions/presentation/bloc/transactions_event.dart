part of 'transactions_bloc.dart';

sealed class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsStarted extends TransactionsEvent {
  const TransactionsStarted();
}

class TransactionAdded extends TransactionsEvent {
  const TransactionAdded(this.transaction);

  final FinanceTransaction transaction;

  @override
  List<Object?> get props => [transaction];
}

class TransactionDeleted extends TransactionsEvent {
  const TransactionDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class TransactionsObserved extends TransactionsEvent {
  const TransactionsObserved(this.transactions);

  final List<FinanceTransaction> transactions;

  @override
  List<Object?> get props => [transactions];
}

class TransactionsSyncRequested extends TransactionsEvent {
  const TransactionsSyncRequested();
}
