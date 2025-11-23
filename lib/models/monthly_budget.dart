/// Model untuk Budget Bulanan di Dashboard
class MonthlyBudget {
  final String id;
  final double amount;
  final int month;
  final int year;
  final double spentAmount;

  MonthlyBudget({
    required this.id,
    required this.amount,
    required this.month,
    required this.year,
    required this.spentAmount,
  });

  double get remaining => amount - spentAmount;
  double get percentage => amount > 0 ? (spentAmount / amount) * 100 : 0;

  /// Buat salinan dengan perubahan terpilih
  MonthlyBudget copyWith({
    String? id,
    double? amount,
    int? month,
    int? year,
    double? spentAmount,
  }) {
    return MonthlyBudget(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      month: month ?? this.month,
      year: year ?? this.year,
      spentAmount: spentAmount ?? this.spentAmount,
    );
  }

  /// Konversi ke Map (untuk penyimpanan)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'month': month,
      'year': year,
      'spent_amount': spentAmount,
    };
  }

  /// Buat dari Map (dari penyimpanan)
  factory MonthlyBudget.fromMap(Map<String, dynamic> map) {
    return MonthlyBudget(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
      spentAmount: (map['spent_amount'] as num).toDouble(),
    );
  }
}
