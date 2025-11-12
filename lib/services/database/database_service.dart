import 'dart:async';

import 'package:uas/models/budget.dart';
import 'package:uas/models/reminder.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/models/transaction.dart';

/// Abstraksi layanan database untuk FinanSiswa.
/// Implementasi mobile menggunakan SQLite (sqflite),
/// dan fallback web menggunakan SharedPreferences sebagai penyimpanan JSON.
abstract class DatabaseService {
  /// Inisialisasi database (membuka koneksi / memuat storage)
  Future<void> init();

  // Transaksi
  Future<int> insertTransaction(FinanceTransaction txn);
  Future<List<FinanceTransaction>> getTransactions({DateTime? from, DateTime? to});
  Future<int> updateTransaction(FinanceTransaction txn);
  Future<int> deleteTransaction(int id);

  // Anggaran
  Future<int> insertBudget(Budget budget);
  Future<List<Budget>> getBudgets();
  Future<int> updateBudget(Budget budget);
  Future<int> deleteBudget(int id);

  // Target tabungan
  Future<int> insertSavingGoal(SavingGoal goal);
  Future<List<SavingGoal>> getSavingGoals();
  Future<int> updateSavingGoal(SavingGoal goal);
  Future<int> deleteSavingGoal(int id);

  // Pengingat
  Future<int> insertReminder(Reminder reminder);
  Future<List<Reminder>> getReminders({bool? onlyUnpaid});
  Future<int> updateReminder(Reminder reminder);
  Future<int> deleteReminder(int id);
}