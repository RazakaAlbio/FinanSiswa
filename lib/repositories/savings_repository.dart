import 'package:uas/models/saving_goal.dart';

class SavingsRepository {
  /// Mengambil semua target tabungan
  Future<List<SavingGoal>> getSavingsTargets() async {
    // Implementasi untuk mengambil data target tabungan dari database
    // Untuk sementara return dummy data sesuai prototype
    return [
      SavingGoal(
        id: 1,
        name: 'Trip ke Bali',
        targetAmount: 10000000, // Rp 10.000.000
        savedAmount: 0, // Rp 0
        deadline: DateTime.now().add(const Duration(days: 90)),
      ),
    ];
  }

  /// Menambah target tabungan baru
  Future<void> addSavingsTarget(SavingGoal target) async {
    // Implementasi untuk menambah target tabungan ke database
  }

  /// Update jumlah yang sudah terkumpul
  Future<void> updateSavedAmount(int goalId, double amount) async {
    // Implementasi untuk update nominal terkumpul
  }

  /// Hapus target tabungan
  Future<void> deleteSavingsTarget(int goalId) async {
    // Implementasi untuk menghapus target tabungan
  }
}
