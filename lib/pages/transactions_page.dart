import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/pages/transaction_form_page.dart';
import 'package:uas/pages/transaction_detail_page.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<FinanceTransaction> _txns = [];
  List<FinanceTransaction> _expenses = [];
  double _totalExpenses = 0.0;
  double _averageDaily = 0.0;
  Map<String, double> _categoryExpenses = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FinanceRepository>();
    final txns = await repo.listTransactions();
    setState(() {
      _txns = txns;
      _calculateStatistics(txns);
    });
  }

  void _calculateStatistics(List<FinanceTransaction> transactions) {
    _expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    _totalExpenses = _expenses.fold(0.0, (sum, t) => sum + t.amount);
    _averageDaily = _totalExpenses / 30; // asumsi 30 hari

    _categoryExpenses.clear();
    for (var e in _expenses) {
      _categoryExpenses.update(
        e.category,
        (v) => v + e.amount,
        ifAbsent: () => e.amount,
      );
    }
  }

  // Warna kategori sesuai prototype
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'makanan':
        return const Color(0xFFFF8C00); // orange
      case 'hiburan':
        return const Color(0xFFE91E63); // pink
      case 'akademik':
        return const Color(0xFF9C27B0); // purple
      case 'transportasi':
        return const Color(0xFF2196F3); // blue
      case 'kesehatan':
        return const Color(0xFF4CAF50); // green
      case 'lainnya':
      default:
        return const Color(0xFF607D8B); // grey blue
    }
  }

  Future<void> _add() async {
    final res = await Navigator.of(context).push<FinanceTransaction>(
      MaterialPageRoute(builder: (_) => const TransactionFormPage()),
    );
    if (res != null) {
      await context.read<FinanceRepository>().addTransaction(res);
      _load();
    }
  }

  Future<void> _openDetail(FinanceTransaction t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(
          transaction: t,
          onUpdate: (updated) async {
            await context.read<FinanceRepository>().updateTransaction(updated);
            _load();
          },
          onDelete: (id) async {
            await context.read<FinanceRepository>().deleteTransaction(id);
            _load();
          },
        ),
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');

    final pieSections = _categoryExpenses.entries.map((entry) {
      final color = _getCategoryColor(entry.key);
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '',
        radius: 50,
      );
    }).toList();

    final totalForLegend = _categoryExpenses.values.fold(0.0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // HEADER TEAL SIMPEL (sesuai prototype)
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: const Color(0xFF00BFA5),
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Laporan Keuangan',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Analisa pola pengeluaranmu',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // CARD TOTAL & RATA-RATA (di luar header)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        title: 'Total Pengeluaran',
                        amount: fmt.format(_totalExpenses),
                        change: '8% dari bulan lalu',
                        changePositive: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        title: 'Rata-rata Harian',
                        amount: fmt.format(_averageDaily),
                        change: '8% dari bulan lalu',
                        changePositive: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // PIE CHART + LEGEND
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran per Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 180,
                              width: 180,
                              child: _totalExpenses == 0
                                  ? const Center(child: Text('Belum ada data'))
                                  : PieChart(
                                      PieChartData(
                                        sections: pieSections,
                                        centerSpaceRadius: 50,
                                        sectionsSpace: 3,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                children: _categoryExpenses.entries.map((e) {
                                  final percent =
                                      (e.value / totalForLegend * 100).round();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(e.key),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(e.key)),
                                        Text(
                                          '$percent%',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
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

            // Daftar Transaksi Header & List (tetap sama)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      'Daftar Transaksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      backgroundColor: const Color(0xFF00BFA5).withOpacity(0.1),
                      label: Text('${_txns.length} transaksi'),
                    ),
                  ],
                ),
              ),
            ),

            // List transaksi tetap sama seperti sebelumnya...
            _txns.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum ada transaksi',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text('Tap + untuk menambah transaksi pertama'),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, i) {
                      final t = _txns[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                            child: Icon(
                              t.type == TransactionType.income
                                  ? Icons.call_received
                                  : Icons.call_made,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            t.category,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat(
                                  'dd MMM yyyy',
                                  'id_ID',
                                ).format(t.date),
                              ),
                              if (t.note != null && t.note!.isNotEmpty)
                                Text(
                                  t.note!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                fmt.format(t.amount),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: t.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Text(
                                t.type == TransactionType.income
                                    ? 'Pemasukan'
                                    : 'Pengeluaran',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _openDetail(t),
                        ),
                      );
                    }, childCount: _txns.length),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00BFA5),
        onPressed: _add,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String amount,
    required String change,
    required bool changePositive,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              change,
              style: TextStyle(
                fontSize: 12,
                color: changePositive ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
