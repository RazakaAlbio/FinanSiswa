import 'package:flutter/foundation.dart';

/// Interval pengulangan pengingat
enum ReminderRepeat { none, daily, weekly, monthly }

/// Model pengingat pembayaran/tagihan
class Reminder {
  final int? id;
  final String title;
  final double? amount;
  final DateTime dueDate;
  final bool isPaid;
  final ReminderRepeat repeat;

  const Reminder({
    this.id,
    required this.title,
    this.amount,
    required this.dueDate,
    this.isPaid = false,
    this.repeat = ReminderRepeat.none,
  });

  /// Buat salinan dengan perubahan terpilih
  Reminder copyWith({
    int? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    ReminderRepeat? repeat,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      repeat: repeat ?? this.repeat,
    );
  }

  /// Konversi ke Map (untuk SQLite/backup JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'due_date': dueDate.millisecondsSinceEpoch,
      'is_paid': isPaid ? 1 : 0,
      'repeat': describeEnum(repeat),
    };
  }

  /// Buat dari Map (dari SQLite/backup JSON)
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: map['amount'] == null ? null : (map['amount'] as num).toDouble(),
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int),
      isPaid: (map['is_paid'] as int) == 1,
      repeat: ReminderRepeat.values.firstWhere(
        (r) => describeEnum(r) == (map['repeat'] as String? ?? 'none'),
        orElse: () => ReminderRepeat.none,
      ),
    );
  }
}