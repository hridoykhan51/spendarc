import 'package:finance_app/features/transactions/domain/entities/transaction.dart';

class TransactionModel extends FinanceTransaction {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.category,
    required super.amount,
    required super.date,
    required super.type,
    required super.updatedAt,
    super.deleted,
    super.synced,
  });

  factory TransactionModel.fromEntity(FinanceTransaction transaction) {
    return TransactionModel(
      id: transaction.id,
      title: transaction.title,
      category: transaction.category,
      amount: transaction.amount,
      date: transaction.date,
      type: transaction.type,
      updatedAt: transaction.updatedAt,
      deleted: transaction.deleted,
      synced: transaction.synced,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      type: TransactionType.values.byName(json['type'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deleted: json['deleted'] as bool? ?? false,
      synced: json['synced'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      'updatedAt': updatedAt.toIso8601String(),
      'deleted': deleted,
      'synced': synced,
    };
  }

  @override
  TransactionModel copyWith({
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
    return TransactionModel(
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
}
