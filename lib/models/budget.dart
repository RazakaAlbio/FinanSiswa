import 'package:flutter/foundation.dart';

/// Periode anggaran yang didukung
enum BudgetPeriod { daily, weekly, monthly }

/// Model anggaran mahasiswa
/// Menyimpan nama anggaran, jumlah, periode, tanggal mulai & akhir.
class Budget {
  final int? id;
  final String name;
  final double amount;
  final BudgetPeriod period;
  final DateTime startDate;
  final DateTime? endDate;

  const Budget({
    this.id,
    required this.name,
    required this.amount,
    required this.period,
    required this.startDate,
    this.endDate,
  });

  /// Buat salinan dengan perubahan terpilih
  Budget copyWith({
    int? id,
    String? name,
    double? amount,
    BudgetPeriod? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  /// Konversi ke Map (untuk SQLite/backup JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'period': describeEnum(period),
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
    };
  }

  /// Buat dari Map (dari SQLite/backup JSON)
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (p) => describeEnum(p) == (map['period'] as String),
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date'] as int),
      endDate: map['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['end_date'] as int)
          : null,
    );
  }
}