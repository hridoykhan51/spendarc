import 'package:flutter/material.dart';
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
  double _drag = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 360),
          lowerBound: -96,
          upperBound: 0,
        )..addListener(() {
          setState(() => _drag = _controller.value);
        });
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final theme = Theme.of(context);
    final sign = transaction.isExpense ? '-' : '+';
    final amountColor = transaction.isExpense
        ? theme.colorScheme.error
        : const Color(0xff087f5b);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(
          () => _drag = (_drag + details.delta.dx).clamp(-96, 0).toDouble(),
        );
      },
      onHorizontalDragEnd: (_) {
        if (_drag < -56) {
          widget.onDelete(transaction.id);
        }
        _controller
          ..value = _drag
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
            child: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          ),
          Transform.translate(
            offset: Offset(_drag, 0),
            child: ColoredBox(
              color: theme.colorScheme.surface,
              child: ListTile(
                minVerticalPadding: 12,
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(
                    transaction.isExpense
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    size: 18,
                  ),
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
