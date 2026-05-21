import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:finance_app/features/transactions/presentation/bloc/summary_bloc.dart';
import 'package:finance_app/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:finance_app/features/transactions/presentation/widgets/arc_budget_meter.dart';
import 'package:finance_app/features/transactions/presentation/widgets/particle_burst.dart';
import 'package:finance_app/features/transactions/presentation/widgets/spending_line_chart.dart';
import 'package:finance_app/features/transactions/presentation/widgets/transaction_tile.dart';
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
              title: const Text('SpendArc'),
              actions: [
                BlocBuilder<TransactionsBloc, TransactionsState>(
                  builder: (context, state) {
                    return IconButton(
                      tooltip: 'Sync',
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
                          : const Icon(Icons.sync),
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
                      SliverToBoxAdapter(child: _SummaryHeader()),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      _TransactionsList(),
                    ],
                  ),
                ),
                Positioned.fill(child: ParticleBurst(trigger: _burstTrigger)),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openAddMoneySheet(context),
              icon: const Icon(Icons.add),
              label: const Text('Add money'),
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
      builder: (_) => const _AddMoneySheet(),
    );

    if (transaction == null || !mounted) {
      return;
    }

    bloc.add(TransactionAdded(transaction));
    setState(() => _burstTrigger++);
  }
}

class _AddMoneySheet extends StatefulWidget {
  const _AddMoneySheet();

  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Food';
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add money',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selection) {
                setState(() => _type = selection.single);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                DropdownMenuItem(value: 'Housing', child: Text('Housing')),
                DropdownMenuItem(value: 'Income', child: Text('Income')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.check),
                label: const Text('Add transaction'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final now = DateTime.now();
    Navigator.of(context).pop(
      FinanceTransaction(
        id: 'txn-${now.microsecondsSinceEpoch}',
        title: _titleController.text.trim(),
        category: _category,
        amount: double.parse(_amountController.text),
        date: now,
        type: _type,
        updatedAt: now,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}

class _SummaryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      builder: (context, state) {
        final summary = state.summary;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ArcBudgetMeter(
                progress: summary.budgetProgress,
                expenses: summary.expenses,
                budget: summary.budget,
              ),
              const SizedBox(height: 20),
              Text(
                'Last 7 days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SpendingLineChart(values: summary.byDay),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: 'Income',
                      value: '\$${summary.income.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Metric(
                      label: 'Balance',
                      value: '\$${summary.balance.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Added money',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
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
            child: Center(child: Text('No transactions yet')),
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
