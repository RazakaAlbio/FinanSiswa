# FinanSiswa

Aplikasi manajemen finansial sederhana untuk mahasiswa, fokus pada pencatatan transaksi, anggaran, tabungan, serta pengingat jatuh tempo. Mendukung tema dinamis (light/dark/system) dan backup/restore data.

## Deskripsi & Fitur

- Manajemen transaksi harian dengan kategori dan jumlah.
- Anggaran per kategori beserta progress realisasi.
- Tabungan: target, progress, dan riwayat top-up.
- Pengingat jatuh tempo dengan notifikasi lokal (Android/iOS). Fallback inexact alarm jika exact alarms tidak diizinkan.
- Dashboard interaktif menggunakan `fl_chart` (bar & line chart).
- Pengaturan: mata uang, tema (light/dark/system), backup & restore.
- Lokalization `id_ID` dan `en_US`.

## Instalasi & Setup

- Prasyarat: terpasang `Flutter` (3.9+) dan SDK platform (Android/iOS/Web).
- Perintah dasar:
  - `flutter pub get` untuk mengambil dependencies.
  - `flutter run` untuk menjalankan aplikasi di emulator/perangkat.
  - `flutter test` untuk menjalankan pengujian widget.
- Android: pastikan Android SDK & emulator/USB debugging siap.
- Web: jalankan `flutter run -d web-server` dan buka URL yang diberikan.

## Dependencies (Pubspec)

- `flutter_local_notifications: ^17.2.3` — notifikasi lokal lintas platform.
- `shared_preferences: ^2.2.3` — penyimpanan preferensi ringan.
- `sqflite: ^2.3.3` — database SQLite di Android/iOS.
- `path_provider: ^2.1.3`, `path: ^1.9.0` — utilitas path.
- `intl: ^0.20.2` — format angka/tanggal.
- `fl_chart: ^0.69.0` — chart UI.
- `provider: ^6.1.2` — state management.
- `google_fonts: ^6.2.1` — font Poppins.
- Dev: `flutter_test`, `flutter_lints: ^5.0.0`.

## Struktur Direktori

- `lib/main.dart` — bootstrap aplikasi, provider, dan shell navigasi.
- `lib/pages/` — halaman utama (`dashboard_page.dart`, `transactions_page.dart`, `budgets_page.dart`, `savings_page.dart`, `reminders_page.dart`, `settings_page.dart`).
- `lib/repositories/` — akses data (`FinanceRepository`).
- `lib/services/` — layanan utilitas (`preferences_service.dart`, `notification_service.dart`, `backup_service.dart`).
- `lib/theme/` — tema M3 kustom (`app_theme.dart`).
- `test/` — pengujian widget (smoke test, `show_date_picker_test.dart`).
- `android/`, `ios/`, `web/`, `macos/`, `linux/` — aset & konfigurasi platform.

## Detail Implementasi Penting

- Tema Dinamis:
  - `PreferencesService` sekarang `ChangeNotifier` dan memanggil `notifyListeners()` saat `setTheme`.
  - `MaterialApp` menggunakan `theme`, `darkTheme`, dan `themeMode` (light/dark/system) yang membaca `PreferencesService` melalui `Consumer`.
  - `SettingsPage` menambahkan opsi tema `system` dan memperbarui preferensi secara langsung.
- Pengingat & Exact Alarms:
  - `AndroidManifest.xml` menambahkan permission `android.permission.SCHEDULE_EXACT_ALARM`.
  - `NotificationService.scheduleReminderNotification` memakai `try/catch` dan fallback ke `AndroidScheduleMode.inexact` jika exact alarms tidak diizinkan.
  - Penyesuaian jadwal jika `dueDate` lampau (menjadwalkan beberapa detik ke depan sebagai proteksi).

## Pengujian

- Widget test: jalankan `flutter test`. Meliputi smoke test dan `showDatePicker` pada berbagai kondisi layar.
- Manual:
  - Uji tema pada Settings: pilih `Light`, `Dark`, dan `System` lalu verifikasi konsistensi di setiap halaman.
  - Android 12/13+: uji pengingat. Jika muncul error "Exact alarms are not permitted", konfirmasi fallback berjalan (notifikasi tetap terjadwal).

## Kontribusi

- Gunakan branching feature (`feat/…`) dan buat PR dengan deskripsi jelas.
- Ikuti gaya kode yang konsisten (Material 3, Provider, lints aktif).
- Tambahkan pengujian untuk fitur baru bila memungkinkan.
- Diskusikan perubahan yang memengaruhi arsitektur sebelum implementasi.

### Code of Conduct

- Berkomunikasi dengan hormat, inklusif, dan kolaboratif.
- Hindari perilaku ofensif, diskriminatif, atau mengganggu.
- Terima masukan teknis dan berikan umpan balik secara konstruktif.

## Lisensi

- Lisensi: MIT. Anda bebas menggunakan, memodifikasi, dan mendistribusikan dengan mencantumkan atribusi.
