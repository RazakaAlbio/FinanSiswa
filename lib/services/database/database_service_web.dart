import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uas/models/budget.dart';
import 'package:uas/models/reminder.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/services/database/database_service.dart';

/// Fallback web: menyimpan data ke SharedPreferences sebagai JSON.
/// Catatan: Ini hanya untuk preview web; pada mobile gunakan SQLite.
class DatabaseServiceWeb implements DatabaseService {
  static const _key = 'finansiswa_db_json';
  late SharedPreferences _prefs;

  Map<String, dynamic> _store = {
    'transactions': <Map<String, dynamic>>[],
    'budgets': <Map<String, dynamic>>[],
    'saving_goals': <Map<String, dynamic>>[],
    'reminders': <Map<String, dynamic>>[],
    '_seq': 0,
  };

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs.getString(_key);
    if (raw != null) {
      _store = jsonDecode(raw) as Map<String, dynamic>;
    }
  }

  Future<void> _persist() async {
    await _prefs.setString(_key, jsonEncode(_store));
  }

  int _nextId() {
    final next = ((_store['_seq'] as int?) ?? 0) + 1;
    _store['_seq'] = next;
    return next;
  }

  // Transaksi
  @override
  Future<int> insertTransaction(FinanceTransaction txn) async {
    final map = txn.copyWith(id: _nextId()).toMap();
    final list = (_store['transactions'] as List).cast<Map<String, dynamic>>();
    list.add(map);
    await _persist();
    return map['id'] as int;
  }

  @override
  Future<List<FinanceTransaction>> getTransactions({DateTime? from, DateTime? to}) async {
    final list = (_store['transactions'] as List).cast<Map<String, dynamic>>();
    Iterable<Map<String, dynamic>> data = list;
    if (from != null) {
      data = data.where((m) => (m['date'] as int) >= from.millisecondsSinceEpoch);
    }
    if (to != null) {
      data = data.where((m) => (m['date'] as int) <= to.millisecondsSinceEpoch);
    }
    final sorted = data.toList()
      ..sort((a, b) => (b['date'] as int).compareTo(a['date'] as int));
    return sorted.map(FinanceTransaction.fromMap).toList();
  }

  @override
  Future<int> updateTransaction(FinanceTransaction txn) async {
    final list = (_store['transactions'] as List).cast<Map<String, dynamic>>();
    final idx = list.indexWhere((m) => m['id'] == txn.id);
    if (idx >= 0) {
      list[idx] = txn.toMap();
      await _persist();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteTransaction(int id) async {
    final list = (_store['transactions'] as List).cast<Map<String, dynamic>>();
    final originalLen = list.length;
    list.removeWhere((m) => m['id'] == id);
    await _persist();
    return originalLen - list.length;
  }

  // Anggaran
  @override
  Future<int> insertBudget(Budget budget) async {
    final map = budget.copyWith(id: _nextId()).toMap();
    final list = (_store['budgets'] as List).cast<Map<String, dynamic>>();
    list.add(map);
    await _persist();
    return map['id'] as int;
  }

  @override
  Future<List<Budget>> getBudgets() async {
    final list = (_store['budgets'] as List).cast<Map<String, dynamic>>();
    final sorted = list.toList()
      ..sort((a, b) => (b['start_date'] as int).compareTo(a['start_date'] as int));
    return sorted.map(Budget.fromMap).toList();
  }

  @override
  Future<int> updateBudget(Budget budget) async {
    final list = (_store['budgets'] as List).cast<Map<String, dynamic>>();
    final idx = list.indexWhere((m) => m['id'] == budget.id);
    if (idx >= 0) {
      list[idx] = budget.toMap();
      await _persist();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteBudget(int id) async {
    final list = (_store['budgets'] as List).cast<Map<String, dynamic>>();
    final originalLen = list.length;
    list.removeWhere((m) => m['id'] == id);
    await _persist();
    return originalLen - list.length;
  }

  // Target tabungan
  @override
  Future<int> insertSavingGoal(SavingGoal goal) async {
    final map = goal.copyWith(id: _nextId()).toMap();
    final list = (_store['saving_goals'] as List).cast<Map<String, dynamic>>();
    list.add(map);
    await _persist();
    return map['id'] as int;
  }

  @override
  Future<List<SavingGoal>> getSavingGoals() async {
    final list = (_store['saving_goals'] as List).cast<Map<String, dynamic>>();
    return list.map(SavingGoal.fromMap).toList();
  }

  @override
  Future<int> updateSavingGoal(SavingGoal goal) async {
    final list = (_store['saving_goals'] as List).cast<Map<String, dynamic>>();
    final idx = list.indexWhere((m) => m['id'] == goal.id);
    if (idx >= 0) {
      list[idx] = goal.toMap();
      await _persist();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteSavingGoal(int id) async {
    final list = (_store['saving_goals'] as List).cast<Map<String, dynamic>>();
    final originalLen = list.length;
    list.removeWhere((m) => m['id'] == id);
    await _persist();
    return originalLen - list.length;
  }

  // Pengingat
  @override
  Future<int> insertReminder(Reminder reminder) async {
    final map = reminder.copyWith(id: _nextId()).toMap();
    final list = (_store['reminders'] as List).cast<Map<String, dynamic>>();
    list.add(map);
    await _persist();
    return map['id'] as int;
  }

  @override
  Future<List<Reminder>> getReminders({bool? onlyUnpaid}) async {
    final list = (_store['reminders'] as List).cast<Map<String, dynamic>>();
    Iterable<Map<String, dynamic>> data = list;
    if (onlyUnpaid == true) {
      data = data.where((m) => (m['is_paid'] as int) == 0);
    }
    final sorted = data.toList()
      ..sort((a, b) => (a['due_date'] as int).compareTo(b['due_date'] as int));
    return sorted.map(Reminder.fromMap).toList();
  }

  @override
  Future<int> updateReminder(Reminder reminder) async {
    final list = (_store['reminders'] as List).cast<Map<String, dynamic>>();
    final idx = list.indexWhere((m) => m['id'] == reminder.id);
    if (idx >= 0) {
      list[idx] = reminder.toMap();
      await _persist();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteReminder(int id) async {
    final list = (_store['reminders'] as List).cast<Map<String, dynamic>>();
    final originalLen = list.length;
    list.removeWhere((m) => m['id'] == id);
    await _persist();
    return originalLen - list.length;
  }
}