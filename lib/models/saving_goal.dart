/// Model target tabungan
/// Menyimpan nama tujuan, target nominal, nominal terkumpul, dan tenggat.
class SavingGoal {
  final int? id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;

  const SavingGoal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
  });

  /// Persentase progres toward target
  double get progress => targetAmount == 0
      ? 0
      : (savedAmount / targetAmount).clamp(0, 1.0);

  /// Buat salinan dengan perubahan terpilih
  SavingGoal copyWith({
    int? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? deadline,
  }) {
    return SavingGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      deadline: deadline ?? this.deadline,
    );
  }

  /// Konversi ke Map (untuk SQLite/backup JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'saved_amount': savedAmount,
      'deadline': deadline?.millisecondsSinceEpoch,
    };
  }

  /// Buat dari Map (dari SQLite/backup JSON)
  factory SavingGoal.fromMap(Map<String, dynamic> map) {
    return SavingGoal(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      savedAmount: (map['saved_amount'] as num).toDouble(),
      deadline: map['deadline'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int)
          : null,
    );
  }
}