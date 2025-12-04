import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/main.dart';
import 'package:uas/models/monthly_budget.dart';
import 'package:uas/repositories/budget_repository.dart';
import 'package:uas/services/preferences_service.dart';
import 'package:uas/theme/app_theme.dart';

class BudgetSliderModal extends StatefulWidget {
  final double min;
  final double max;
  final double initial;
  final String cityName;
  final bool isFirstLaunch;

  const BudgetSliderModal({
    super.key,
    required this.min,
    required this.max,
    required this.initial,
    required this.cityName,
    this.isFirstLaunch = false,
  });

  @override
  State<BudgetSliderModal> createState() => _BudgetSliderModalState();
}

class _BudgetSliderModalState extends State<BudgetSliderModal> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initial;
  }

  String _formatCurrency(double value) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormatter.format(value);
  }

  Future<void> _saveBudget() async {
    final repo = context.read<BudgetRepository>();
    final prefs = context.read<PreferencesService>();
    final now = DateTime.now();
    
    final budget = MonthlyBudget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: _currentValue,
      month: now.month,
      year: now.year,
      spentAmount: 0,
    );

    await repo.setMonthlyBudget(budget);

    if (widget.isFirstLaunch) {
      await prefs.setFirstLaunchFalse();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomeShell()),
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.cityName == 'Custom' 
                ? 'Atur Budget Sendiri' 
                : 'Atur Budget untuk ${widget.cityName}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              _formatCurrency(_currentValue),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withOpacity(0.2),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.1),
            ),
            child: Slider(
              value: _currentValue,
              min: widget.min,
              max: widget.max,
              divisions: 100,
              label: _formatCurrency(_currentValue),
              onChanged: (value) {
                setState(() {
                  _currentValue = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatCurrency(widget.min),
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                _formatCurrency(widget.max),
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveBudget,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Simpan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
