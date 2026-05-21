import 'package:equatable/equatable.dart';

enum TransactionType { expense, income }

class FinanceTransaction extends Equatable {
  const FinanceTransaction({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
    required this.type,
    required this.updatedAt,
    this.deleted = false,
    this.synced = false,
  });

  final String id;
  final String title;
  final String category;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final DateTime updatedAt;
  final bool deleted;
  final bool synced;

  bool get isExpense => type == TransactionType.expense;

  FinanceTransaction copyWith({
    String? id,
    String? title,
    String? category,
    double? amount,
    DateTime? date,
    TransactionType? type,
    DateTime? updatedAt,
    bool? deleted,
    bool? synced,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      updatedAt: updatedAt ?? this.updatedAt,
      deleted: deleted ?? this.deleted,
      synced: synced ?? this.synced,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    amount,
    date,
    type,
    updatedAt,
    deleted,
    synced,
  ];
}
