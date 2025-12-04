import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas/models/monthly_budget.dart';

class BudgetRepository {
  static const _keyBudget = 'monthly_budget';

  /// Mengambil budget bulanan untuk bulan berjalan
  Future<MonthlyBudget?> getCurrentMonthBudget() async {
    final prefs = await SharedPreferences.getInstance();
    final String? budgetJson = prefs.getString(_keyBudget);
    
    if (budgetJson != null) {
      try {
        return MonthlyBudget.fromMap(jsonDecode(budgetJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Menyimpan budget bulanan
  Future<void> setMonthlyBudget(MonthlyBudget budget) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBudget, jsonEncode(budget.toMap()));
  }

  /// Update spent amount berdasarkan transaksi
  Future<void> updateSpentAmount(double amount) async {
    final budget = await getCurrentMonthBudget();
    if (budget != null) {
      final newBudget = budget.copyWith(spentAmount: amount);
      await setMonthlyBudget(newBudget);
    }
  }
}
