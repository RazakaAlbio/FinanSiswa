import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/models/monthly_budget.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/repositories/budget_repository.dart';
import 'package:uas/repositories/savings_repository.dart';
import 'package:uas/pages/transaction_form_page.dart';
import 'package:uas/pages/savings_page.dart';
import 'package:uas/pages/budgets_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<FinanceTransaction> _txns = [];
  MonthlyBudget? _monthlyBudget;
  List<SavingGoal> _savingsGoals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FinanceRepository>();
    final budgetRepo = context.read<BudgetRepository>();
    final savingsRepo = context.read<SavingsRepository>();

    final txns = await repo.listTransactions();
    final budget = await budgetRepo.getCurrentMonthBudget();
    final goals = await savingsRepo.getSavingsTargets();

    setState(() {
      _txns = txns;
      _monthlyBudget = budget;
      _savingsGoals = goals;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final income = _txns
        .where((t) => t.type == TransactionType.income)
        .fold<double>(0, (s, t) => s + t.amount);
    final expense = _txns
        .where((t) => t.type == TransactionType.expense)
        .fold<double>(0, (s, t) => s + t.amount);
    final net = income - expense;

    final SavingGoal? firstGoal = _savingsGoals.isNotEmpty
        ? _savingsGoals.first
        : null;
    final double saved = firstGoal?.savedAmount ?? 0;
    final double target =
        firstGoal?.targetAmount ?? 1; // hindari divide by zero
    final double progress = target > 0 ? saved / target : 0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              backgroundColor: const Color(0xFF00BFA5),
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Saldo',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fmt.format(net),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: _cardWithIcon(
                                icon: Icons.arrow_upward,
                                label: 'Pemasukan',
                                amount: fmt.format(income),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _cardWithIcon(
                                icon: Icons.arrow_downward,
                                label: 'Pengeluaran',
                                amount: fmt.format(expense),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // QUICK ACTIONS - PERSIS PROTOTYPE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _quickAction(
                          'Tambah Transaksi',
                          Icons.add_circle_outline,
                          () async {
                            final res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const TransactionFormPage(),
                              ),
                            );
                            if (res != null) {
                              await context
                                  .read<FinanceRepository>()
                                  .addTransaction(res);
                              _load();
                            }
                          },
                        ),
                        _quickAction(
                          'Target Tabungan',
                          Icons.track_changes,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavingsPage(),
                            ),
                          ),
                        ),
                        _quickAction(
                          'Budget',
                          Icons.account_balance_wallet,
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BudgetsPage(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // BUDGET BULANAN
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget Bulanan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: _monthlyBudget == null
                                  ? 0
                                  : (expense / _monthlyBudget!.amount).clamp(
                                      0.0,
                                      1.0,
                                    ),
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF4CAF50),
                              ),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _monthlyBudget == null
                                      ? '0%'
                                      : '${((expense / _monthlyBudget!.amount) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Rp 0 dari 0',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Colors.amber[700],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Bagus! Pengeluaranmu masih terkontrol bulan ini.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TARGET TABUNGAN
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Target Tabungan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.flight,
                                    color: Colors.blue,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        firstGoal?.name ?? 'Belum ada target',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        '${fmt.format(saved)} / ${fmt.format(target)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toStringAsFixed(0)}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF4CAF50),
                              ),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 100), // biar bisa scroll ke bawah
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardWithIcon({
    required IconData icon,
    required String label,
    required String amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF00BFA5).withOpacity(0.15),
            child: Icon(icon, size: 32, color: const Color(0xFF00BFA5)),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
