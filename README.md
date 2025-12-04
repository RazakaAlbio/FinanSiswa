# FinanSiswa

Aplikasi manajemen finansial sederhana untuk mahasiswa, fokus pada pencatatan transaksi, anggaran, tabungan, serta edukasi keuangan. Mendukung tema dinamis (light/dark/system) dan rekomendasi budget berdasarkan kota.

## Fitur Utama

### 1. Onboarding & Personalisasi
- **Welcome Page**: Halaman sambutan yang ramah untuk pengguna baru.
- **Rekomendasi Budget**: Pilih kota studi (Jakarta, Bandung, Yogyakarta, Surabaya) untuk mendapatkan rekomendasi budget bulanan yang sesuai.
- **Atur Sendiri**: Opsi untuk mengatur nominal budget secara manual.

### 2. Manajemen Keuangan
- **Dashboard**: Ringkasan saldo, pengeluaran bulan ini, dan status budget.
- **Transaksi**: Catat pemasukan dan pengeluaran dengan kategori yang relevan untuk mahasiswa (Makan, Transport, Akademik, dll).
- **Laporan**: Visualisasi pengeluaran dalam bentuk Pie Chart.

### 3. Budgeting
- **Budget Bulanan**: Atur limit pengeluaran per kategori.
- **Budget Preset**: Terapkan template budget berdasarkan kota kapan saja melalui halaman Budget.
- **Tracking**: Pantau realisasi budget dengan progress bar visual.

### 4. Tabungan (Savings)
- **Target Tabungan**: Tetapkan tujuan menabung (misal: Beli Laptop, Liburan).
- **Progress Tracking**: Pantau persentase pencapaian target.
- **Add Funds**: Tambahkan nominal tabungan secara berkala.
- **Deadline**: Set tanggal target tercapai.

### 5. Edukasi (Belajar)
- **Artikel Pilihan**: Kumpulan artikel singkat tentang tips keuangan mahasiswa.
- **Tips Cepat**: Kartu interaktif dengan tips praktis sehari-hari.
- **Detail Artikel**: Bacaan lengkap dengan estimasi waktu baca.

### 6. Fitur Lainnya
- **Tema Dinamis**: Dukungan Light Mode, Dark Mode, dan System Default.
- **Notifikasi**: Pengingat harian untuk mencatat transaksi.
- **Backup & Restore**: Simpan data ke file lokal untuk keamanan.

## Instalasi & Build

### Prasyarat
- Flutter SDK (3.9+)
- Android SDK / Xcode

### Menjalankan Aplikasi (Debug)
```bash
flutter pub get
flutter run
```

### Membuat File APK (Android)
Untuk membuat file instalasi Android (APK):

```bash
flutter build apk --release
```
File APK akan tersedia di: `build/app/outputs/flutter-apk/app-release.apk`

## Struktur Project

- `lib/main.dart`: Entry point dan konfigurasi tema/route.
- `lib/pages/`: Berisi halaman-halaman UI (Welcome, Dashboard, Budget, Belajar, dll).
- `lib/models/`: Model data (Transaction, Budget, Article, dll).
- `lib/repositories/`: Logika penyimpanan data (SQLite/SharedPrefs).
- `lib/services/`: Service pendukung (Preferences, Notification).
- `lib/theme/`: Konfigurasi tema aplikasi.

## Dependencies Utama

- `provider`: State management.
- `fl_chart`: Visualisasi grafik.
- `shared_preferences`: Penyimpanan setting sederhana.
- `sqflite`: Database lokal untuk transaksi.
- `flutter_markdown`: Rendering artikel.
- `google_fonts`: Tipografi (Poppins).
- `flutter_local_notifications`: Sistem notifikasi.

## Catatan Rilis (Terbaru)

- **[FIX]** Mengatasi crash `LateInitializationError` pada startup.
- **[FIX]** Memperbaiki tombol dan kartu yang tidak responsif di halaman Welcome dan Budget.
- **[NEW]** Menambahkan halaman Edukasi Keuangan.
- **[NEW]** Implementasi fitur Budget Preset berdasarkan kota.
