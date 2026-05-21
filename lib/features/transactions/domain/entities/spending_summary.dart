import 'package:equatable/equatable.dart';

class SpendingSummary extends Equatable {
  const SpendingSummary({
    required this.income,
    required this.expenses,
    required this.budget,
    required this.byDay,
  });

  final double income;
  final double expenses;
  final double budget;
  final List<double> byDay;

  double get balance => income - expenses;

  double get budgetProgress {
    if (budget <= 0) {
      return 0;
    }
    return (expenses / budget).clamp(0, 1).toDouble();
  }

  @override
  List<Object?> get props => [income, expenses, budget, byDay];
}
