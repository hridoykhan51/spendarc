import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_app/core/usecase/usecase.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:finance_app/features/transactions/domain/usecases/add_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:finance_app/features/transactions/domain/usecases/get_transactions.dart';
import 'package:finance_app/features/transactions/domain/usecases/sync_pending_transactions.dart';

part 'transactions_event.dart';
part 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc({
    required GetTransactions getTransactions,
    required AddTransaction addTransaction,
    required DeleteTransaction deleteTransaction,
    required SyncPendingTransactions syncPendingTransactions,
    required TransactionRepository repository,
  }) : _getTransactions = getTransactions,
       _addTransaction = addTransaction,
       _deleteTransaction = deleteTransaction,
       _syncPendingTransactions = syncPendingTransactions,
       _repository = repository,
       super(const TransactionsState()) {
    on<TransactionsStarted>(_onStarted);
    on<TransactionAdded>(_onAdded);
    on<TransactionDeleted>(_onDeleted);
    on<TransactionsObserved>(_onObserved);
    on<TransactionsSyncRequested>(_onSyncRequested);
  }

  final GetTransactions _getTransactions;
  final AddTransaction _addTransaction;
  final DeleteTransaction _deleteTransaction;
  final SyncPendingTransactions _syncPendingTransactions;
  final TransactionRepository _repository;
  StreamSubscription<List<FinanceTransaction>>? _subscription;

  Future<void> _onStarted(
    TransactionsStarted event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(status: TransactionsStatus.loading));
    await _subscription?.cancel();
    _subscription = _repository.watchTransactions().listen(
      (transactions) => add(TransactionsObserved(transactions)),
    );

    final result = await _getTransactions(const NoParams());
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          message: failure.message,
        ),
      ),
      (transactions) => emit(
        state.copyWith(
          status: TransactionsStatus.success,
          transactions: _visibleSorted(transactions),
          message: '',
        ),
      ),
    );
  }

  Future<void> _onAdded(
    TransactionAdded event,
    Emitter<TransactionsState> emit,
  ) async {
    final previous = state.transactions;
    final optimistic = _visibleSorted([event.transaction, ...previous]);
    // Optimistic UI: commit visually first, then rollback on write failure.
    emit(
      state.copyWith(
        status: TransactionsStatus.success,
        transactions: optimistic,
        pendingWrites: state.pendingWrites + 1,
        message: '',
      ),
    );

    final result = await _addTransaction(event.transaction);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          transactions: previous,
          pendingWrites: (state.pendingWrites - 1).clamp(0, 999).toInt(),
          message: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: TransactionsStatus.success,
          pendingWrites: (state.pendingWrites - 1).clamp(0, 999).toInt(),
        ),
      ),
    );
  }

  Future<void> _onDeleted(
    TransactionDeleted event,
    Emitter<TransactionsState> emit,
  ) async {
    final previous = state.transactions;
    // Remove immediately for perceived speed; restore previous list if delete fails.
    emit(
      state.copyWith(
        transactions: previous.where((item) => item.id != event.id).toList(),
        pendingWrites: state.pendingWrites + 1,
        message: '',
      ),
    );

    final result = await _deleteTransaction(event.id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: TransactionsStatus.failure,
          transactions: previous,
          pendingWrites: (state.pendingWrites - 1).clamp(0, 999).toInt(),
          message: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: TransactionsStatus.success,
          pendingWrites: (state.pendingWrites - 1).clamp(0, 999).toInt(),
        ),
      ),
    );
  }

  void _onObserved(
    TransactionsObserved event,
    Emitter<TransactionsState> emit,
  ) {
    emit(
      state.copyWith(
        status: TransactionsStatus.success,
        transactions: _visibleSorted(event.transactions),
      ),
    );
  }

  Future<void> _onSyncRequested(
    TransactionsSyncRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(state.copyWith(syncing: true));
    final result = await _syncPendingTransactions(const NoParams());
    result.fold(
      (failure) =>
          emit(state.copyWith(syncing: false, message: failure.message)),
      (_) => emit(state.copyWith(syncing: false, message: '')),
    );
  }

  List<FinanceTransaction> _visibleSorted(
    List<FinanceTransaction> transactions,
  ) {
    return transactions.where((item) => !item.deleted).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
