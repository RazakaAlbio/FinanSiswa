import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/repositories/finance_repository.dart';

/// Halaman Dashboard: ringkasan pemasukan/pengeluaran & visualisasi grafik
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<FinanceTransaction> _txns = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FinanceRepository>();
    final txns = await repo.listTransactions();
    setState(() => _txns = txns);
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    final income = _txns.where((t) => t.type == TransactionType.income).fold<double>(0, (s, t) => s + t.amount);
    final expense = _txns.where((t) => t.type == TransactionType.expense).fold<double>(0, (s, t) => s + t.amount);
    final net = income - expense;

    final byCategory = <String, double>{};
    for (final t in _txns.where((t) => t.type == TransactionType.expense)) {
      byCategory.update(t.category, (value) => value + t.amount, ifAbsent: () => t.amount);
    }
    final bars = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(title: 'Pemasukan', value: fmt.format(income), color: Colors.green.shade700, icon: Icons.call_received)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Pengeluaran', value: fmt.format(expense), color: Colors.red.shade700, icon: Icons.call_made)),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(title: 'Saldo Bersih', value: fmt.format(net), color: Colors.blue.shade700, icon: Icons.account_balance),
          const SizedBox(height: 24),
          Text('Pengeluaran per Kategori', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SizedBox(
            height: 240,
            child: bars.isEmpty
                ? const Center(child: Text('Belum ada data'))
                : BarChart(
                    BarChartData(
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= bars.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  bars[idx].key.length > 6 ? '${bars[idx].key.substring(0, 6)}…' : bars[idx].key,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: [
                        for (int i = 0; i < bars.length; i++)
                          BarChartGroupData(x: i, barRods: [BarChartRodData(toY: bars[i].value, color: Colors.orange)])
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _StatCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}