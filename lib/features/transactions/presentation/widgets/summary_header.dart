import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_app/core/constants/app_strings.dart';
import 'package:finance_app/features/transactions/presentation/bloc/summary_bloc.dart';
import 'package:finance_app/features/transactions/presentation/widgets/arc_budget_meter.dart';
import 'package:finance_app/features/transactions/presentation/widgets/metric_card.dart';
import 'package:finance_app/features/transactions/presentation/widgets/spending_line_chart.dart';

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SummaryBloc, SummaryState>(
      buildWhen: (previous, current) => previous.summary != current.summary,
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
                AppStrings.lastSevenDays,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SpendingLineChart(values: summary.byDay),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      label: AppStrings.income,
                      value: '\$${summary.income.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      label: AppStrings.balance,
                      value: '\$${summary.balance.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                AppStrings.addedMoney,
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
