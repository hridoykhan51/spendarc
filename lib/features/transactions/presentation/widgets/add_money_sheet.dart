import 'package:flutter/material.dart';
import 'package:finance_app/core/constants/app_icons.dart';
import 'package:finance_app/core/constants/app_strings.dart';
import 'package:finance_app/features/transactions/domain/entities/transaction.dart';

class AddMoneySheet extends StatefulWidget {
  const AddMoneySheet({super.key});

  @override
  State<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<AddMoneySheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = AppStrings.food;
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
              AppStrings.addMoney,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(AppStrings.expense),
                  icon: Icon(AppIcons.expense),
                ),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(AppStrings.income),
                  icon: Icon(AppIcons.income),
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
                labelText: AppStrings.title,
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return AppStrings.enterTitle;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: AppStrings.amount,
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final amount = double.tryParse(value ?? '');
                if (amount == null || amount <= 0) {
                  return AppStrings.enterValidAmount;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: AppStrings.category,
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: AppStrings.food,
                  child: Text(AppStrings.food),
                ),
                DropdownMenuItem(
                  value: AppStrings.transport,
                  child: Text(AppStrings.transport),
                ),
                DropdownMenuItem(
                  value: AppStrings.housing,
                  child: Text(AppStrings.housing),
                ),
                DropdownMenuItem(
                  value: AppStrings.income,
                  child: Text(AppStrings.income),
                ),
                DropdownMenuItem(
                  value: AppStrings.other,
                  child: Text(AppStrings.other),
                ),
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
                icon: const Icon(AppIcons.confirm),
                label: const Text(AppStrings.addTransaction),
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
