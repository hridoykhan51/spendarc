import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_app/core/constants/app_icons.dart';
import 'package:finance_app/core/constants/app_strings.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/presentation/bloc/summary_bloc.dart';
import 'package:finance_app/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:finance_app/features/transactions/presentation/widgets/add_money_sheet.dart';
import 'package:finance_app/features/transactions/presentation/widgets/particle_burst.dart';
import 'package:finance_app/features/transactions/presentation/widgets/summary_header.dart';
import 'package:finance_app/features/transactions/presentation/widgets/transactions_list.dart';
import 'package:finance_app/injection_container.dart';

class SpendArcPage extends StatefulWidget {
  const SpendArcPage({super.key});

  @override
  State<SpendArcPage> createState() => _SpendArcPageState();
}

class _SpendArcPageState extends State<SpendArcPage> {
  int _burstTrigger = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TransactionsBloc(
            getTransactions: sl(),
            addTransaction: sl(),
            deleteTransaction: sl(),
            syncPendingTransactions: sl(),
            repository: sl(),
          )..add(const TransactionsStarted()),
        ),
        BlocProvider(
          create: (_) =>
              SummaryBloc(repository: sl())..add(const SummaryStarted()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(AppStrings.appName),
              actions: [
                BlocBuilder<TransactionsBloc, TransactionsState>(
                  buildWhen: (previous, current) =>
                      previous.syncing != current.syncing,
                  builder: (context, state) {
                    return IconButton(
                      tooltip: AppStrings.sync,
                      onPressed: state.syncing
                          ? null
                          : () => context.read<TransactionsBloc>().add(
                              const TransactionsSyncRequested(),
                            ),
                      icon: state.syncing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(AppIcons.sync),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async => context.read<TransactionsBloc>().add(
                    const TransactionsSyncRequested(),
                  ),
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(child: SummaryHeader()),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      const TransactionsList(),
                    ],
                  ),
                ),
                Positioned.fill(child: ParticleBurst(trigger: _burstTrigger)),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openAddMoneySheet(context),
              icon: const Icon(AppIcons.add),
              label: const Text(AppStrings.addMoney),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddMoneySheet(BuildContext context) async {
    final bloc = context.read<TransactionsBloc>();
    final transaction = await showModalBottomSheet<FinanceTransaction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddMoneySheet(),
    );

    if (transaction == null || !mounted) {
      return;
    }

    bloc.add(TransactionAdded(transaction));
    setState(() => _burstTrigger++);
  }
}
