import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:uas/models/reminder.dart';

/// Layanan notifikasi lokal untuk pengingat.
/// Pada web, fungsi ini menjadi no-op agar aplikasi tetap berjalan.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  /// Inisialisasi notifikasi lokal (Android/iOS/macOS). Web: no-op.
  Future<void> init() async {
    if (kIsWeb) return; // Tidak didukung di web

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: darwinInit, macOS: darwinInit);
    await _plugin.initialize(initSettings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);
  }

  /// Jadwalkan notifikasi untuk pengingat tertentu.
  Future<void> scheduleReminderNotification(Reminder r) async {
    if (kIsWeb) return;
    final androidDetails = const AndroidNotificationDetails(
      'finansiswa_reminders',
      'Pengingat Pembayaran',
      channelDescription: 'Notifikasi pengingat pembayaran/tagihan FinanSiswa',
      importance: Importance.max,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    final details = NotificationDetails(android: androidDetails, iOS: darwinDetails, macOS: darwinDetails);

    final tzDateTime = tz.TZDateTime.from(r.dueDate, tz.local);
    await _plugin.zonedSchedule(
      r.id ?? r.dueDate.millisecondsSinceEpoch ~/ 1000,
      r.title,
      (r.amount == null) ? 'Jatuh tempo' : 'Jatuh tempo: Rp ${r.amount!.toStringAsFixed(0)}',
      tzDateTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'reminder:${r.id ?? ''}',
    );
  }

  /// Batalkan notifikasi dengan id
  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }
}