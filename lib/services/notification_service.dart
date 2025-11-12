import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart' show PlatformException;
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

    // Pastikan waktu masa depan untuk menghindari error penjadwalan
    var tzDateTime = tz.TZDateTime.from(r.dueDate, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (tzDateTime.isBefore(now)) {
      // Jika dueDate sudah lewat, jadwalkan beberapa detik ke depan sebagai fallback aman
      tzDateTime = now.add(const Duration(seconds: 5));
    }

    final id = r.id ?? r.dueDate.millisecondsSinceEpoch ~/ 1000;
    final body = (r.amount == null)
        ? 'Jatuh tempo'
        : 'Jatuh tempo: Rp ${r.amount!.toStringAsFixed(0)}';

    try {
      await _plugin.zonedSchedule(
        id,
        r.title,
        body,
        tzDateTime,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'reminder:${r.id ?? ''}',
      );
    } on PlatformException catch (e) {
      // Fallback: perangkat tidak mengizinkan exact alarms atau permission belum diberikan
      final msg = e.message ?? '';
      if (msg.contains('Exact alarms are not permitted') ||
          msg.contains('SCHEDULE_EXACT_ALARM') ||
          msg.contains('exact')) {
        debugPrint('[NotificationService] Exact alarm tidak diizinkan, fallback ke inexact. Error: $msg');
        await _plugin.zonedSchedule(
          id,
          r.title,
          body,
          tzDateTime,
          details,
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          payload: 'reminder:${r.id ?? ''}',
        );
      } else {
        rethrow;
      }
    } catch (e) {
      // Tangani error tak terduga tanpa memblokir aplikasi
      debugPrint('[NotificationService] Gagal menjadwalkan notifikasi: $e');
    }
  }

  /// Batalkan notifikasi dengan id
  Future<void> cancel(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }
}