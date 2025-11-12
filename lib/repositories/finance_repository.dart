import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uas/models/budget.dart';
import 'package:uas/models/reminder.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/services/database/database_service.dart';
import 'package:uas/services/database/database_service_sqflite.dart';
import 'package:uas/services/database/database_service_web.dart';

/// Repository yang menyatukan akses data untuk seluruh entitas.
class FinanceRepository {
  late final DatabaseService _db;

  FinanceRepository() {
    _db = kIsWeb ? DatabaseServiceWeb() : DatabaseServiceSqflite();
  }

  /// Inisialisasi storage/database
  Future<void> init() => _db.init();

  // Transaksi
  Future<int> addTransaction(FinanceTransaction txn) => _db.insertTransaction(txn);
  Future<List<FinanceTransaction>> listTransactions({DateTime? from, DateTime? to}) =>
      _db.getTransactions(from: from, to: to);
  Future<int> updateTransaction(FinanceTransaction txn) => _db.updateTransaction(txn);
  Future<int> deleteTransaction(int id) => _db.deleteTransaction(id);

  // Anggaran
  Future<int> addBudget(Budget budget) => _db.insertBudget(budget);
  Future<List<Budget>> listBudgets() => _db.getBudgets();
  Future<int> updateBudget(Budget budget) => _db.updateBudget(budget);
  Future<int> deleteBudget(int id) => _db.deleteBudget(id);

  // Target tabungan
  Future<int> addSavingGoal(SavingGoal goal) => _db.insertSavingGoal(goal);
  Future<List<SavingGoal>> listSavingGoals() => _db.getSavingGoals();
  Future<int> updateSavingGoal(SavingGoal goal) => _db.updateSavingGoal(goal);
  Future<int> deleteSavingGoal(int id) => _db.deleteSavingGoal(id);

  // Pengingat
  Future<int> addReminder(Reminder reminder) => _db.insertReminder(reminder);
  Future<List<Reminder>> listReminders({bool? onlyUnpaid}) => _db.getReminders(onlyUnpaid: onlyUnpaid);
  Future<int> updateReminder(Reminder reminder) => _db.updateReminder(reminder);
  Future<int> deleteReminder(int id) => _db.deleteReminder(id);
}