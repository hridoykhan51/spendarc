import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_app/core/constants/app_strings.dart';
import 'package:finance_app/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:finance_app/features/transactions/presentation/widgets/transaction_tile.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.transactions != current.transactions,
      builder: (context, state) {
        if (state.status == TransactionsStatus.loading) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.transactions.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(AppStrings.noTransactionsYet)),
          );
        }
        return SliverList.separated(
          itemCount: state.transactions.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final transaction = state.transactions[index];
            return TransactionTile(
              transaction: transaction,
              onDelete: (id) =>
                  context.read<TransactionsBloc>().add(TransactionDeleted(id)),
            );
          },
        );
      },
    );
  }
}
