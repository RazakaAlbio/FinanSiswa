import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uas/models/budget.dart';
import 'package:uas/models/reminder.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/services/database/database_service.dart';

/// Implementasi DatabaseService menggunakan SQLite (sqflite) untuk mobile/desktop.
class DatabaseServiceSqflite implements DatabaseService {
  static const _dbName = 'finansiswa.db';
  static const _dbVersion = 1;

  Database? _db;

  @override
  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE transactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          type TEXT NOT NULL,
          date INTEGER NOT NULL,
          note TEXT
        );
        ''');

        await db.execute('''
        CREATE TABLE budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          amount REAL NOT NULL,
          period TEXT NOT NULL,
          start_date INTEGER NOT NULL,
          end_date INTEGER
        );
        ''');

        await db.execute('''
        CREATE TABLE saving_goals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          target_amount REAL NOT NULL,
          saved_amount REAL NOT NULL,
          deadline INTEGER
        );
        ''');

        await db.execute('''
        CREATE TABLE reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          amount REAL,
          due_date INTEGER NOT NULL,
          is_paid INTEGER NOT NULL,
          repeat TEXT NOT NULL
        );
        ''');
      },
    );
  }

  Database get _database => _db!;

  // Transaksi
  @override
  Future<int> insertTransaction(FinanceTransaction txn) async {
    return _database.insert('transactions', txn.toMap());
  }

  @override
  Future<List<FinanceTransaction>> getTransactions({DateTime? from, DateTime? to}) async {
    String where = '';
    List<Object?> whereArgs = [];
    if (from != null) {
      where += (where.isEmpty ? '' : ' AND ') + 'date >= ?';
      whereArgs.add(from.millisecondsSinceEpoch);
    }
    if (to != null) {
      where += (where.isEmpty ? '' : ' AND ') + 'date <= ?';
      whereArgs.add(to.millisecondsSinceEpoch);
    }
    final rows = await _database.query('transactions', where: where.isEmpty ? null : where, whereArgs: whereArgs, orderBy: 'date DESC');
    return rows.map(FinanceTransaction.fromMap).toList();
  }

  @override
  Future<int> updateTransaction(FinanceTransaction txn) async {
    return _database.update('transactions', txn.toMap(), where: 'id = ?', whereArgs: [txn.id]);
  }

  @override
  Future<int> deleteTransaction(int id) async {
    return _database.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // Anggaran
  @override
  Future<int> insertBudget(Budget budget) async {
    return _database.insert('budgets', budget.toMap());
  }

  @override
  Future<List<Budget>> getBudgets() async {
    final rows = await _database.query('budgets', orderBy: 'start_date DESC');
    return rows.map(Budget.fromMap).toList();
  }

  @override
  Future<int> updateBudget(Budget budget) async {
    return _database.update('budgets', budget.toMap(), where: 'id = ?', whereArgs: [budget.id]);
  }

  @override
  Future<int> deleteBudget(int id) async {
    return _database.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  // Target tabungan
  @override
  Future<int> insertSavingGoal(SavingGoal goal) async {
    return _database.insert('saving_goals', goal.toMap());
  }

  @override
  Future<List<SavingGoal>> getSavingGoals() async {
    final rows = await _database.query('saving_goals', orderBy: 'id DESC');
    return rows.map(SavingGoal.fromMap).toList();
  }

  @override
  Future<int> updateSavingGoal(SavingGoal goal) async {
    return _database.update('saving_goals', goal.toMap(), where: 'id = ?', whereArgs: [goal.id]);
  }

  @override
  Future<int> deleteSavingGoal(int id) async {
    return _database.delete('saving_goals', where: 'id = ?', whereArgs: [id]);
  }

  // Pengingat
  @override
  Future<int> insertReminder(Reminder reminder) async {
    return _database.insert('reminders', reminder.toMap());
  }

  @override
  Future<List<Reminder>> getReminders({bool? onlyUnpaid}) async {
    String? where;
    List<Object?>? whereArgs;
    if (onlyUnpaid == true) {
      where = 'is_paid = ?';
      whereArgs = [0];
    }
    final rows = await _database.query('reminders', where: where, whereArgs: whereArgs, orderBy: 'due_date ASC');
    return rows.map(Reminder.fromMap).toList();
  }

  @override
  Future<int> updateReminder(Reminder reminder) async {
    return _database.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  @override
  Future<int> deleteReminder(int id) async {
    return _database.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}