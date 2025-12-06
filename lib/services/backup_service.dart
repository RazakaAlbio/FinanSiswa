import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uas/models/budget.dart';
import 'package:uas/models/reminder.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/repositories/finance_repository.dart';

/// Layanan backup/restore sederhana menggunakan file JSON lokal.
class BackupService {
  static const String defaultFileName = 'finansiswa_backup.json';

  /// Ekspor data dari repository menjadi JSON string
  Future<String> exportBackupJson(FinanceRepository repo) async {
    final txns = await repo.listTransactions();
    final budgets = await repo.listBudgets();
    final goals = await repo.listSavingGoals();
    final reminders = await repo.listReminders();

    final payload = {
      'version': 1,
      'transactions': txns.map((e) => e.toMap()).toList(),
      'budgets': budgets.map((e) => e.toMap()).toList(),
      'saving_goals': goals.map((e) => e.toMap()).toList(),
      'reminders': reminders.map((e) => e.toMap()).toList(),
      'generated_at': DateTime.now().toIso8601String(),
    };
    return jsonEncode(payload);
  }

  /// Simpan JSON backup ke file (User memilih lokasi)
  Future<String?> saveBackupToFile(String jsonContent, {String? fileName}) async {
    if (kIsWeb) {
      return 'web://inline';
    }
    
    // Encode content to bytes
    final bytes = Uint8List.fromList(utf8.encode(jsonContent));
    
    // Gunakan FilePicker untuk menyimpan file
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Simpan Backup',
      fileName: fileName ?? defaultFileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: bytes, // Required for Android/iOS
    );

    if (outputFile == null) {
      return null;
    }

    // On non-mobile platforms, we might still need to write the file manually if saveFile just returns the path.
    // On Android/iOS, providing 'bytes' lets the plugin handle the writing.
    // We can check if the file exists or just write it again to be safe for Desktop.
    // However, writing to the path returned by Android SAF might not work with File API directly if it's a URI.
    // Since we passed bytes, we assume it's written on Android/iOS.
    if (!Platform.isAndroid && !Platform.isIOS) {
       final file = File(outputFile);
       await file.writeAsString(jsonContent, flush: true);
    }
    
    return outputFile;
  }

  /// Baca file backup JSON dari Documents directory
  Future<Map<String, dynamic>> readBackupFromFile({String? fileName}) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, fileName ?? defaultFileName);
    final file = File(path);
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  /// Restore data ke repository dari payload backup
  Future<void> restoreFromPayload(FinanceRepository repo, Map<String, dynamic> payload) async {
    // Hapus data lama secara sederhana: load lalu delete.
    final oldTxns = await repo.listTransactions();
    for (final t in oldTxns) {
      if (t.id != null) await repo.deleteTransaction(t.id!);
    }
    final oldBudgets = await repo.listBudgets();
    for (final b in oldBudgets) {
      if (b.id != null) await repo.deleteBudget(b.id!);
    }
    final oldGoals = await repo.listSavingGoals();
    for (final g in oldGoals) {
      if (g.id != null) await repo.deleteSavingGoal(g.id!);
    }
    final oldRem = await repo.listReminders();
    for (final r in oldRem) {
      if (r.id != null) await repo.deleteReminder(r.id!);
    }

    // Tambahkan data baru
    final txns = (payload['transactions'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (final m in txns) {
      final t = FinanceTransaction.fromMap(m);
      await repo.addTransaction(t.copyWith(id: null));
    }

    final budgets = (payload['budgets'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (final m in budgets) {
      final b = Budget.fromMap(m);
      await repo.addBudget(b.copyWith(id: null));
    }

    final goals = (payload['saving_goals'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (final m in goals) {
      final g = SavingGoal.fromMap(m);
      await repo.addSavingGoal(g.copyWith(id: null));
    }

    final reminders = (payload['reminders'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    for (final m in reminders) {
      final r = Reminder.fromMap(m);
      await repo.addReminder(r.copyWith(id: null));
    }
  }
}