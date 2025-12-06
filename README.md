# FinanSiswa

Aplikasi manajemen finansial sederhana untuk mahasiswa, fokus pada pencatatan transaksi, anggaran, tabungan, serta edukasi keuangan. Mendukung tema dinamis (light/dark/system) dan rekomendasi budget berdasarkan kota.

## Fitur Utama

### 1. Onboarding & Personalisasi
- **Welcome Page**: Halaman sambutan yang ramah untuk pengguna baru.
- **Rekomendasi Budget**: Pilih kota studi (Jakarta, Bandung, Yogyakarta, Surabaya) untuk mendapatkan rekomendasi budget bulanan yang sesuai.
- **Atur Sendiri**: Opsi untuk mengatur nominal budget secara manual.

### 2. Manajemen Keuangan
- **Dashboard**: 
  - Ringkasan saldo (Pemasukan - Pengeluaran).
  - Kartu ringkasan Pemasukan dan Pengeluaran.
  - Progress Budget Bulanan dan Budget per Kategori.
  - Daftar Target Tabungan dengan progress bar.
- **Transaksi**: 
  - Catat pemasukan dan pengeluaran.
  - Kategori yang relevan untuk mahasiswa (Makan, Transport, Akademik, dll).
  - Filter dan riwayat transaksi.
- **Laporan**: Visualisasi pengeluaran dalam bentuk Pie Chart (di halaman Transaksi/Laporan).

### 3. Budgeting
- **Budget Bulanan**: Atur limit pengeluaran total per bulan.
- **Budget Kategori**: Atur limit khusus untuk kategori tertentu (misal: Makanan, Transport).
- **Budget Preset**: Terapkan template budget berdasarkan kota kapan saja melalui halaman Budget.
- **Tracking**: Pantau realisasi budget dengan progress bar visual (Merah jika > 80%).

### 4. Tabungan (Savings)
- **Target Tabungan**: Tetapkan tujuan menabung (misal: Beli Laptop, Liburan).
- **Progress Tracking**: Pantau persentase pencapaian target, nominal terkumpul, dan sisa yang dibutuhkan.
- **Deadline**: Set tanggal target tercapai.
- **Integrasi Transaksi**: Menambah tabungan dilakukan melalui pencatatan transaksi tipe 'Tabungan'.

### 5. Edukasi (Belajar)
- **Artikel Pilihan**: Kumpulan artikel singkat tentang tips keuangan mahasiswa.
- **Tips Cepat**: Kartu interaktif dengan tips praktis sehari-hari.
- **Detail Artikel**: Bacaan lengkap dengan estimasi waktu baca.

### 6. Pengaturan & Keamanan
- **Backup & Restore**: 
  - Ekspor data ke file JSON (disimpan di lokasi pilihan pengguna).
  - Restore data dari file JSON.
- **Notifikasi**: Pengingat harian untuk mencatat transaksi.

---

## Arsitektur & Logika

Aplikasi ini dibangun menggunakan Flutter dengan arsitektur MVVM-like sederhana menggunakan `Provider` untuk state management.

### Struktur Folder
- `lib/main.dart`: Entry point, inisialisasi service, dan routing.
- `lib/pages/`: UI Screen (Dashboard, TransactionForm, Savings, dll).
- `lib/models/`: Data class (Transaction, Budget, SavingGoal, Reminder).
- `lib/repositories/`: Abstraksi akses data (`FinanceRepository`).
- `lib/services/`: 
  - `database/`: Implementasi SQLite (`DatabaseServiceSqflite`).
  - `BackupService`: Logika ekspor/impor JSON.
  - `NotificationService`: Local notifications.

### Skema Database (SQLite)
Aplikasi menggunakan `sqflite` dengan tabel-tabel berikut:

#### 1. `transactions`
Menyimpan riwayat pemasukan dan pengeluaran.
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | INTEGER PK | ID Unik |
| `amount` | REAL | Nominal transaksi |
| `category` | TEXT | Kategori (Makan, Transport, dll) |
| `type` | TEXT | 'income' atau 'expense' |
| `date` | INTEGER | Timestamp (millisecondsSinceEpoch) |
| `note` | TEXT | Catatan tambahan |

#### 2. `budgets`
Menyimpan anggaran per kategori atau bulanan.
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | INTEGER PK | ID Unik |
| `name` | TEXT | Nama budget (misal: Bulanan, Makanan) |
| `amount` | REAL | Limit anggaran |
| `period` | TEXT | Periode (misal: 'monthly') |
| `start_date` | INTEGER | Tanggal mulai |
| `end_date` | INTEGER | Tanggal berakhir |

#### 3. `saving_goals`
Menyimpan target tabungan.
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | INTEGER PK | ID Unik |
| `name` | TEXT | Nama tujuan |
| `target_amount` | REAL | Target nominal |
| `saved_amount` | REAL | Nominal terkumpul saat ini |
| `deadline` | INTEGER | Tanggal target (opsional) |

#### 4. `reminders`
Menyimpan pengingat tagihan atau jadwal menabung.
| Kolom | Tipe | Deskripsi |
|-------|------|-----------|
| `id` | INTEGER PK | ID Unik |
| `title` | TEXT | Judul pengingat |
| `amount` | REAL | Nominal tagihan (opsional) |
| `due_date` | INTEGER | Tanggal jatuh tempo |
| `is_paid` | INTEGER | Status bayar (0/1) |
| `repeat` | TEXT | Pola ulang (misal: 'monthly') |

---

## Instalasi & Build

### Prasyarat
- Flutter SDK (3.10+)
- Android SDK / Xcode

### Menjalankan Aplikasi (Debug)
```bash
flutter pub get
flutter run
```

### Troubleshooting
Jika mengalami crash saat startup atau error build:
1. Jalankan `flutter clean`
2. Jalankan `flutter pub get`
3. Jalankan `flutter run`

---

## Catatan Perubahan (Changelog)

### Terbaru
- **[FIX] Dashboard Integration**: Menyelaraskan tampilan kartu target tabungan di Dashboard dengan halaman Savings (padding, layout, data).
- **[FIX] Backup Service**: Memperbaiki error "Bytes required" pada Android saat menyimpan file backup. Menggunakan `FilePicker` untuk memilih lokasi simpan.
- **[FIX] Syntax & Build**: Memperbaiki syntax error di `SavingsPage` dan upgrade `file_picker` ke versi 8.x untuk kompatibilitas Android embedding v2.
- **[UPDATE] UI Refinement**: 
  - Menghapus tombol "Add Funds" dari kartu tabungan.
  - Menghapus dummy data "Trip ke Bali".
  - Menghapus pengaturan Tema dari Settings.
  - Format mata uang Rupiah tanpa desimal (,00).
- **[NEW] Restore Feature**: Implementasi fitur restore data dari file JSON.

### Sebelumnya
- **[FIX]** Mengatasi crash `LateInitializationError` pada startup.
- **[FIX]** Memperbaiki interaksi kartu di halaman Welcome dan Budget.
- **[NEW]** Implementasi fitur Budget Preset berdasarkan kota.
