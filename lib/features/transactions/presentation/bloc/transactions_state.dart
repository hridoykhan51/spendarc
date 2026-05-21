part of 'transactions_bloc.dart';

enum TransactionsStatus { initial, loading, success, failure }

class TransactionsState extends Equatable {
  const TransactionsState({
    this.status = TransactionsStatus.initial,
    this.transactions = const [],
    this.pendingWrites = 0,
    this.syncing = false,
    this.message = '',
  });

  final TransactionsStatus status;
  final List<FinanceTransaction> transactions;
  final int pendingWrites;
  final bool syncing;
  final String message;

  TransactionsState copyWith({
    TransactionsStatus? status,
    List<FinanceTransaction>? transactions,
    int? pendingWrites,
    bool? syncing,
    String? message,
  }) {
    return TransactionsState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      pendingWrites: pendingWrites ?? this.pendingWrites,
      syncing: syncing ?? this.syncing,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    transactions,
    pendingWrites,
    syncing,
    message,
  ];
}
