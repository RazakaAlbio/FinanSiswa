import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uas/models/budget.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/pages/budget_form_page.dart';
import 'package:uas/pages/budget_detail_page.dart';
import 'package:uas/pages/budget_slider_modal.dart';
import 'package:uas/models/monthly_budget.dart';
import 'package:uas/repositories/budget_repository.dart';

class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  List<Budget> _budgets = [];
  MonthlyBudget? _monthlyBudget;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FinanceRepository>();
    final budgetRepo = context.read<BudgetRepository>();
    final items = await repo.listBudgets();
    final monthly = await budgetRepo.getCurrentMonthBudget();
    setState(() {
      _budgets = items;
      _monthlyBudget = monthly;
    });
  }

  void _editBudget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BudgetSliderModal(
        min: 0,
        max: 100000000,
        initial: _monthlyBudget?.amount ?? 5000000,
        cityName: 'Custom',
        isFirstLaunch: false,
      ),
    ).then((updated) {
      if (updated == true) _load();
    });
  }

  Future<void> _addBudgetDialog() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    BudgetPeriod period = BudgetPeriod.monthly; // default

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Budget>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Anggaran'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) => v == null || v.trim().length < 2
                      ? 'Nama minimal 2 karakter'
                      : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Nominal'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Nominal wajib diisi';
                    final val = double.tryParse(v.replaceAll(',', '.'));
                    if (val == null || val <= 0) return 'Nominal harus > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<BudgetPeriod>(
                  value: period,
                  decoration: const InputDecoration(labelText: 'Periode'),
                  items: const [
                    DropdownMenuItem(
                      value: BudgetPeriod.daily,
                      child: Text('Harian'),
                    ),
                    DropdownMenuItem(
                      value: BudgetPeriod.weekly,
                      child: Text('Mingguan'),
                    ),
                    DropdownMenuItem(
                      value: BudgetPeriod.monthly,
                      child: Text('Bulanan'),
                    ),
                  ],
                  onChanged: (v) => period = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final budget = Budget(
                name: nameCtrl.text.trim(),
                amount: double.parse(amountCtrl.text.replaceAll(',', '.')),
                period: period,
                startDate: DateTime.now(),
              );
              Navigator.pop(ctx, budget);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result != null) {
      await context.read<FinanceRepository>().addBudget(result);
      await _load();
    }
  }

  Future<void> _delete(int id) async {
    await context.read<FinanceRepository>().deleteBudget(id);
    await _load();
  }

  Icon _getIconForCategory(String name) {
    final lower = name.toLowerCase();
    IconData iconData;
    Color color = const Color(0xFF00BFA5);

    if (lower.contains('transportasi')) {
      iconData = Icons.directions_bus;
      color = Colors.blue;
    } else if (lower.contains('akademik')) {
      iconData = Icons.book;
      color = Colors.purple;
    } else if (lower.contains('hiburan')) {
      iconData = Icons.videogame_asset;
      color = Colors.pink;
    } else if (lower.contains('kesehatan')) {
      iconData = Icons.local_hospital;
      color = Colors.red;
    } else if (lower.contains('lainnya')) {
      iconData = Icons.inventory;
      color = Colors.grey;
    } else {
      iconData = Icons.category;
    }

    return Icon(iconData, color: color, size: 20);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
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
                          'Budget Bulanan',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kelola pengeluaranmu per kategori',
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

            // TOTAL BUDGET CARD
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Budget',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20, color: Color(0xFF00BFA5)),
                          onPressed: _editBudget,
                          tooltip: 'Ubah Limit Bulanan',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt.format(_monthlyBudget?.amount ?? 0),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _monthlyBudget == null
                          ? 0
                          : (_monthlyBudget!.spentAmount / _monthlyBudget!.amount).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFF4CAF50),
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Terpakai ${fmt.format(_monthlyBudget?.spentAmount ?? 0)} (${_monthlyBudget?.percentage.toStringAsFixed(1)}%)',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // SWITCH PRESET (dummy)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(
                      'Gunakan Budget Preset',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Budget disesuaikan untuk kota Bandung',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    trailing: Switch(value: false, onChanged: (_) {}),
                  ),
                ),
              ),
            ),

            // KATEGORI BUDGET HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kategori Budget',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // LIST BUDGETS
            SliverList(
              delegate: SliverChildBuilderDelegate((context, i) {
                final b = _budgets[i];
                final spent = 0.0; // no spent logic → dummy
                final progress = b.amount > 0 ? spent / b.amount : 0.0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BudgetDetailPage(
                          budget: b,
                          onUpdate: (updated) async {
                            await context
                                .read<FinanceRepository>()
                                .updateBudget(updated);
                            _load();
                          },
                          onDelete: (id) async {
                            await context
                                .read<FinanceRepository>()
                                .deleteBudget(id);
                            _load();
                          },
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(
                                0xFF00BFA5,
                              ).withOpacity(0.1),
                              child: _getIconForCategory(b.name),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    b.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${fmt.format(spent)} / ${fmt.format(b.amount)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }, childCount: _budgets.length),
            ),
            // TIPS CARD
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber[700],
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tips Budget',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• Gunakan aturan 50/30/20: 50% kebutuhan, 30% keinginan, 20% tabungan',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Review budget setiap minggu untuk tetap on track',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '• Sisihkan budget untuk dana darurat',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BFA5),
        onPressed: () async {
          final created = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const BudgetFormPage()));
          if (created == true) await _load();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
