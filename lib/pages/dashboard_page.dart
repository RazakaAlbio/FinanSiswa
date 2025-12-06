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
import 'package:uas/models/budget.dart'; // Import Budget model

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<FinanceTransaction> _txns = [];
  MonthlyBudget? _monthlyBudget;
  List<SavingGoal> _savingsGoals = [];
  List<Budget> _budgets = [];

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
    final goals = await repo.listSavingGoals();

    final budgets = await repo.listBudgets();

    setState(() {
      _txns = txns;
      _monthlyBudget = budget;
      _savingsGoals = goals;
      _budgets = budgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
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
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BudgetsPage(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
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
                                // Expense Progress
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Pengeluaran', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                                    Text(
                                      _monthlyBudget == null ? '0%' : '${((expense / _monthlyBudget!.amount) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: _monthlyBudget == null
                                      ? 0
                                      : (expense / _monthlyBudget!.amount).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation(Colors.red),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 12),
                                // Income Progress
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Pemasukan', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                                    Text(
                                      _monthlyBudget == null ? '0%' : '${((income / _monthlyBudget!.amount) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: _monthlyBudget == null
                                      ? 0
                                      : (income / _monthlyBudget!.amount).clamp(0.0, 1.0),
                                  backgroundColor: Colors.grey[300],
                                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Budget: ${fmt.format(_monthlyBudget?.amount ?? 0)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // INDIVIDUAL BUDGETS LIST
                      if (_budgets.isNotEmpty) ...[
                        Text(
                          'Daftar Anggaran',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _budgets.length,
                            itemBuilder: (context, index) {
                              final b = _budgets[index];
                              // Calculate spent for this budget
                              final bSpent = _txns
                                  .where((t) => 
                                      t.type == TransactionType.expense && 
                                      t.category.toLowerCase() == b.name.toLowerCase())
                                  .fold(0.0, (sum, t) => sum + t.amount);
                              final bProgress = b.amount > 0 ? (bSpent / b.amount).clamp(0.0, 1.0) : 0.0;
                              
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 12),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          b.name,
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          fmt.format(b.amount),
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: bProgress,
                                          backgroundColor: Colors.grey[200],
                                          valueColor: AlwaysStoppedAnimation(
                                            bProgress > 0.8 ? Colors.red : Colors.blue,
                                          ),
                                          minHeight: 6,
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${(bProgress * 100).toStringAsFixed(0)}% Used',
                                          style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                    const SizedBox(height: 20),

                    // TARGET TABUNGAN
                    // TARGET TABUNGAN LIST
                    if (_savingsGoals.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Target Tabungan',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SavingsPage(),
                              ),
                            ),
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._savingsGoals.map((goal) {
                        final saved = goal.savedAmount;
                        final target = goal.targetAmount > 0 ? goal.targetAmount : 1.0;
                        final progress = saved / target;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SavingsPage(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color(0xFF00BFA5).withOpacity(0.1),
                                          child: const Icon(Icons.flight, color: Color(0xFF00BFA5), size: 24),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            goal.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    LinearProgressIndicator(
                                      value: progress.clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey[200],
                                      valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          fmt.format(saved),
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                                        ),
                                        Text(
                                          fmt.format(target),
                                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[800]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sisa: ${fmt.format(target - saved)}',
                                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                        ),
                                        if (goal.deadline != null)
                                          Text(
                                            'Tenggat: ${DateFormat('dd MMM yyyy', 'id_ID').format(goal.deadline!)}',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.red[400],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ] else ...[
                       // Empty state or just the shortcut card
                       Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SavingsPage())),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text('Belum ada target tabungan. Buat sekarang!', style: GoogleFonts.poppins()),
                            ),
                          ),
                        ),
                       ),
                    ],

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
      width: double.infinity, // Ensure full width in Expanded
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
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF00BFA5).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
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
