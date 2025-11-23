import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BelajarPage extends StatelessWidget {
  const BelajarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // HEADER TEAL
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: const Color(0xFF00BFA5),
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edukasi Keuangan',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Belajar kelola uang dengan cerdas',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // TIPS CEPAT (4 CARD)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips Cepat',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0,
                    children: [
                      _quickTipCard(
                        icon: Icons.edit_note,
                        color: const Color(0xFF4CAF50),
                        title: 'Catat Setiap Hari',
                        subtitle: 'Kebiasaan kecil ini akan mengubah hidupmu',
                      ),
                      _quickTipCard(
                        icon: Icons.trending_up,
                        color: const Color(0xFF2196F3),
                        title: 'Review Mingguan',
                        subtitle: 'Cek progress budget setiap minggu',
                      ),
                      _quickTipCard(
                        icon: Icons.account_balance_wallet,
                        color: const Color(0xFFFF9800),
                        title: 'Pisahkan Rekening',
                        subtitle: 'Jangan campur uang belanja & tabungan',
                      ),
                      _quickTipCard(
                        icon: Icons.track_changes,
                        color: const Color(0xFF9C27B0),
                        title: 'Mulai dari Kecil',
                        subtitle: 'Target kecil lebih mudah dicapai',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ARTIKEL PILIHAN
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Artikel Pilihan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // LIST ARTIKEL
          SliverList(
            delegate: SliverChildListDelegate([
              _articleCard(
                icon: Icons.fastfood,
                color: Colors.red,
                tag: 'Tips Hemat',
                duration: '3 menit',
                title: '5 Cara Hemat Makan di Kampus',
                subtitle:
                    'Mahasiswa sering kesulitan mengatur budget makan. Berikut tips praktisnya...',
              ),
              _articleCard(
                icon: Icons.payments,
                color: Colors.green,
                tag: 'Mindset Uang',
                duration: '4 menit',
                title: 'Kenapa Kamu Harus Bayar Diri Sendiri Dulu',
                subtitle:
                    'Konsep pay yourself first adalah kunci membangun kekayaan sejak muda...',
              ),
              _articleCard(
                icon: Icons.bar_chart,
                color: Colors.blue,
                tag: 'Budget',
                duration: '5 menit',
                title: 'Cara Stick ke Budget Tanpa Stress',
                subtitle:
                    'Budget bukan tentang membatasi diri, tapi tentang membuat prioritas...',
              ),
              _articleCard(
                icon: Icons.card_travel,
                color: Colors.purple,
                tag: 'Pemasukan',
                duration: '6 menit',
                title: 'Side Hustle untuk Mahasiswa',
                subtitle:
                    'Cari uang tambahan sambil kuliah? Ini pilihan yang cocok untuk mahasiswa...',
              ),
              _articleCard(
                icon: Icons.health_and_safety,
                color: Colors.teal,
                tag: 'Tabungan',
                duration: '4 menit',
                title: 'Dana Darurat: Berapa yang Cukup?',
                subtitle:
                    'Dana darurat itu penting, tapi berapa sih yang ideal untuk mahasiswa?...',
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _quickTipCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _articleCard({
    required IconData icon,
    required Color color,
    required String tag,
    required String duration,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• $duration',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
