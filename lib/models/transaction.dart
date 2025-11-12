import 'package:flutter/foundation.dart';

/// Jenis transaksi: pemasukan atau pengeluaran
enum TransactionType { income, expense }

/// Model transaksi keuangan mahasiswa
/// Menyimpan jumlah, kategori, tipe (income/expense), tanggal, dan catatan.
class FinanceTransaction {
  final int? id;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime date;
  final String? note;

  const FinanceTransaction({
    this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.note,
  });

  /// Buat salinan dengan perubahan terpilih
  FinanceTransaction copyWith({
    int? id,
    double? amount,
    String? category,
    TransactionType? type,
    DateTime? date,
    String? note,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }

  /// Konversi ke Map (untuk SQLite/backup JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'type': describeEnum(type),
      'date': date.millisecondsSinceEpoch,
      'note': note,
    };
  }

  /// Buat dari Map (dari SQLite/backup JSON)
  factory FinanceTransaction.fromMap(Map<String, dynamic> map) {
    return FinanceTransaction(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      type: (map['type'] as String) == 'income'
          ? TransactionType.income
          : TransactionType.expense,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
    );
  }
}