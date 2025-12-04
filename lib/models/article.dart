import 'package:flutter/material.dart';

class Article {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String tag;
  final String duration;
  final int iconCode;
  final int colorValue;

  const Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.tag,
    required this.duration,
    required this.iconCode,
    required this.colorValue,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);

  static List<Article> get dummyData => [
        Article(
          id: '1',
          title: '5 Cara Hemat Makan di Kampus',
          subtitle: 'Mahasiswa sering kesulitan mengatur budget makan. Berikut tips praktisnya...',
          tag: 'Tips Hemat',
          duration: '3 menit',
          iconCode: Icons.fastfood.codePoint,
          colorValue: Colors.red.value,
          content: '''
Sebagai mahasiswa, pengeluaran terbesar biasanya jatuh pada makanan. Berikut adalah 5 cara ampuh untuk menghemat budget makanmu tanpa harus kelaparan:

1. **Bawa Botol Minum Sendiri**
   Harga air mineral kemasan mungkin terlihat murah, tapi jika dikalikan 30 hari, jumlahnya lumayan lho! Dengan membawa botol minum (tumbler), kamu bisa hemat Rp 100.000 - Rp 150.000 per bulan. Plus, kamu juga membantu mengurangi sampah plastik.

2. **Masak Nasi Sendiri**
   Jika kamu ngekos dan diperbolehkan membawa rice cooker, manfaatkanlah! Membeli lauk saja di warteg jauh lebih murah daripada membeli nasi bungkus lengkap. Kamu bisa hemat hingga 30-40% per porsi.

3. **Manfaatkan Promo & Diskon**
   Jangan gengsi pakai promo! Aplikasi ojek online atau e-wallet sering memberikan diskon cashback. Pantau juga promo "Jumat Berkah" atau diskon jam-jam tertentu di kantin kampus.

4. **Kurangi Jajan Kopi Kekinian**
   Kopi susu seharga Rp 20.000 setiap hari = Rp 600.000 sebulan. Coba ganti dengan menyeduh kopi sachet atau buat kopi sendiri di kos. Rasanya tetap enak, dompet tetap aman.

5. **Puasa Senin-Kamis (Bagi Muslim)**
   Selain mendapat pahala, puasa sunnah juga otomatis memangkas pengeluaran makan siangmu. Badan sehat, dompet hemat, pahala dapat!

Ingat, hemat bukan berarti pelit. Hemat adalah bijak menggunakan uang untuk hal yang benar-benar penting.
          ''',
        ),
        Article(
          id: '2',
          title: 'Kenapa Kamu Harus Bayar Diri Sendiri Dulu',
          subtitle: 'Konsep pay yourself first adalah kunci membangun kekayaan sejak muda...',
          tag: 'Mindset Uang',
          duration: '4 menit',
          iconCode: Icons.payments.codePoint,
          colorValue: Colors.green.value,
          content: '''
Pernahkah kamu merasa gajimu atau uang sakumu "numpang lewat" saja? Baru terima awal bulan, pertengahan bulan sudah menipis. Masalahnya mungkin bukan pada jumlah uangnya, tapi pada **urutan pengeluaranmu**.

**Apa itu "Pay Yourself First"?**
Konsep ini berarti kamu menyisihkan uang untuk tabungan/investasi **segera setelah kamu menerima uang**, SEBELUM kamu membayar tagihan, belanja, atau jajan.

**Kenapa ini penting?**
1. **Membangun Disiplin**: Menabung sisa uang di akhir bulan itu sulit karena biasanya... tidak ada sisa. Dengan menyisihkan di awal, kamu "memaksa" dirimu untuk hidup dengan sisa uang yang ada.
2. **Prioritas Masa Depan**: Kamu memprioritaskan masa depanmu (dana darurat, impian, pensiun) di atas keinginan sesaat.
3. **Peace of Mind**: Memiliki tabungan memberikan ketenangan pikiran. Kamu tidak panik jika ada kebutuhan mendadak.

**Cara Memulainya:**
1. Tentukan persentase, misal 10% atau 20% dari pemasukan.
2. Begitu uang masuk, langsung transfer ke rekening terpisah (rekening tabungan/investasi).
3. Lupakan uang itu ada.
4. Gunakan sisanya untuk kebutuhan sehari-hari.

Mulailah dari nominal kecil. Konsistensi jauh lebih penting daripada jumlah di awal.
          ''',
        ),
        Article(
          id: '3',
          title: 'Cara Stick ke Budget Tanpa Stress',
          subtitle: 'Budget bukan tentang membatasi diri, tapi tentang membuat prioritas...',
          tag: 'Budget',
          duration: '5 menit',
          iconCode: Icons.bar_chart.codePoint,
          colorValue: Colors.blue.value,
          content: '''
Membuat budget itu gampang, yang susah adalah menepatinya. Banyak orang merasa tertekan dengan budget karena merasa "dikekang". Padahal, budget justru memberimu kebebasan untuk membelanjakan uangmu tanpa rasa bersalah.

**Tips Stick ke Budget:**

1. **Gunakan Metode Amplop (Digital/Fisik)**
   Bagi uangmu ke dalam pos-pos (Makan, Transport, Hiburan). Jika pos Hiburan habis, ya sudah, tidak ada nonton bioskop sampai bulan depan. Jangan ambil jatah dari pos Makan.

2. **Berikan "Uang Senang-Senang"**
   Jangan buat budget yang terlalu ketat. Sediakan pos khusus untuk "Jajan/Hiburan". Jika kamu terlalu mengekang diri, kamu akan "balas dendam" dengan boros di kemudian hari.

3. **Review Mingguan**
   Jangan tunggu akhir bulan untuk cek budget. Cek setiap minggu. Jika minggu ini boros di makan, minggu depan masak sendiri. Koreksi secepatnya.

4. **Cari Teman Sevisi**
   Jika teman-temanmu hobi nongkrong mahal, kamu akan sudah berhemat. Cari teman yang juga sedang berjuang mengatur keuangan, atau berani tolak ajakan dengan halus. "Sorry, lagi hemat nih, main ke kosan aja yuk!"

5. **Ingat "Big Why" Kamu**
   Kenapa kamu berhemat? Mau beli laptop baru? Mau traveling? Tempel gambar impianmu di dompet atau wallpaper HP sebagai pengingat saat godaan belanja datang.
          ''',
        ),
        Article(
          id: '4',
          title: 'Side Hustle untuk Mahasiswa',
          subtitle: 'Cari uang tambahan sambil kuliah? Ini pilihan yang cocok untuk mahasiswa...',
          tag: 'Pemasukan',
          duration: '6 menit',
          iconCode: Icons.card_travel.codePoint,
          colorValue: Colors.purple.value,
          content: '''
Uang saku pas-pasan? Jangan sedih. Di era digital ini, peluang mencari uang tambahan (side hustle) bagi mahasiswa terbuka lebar. Kuncinya adalah manajemen waktu.

**Ide Side Hustle Mahasiswa:**

1. **Freelance Writer/Content Creator**
   Suka nulis? Banyak website atau UMKM butuh penulis artikel atau caption sosmed. Modal laptop dan internet saja.

2. **Guru Les Privat**
   Jago Matematika atau Bahasa Inggris? Buka jasa les privat untuk anak SD/SMP di sekitarmu. Bayarannya lumayan per jam.

3. **Jasa Desain Grafis (Canva/Photoshop)**
   Bisa bikin poster atau feed IG yang estetik? Tawarkan jasamu ke teman-teman organisasi kampus atau UMKM.

4. **Dropshipper/Reseller**
   Jualan tanpa stok barang. Kamu hanya perlu mempromosikan produk orang lain. Marginnya kecil, tapi risikonya juga minim.

5. **Joki Tugas (Yang Positif)**
   Bukan joki ujian ya! Tapi jasa ketik, jasa transkrip wawancara, atau jasa merapikan skripsi. Banyak mahasiswa tingkat akhir yang butuh bantuan teknis seperti ini.

**Tips:**
- Pilih yang fleksibel, jangan sampai mengganggu kuliah.
- Jangan tergiur cara cepat kaya (investasi bodong/judi online).
- Fokus pada skill yang bisa jadi portofolio kerjamu nanti.
          ''',
        ),
        Article(
          id: '5',
          title: 'Dana Darurat: Berapa yang Cukup?',
          subtitle: 'Dana darurat itu penting, tapi berapa sih yang ideal untuk mahasiswa?...',
          tag: 'Tabungan',
          duration: '4 menit',
          iconCode: Icons.health_and_safety.codePoint,
          colorValue: Colors.teal.value,
          content: '''
Hidup itu penuh kejutan. Laptop rusak saat skripsi, motor mogok, atau sakit mendadak. Di sinilah peran **Dana Darurat**.

**Berapa Idealnya?**
Untuk orang yang sudah bekerja/berkeluarga, idealnya 6-12 kali pengeluaran bulanan. Tapi untuk mahasiswa?

**Target untuk Mahasiswa:**
Minimal **Rp 1.000.000 - Rp 2.000.000** atau setara **1-2 kali uang saku bulanan**.

Kenapa segitu?
Angka ini biasanya cukup untuk menutupi kejadian tak terduga "level mahasiswa" seperti servis laptop ringan, ban bocor, atau berobat ke klinik, tanpa harus minta orang tua mendadak.

**Di mana Simpannya?**
- Jangan di dompet (gampang terpakai).
- Jangan di deposito berjangka (susah diambil mendadak).
- Simpan di **Rekening Bank Terpisah** atau **Reksadana Pasar Uang** (bisa cair cepat & risikonya rendah).

**Kapan Boleh Dipakai?**
HANYA untuk keadaan DARURAT.
- Laptop rusak = Darurat.
- Diskon sepatu 50% = BUKAN Darurat.
- Tiket konser = BUKAN Darurat.

Mulailah kumpulkan sedikit demi sedikit. Rp 5.000 sehari pun lama-lama jadi bukit!
          ''',
        ),
      ];
}
