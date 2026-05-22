import 'package:flutter/material.dart';
import 'package:finance_app/core/constants/app_colors.dart';
import 'package:finance_app/core/constants/app_icons.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatefulWidget {
  const TransactionTile({
    required this.transaction,
    required this.onDelete,
    super.key,
  });

  final FinanceTransaction transaction;
  final ValueChanged<String> onDelete;

  @override
  State<TransactionTile> createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final ValueNotifier<double> _drag;

  @override
  void initState() {
    super.initState();
    _drag = ValueNotifier<double>(0);
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 360),
          lowerBound: -96,
          upperBound: 0,
        )..addListener(() {
          _drag.value = _controller.value;
        });
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final theme = Theme.of(context);
    final sign = transaction.isExpense ? '-' : '+';
    final amountColor = transaction.isExpense
        ? theme.colorScheme.error
        : AppColors.incomeGreen;
    final directionIcon = transaction.isExpense
        ? AppIcons.expense
        : AppIcons.income;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        _drag.value = (_drag.value + details.delta.dx).clamp(-96, 0).toDouble();
      },
      onHorizontalDragEnd: (_) {
        if (_drag.value < -56) {
          widget.onDelete(transaction.id);
        }
        _controller
          ..value = _drag.value
          ..animateTo(0, curve: Curves.elasticOut);
      },
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            height: 76,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            color: theme.colorScheme.errorContainer,
            child: Icon(AppIcons.delete, color: theme.colorScheme.error),
          ),
          AnimatedBuilder(
            animation: _drag,
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: ListTile(
                minVerticalPadding: 12,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(directionIcon, size: 18),
                ),
                title: Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${transaction.category} · ${DateFormat.MMMd().format(transaction.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '$sign\$${transaction.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_drag.value, 0),
                child: child,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _drag.dispose();
    super.dispose();
  }
}
