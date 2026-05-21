part of 'summary_bloc.dart';

class SummaryState extends Equatable {
  const SummaryState({required this.summary});

  factory SummaryState.initial(double budget) {
    return SummaryState(
      summary: SpendingSummary(
        income: 0,
        expenses: 0,
        budget: budget,
        byDay: List<double>.filled(7, 0),
      ),
    );
  }

  final SpendingSummary summary;

  @override
  List<Object?> get props => [summary];
}
