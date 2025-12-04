import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/main.dart';
import 'package:uas/models/monthly_budget.dart';
import 'package:uas/repositories/budget_repository.dart';
import 'package:uas/theme/app_theme.dart';
import 'package:uas/pages/budget_slider_modal.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _showBudgetSlider(
    BuildContext context, {
    required double min,
    required double max,
    required double initial,
    required String cityName,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BudgetSliderModal(
        min: min,
        max: max,
        initial: initial,
        cityName: cityName,
        isFirstLaunch: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Icon/Image Section
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.savings_outlined,
                size: 80,
                color: Color(0xFF8D6E63),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Selamat Datang di FinanSiswa',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Kelola keuanganmu dengan mudah. Mulai dengan memilih kotamu untuk mendapatkan rekomendasi budget.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),

            // City List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  CityCard(
                    city: 'Jakarta',
                    range: 'Rp 3.000.000 - Rp 4.500.000/bulan',
                    onTap: () => _showBudgetSlider(
                      context,
                      min: 3000000,
                      max: 4500000,
                      initial: 3750000,
                      cityName: 'Jakarta',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CityCard(
                    city: 'Bandung',
                    range: 'Rp 2.000.000 - Rp 3.000.000/bulan',
                    onTap: () => _showBudgetSlider(
                      context,
                      min: 2000000,
                      max: 3000000,
                      initial: 2500000,
                      cityName: 'Bandung',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CityCard(
                    city: 'Yogyakarta',
                    range: 'Rp 1.800.000 - Rp 2.500.000/bulan',
                    onTap: () => _showBudgetSlider(
                      context,
                      min: 1800000,
                      max: 2500000,
                      initial: 2150000,
                      cityName: 'Yogyakarta',
                    ),
                  ),
                  const SizedBox(height: 16),
                  CityCard(
                    city: 'Surabaya',
                    range: 'Rp 2.500.000 - Rp 3.500.000/bulan',
                    onTap: () => _showBudgetSlider(
                      context,
                      min: 2500000,
                      max: 3500000,
                      initial: 3000000,
                      cityName: 'Surabaya',
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    _showBudgetSlider(
                      context,
                      min: 0,
                      max: 100000000, // 100 Juta
                      initial: 1000000,
                      cityName: 'Custom',
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: const Color(0xFFF8F9FA),
                  ),
                  child: Text(
                    'Lewati & Atur Sendiri',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class CityCard extends StatelessWidget {
  final String city;
  final String range;
  final VoidCallback onTap;

  const CityCard({
    super.key,
    required this.city,
    required this.range,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF009688),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        range,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
