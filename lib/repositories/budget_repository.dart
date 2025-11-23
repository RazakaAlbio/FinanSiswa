import 'package:uas/models/monthly_budget.dart';

class BudgetRepository {
  /// Mengambil budget bulanan untuk bulan berjalan
  Future<MonthlyBudget?> getCurrentMonthBudget() async {
    // Untuk sementara return dummy data
    // Nanti bisa diintegrasikan dengan database
    return MonthlyBudget(
      id: 'current',
      amount: 5000000, // Rp 5.000.000
      month: DateTime.now().month,
      year: DateTime.now().year,
      spentAmount: 0, // Akan dihitung dari transaksi
    );
  }

  /// Menyimpan budget bulanan
  Future<void> setMonthlyBudget(MonthlyBudget budget) async {
    // Implementasi untuk menyimpan budget ke database
    // Untuk sementara hanya simpan di memory
  }

  /// Update spent amount berdasarkan transaksi
  Future<void> updateSpentAmount(double amount) async {
    // Implementasi untuk update pengeluaran
  }
}
