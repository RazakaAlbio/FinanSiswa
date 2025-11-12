import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/theme/app_theme.dart';

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
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              Expanded(child: _StatCard(title: 'Pemasukan', value: fmt.format(income), color: Colors.green.shade700, icon: Icons.call_received)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(title: 'Pengeluaran', value: fmt.format(expense), color: Colors.red.shade700, icon: Icons.call_made)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _StatCard(title: 'Saldo Bersih', value: fmt.format(net), color: Colors.blue.shade700, icon: Icons.account_balance),
          const SizedBox(height: AppSpacing.xl),
          Text('Pengeluaran per Kategori', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: MediaQuery.of(context).size.width < 400 ? 220 : 280,
            child: bars.isEmpty
                ? const Center(child: Text('Belum ada data'))
                : BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final cat = bars[group.x.toInt()].key;
                            return BarTooltipItem(
                              '$cat\n${fmt.format(rod.toY)}',
                              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            );
                          },
                        ),
                      ),
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
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: bars[i].value,
                                width: 14,
                                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                                borderRadius: BorderRadius.circular(4),
                              )
                            ],
                          )
                      ],
                  ),
          ),
          ),
          if (bars.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                for (int i = 0; i < bars.length && i < 8; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(bars[i].key, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text('Tren Pengeluaran (7 hari)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          _buildWeeklyExpenseLine(fmt),
        ],
      ),
    );
  }

  Widget _buildWeeklyExpenseLine(NumberFormat fmt) {
    // Group expenses by day for last 7 days
    final now = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));
    final map = {for (final d in days) DateTime(d.year, d.month, d.day): 0.0};
    for (final t in _txns.where((t) => t.type == TransactionType.expense)) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (map.containsKey(d)) map[d] = (map[d] ?? 0) + t.amount;
    }
    final spots = <FlSpot>[];
    for (int i = 0; i < days.length; i++) {
      final d = DateTime(days[i].year, days[i].month, days[i].day);
      spots.add(FlSpot(i.toDouble(), map[d] ?? 0));
    }
    if (spots.every((s) => s.y == 0)) {
      return const SizedBox(height: 200, child: Center(child: Text('Belum ada data')));
    }
    return SizedBox(
      height: MediaQuery.of(context).size.width < 400 ? 200 : 240,
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (s) => s
                  .map((barSpot) => LineTooltipItem(fmt.format(barSpot.y), const TextStyle(color: Colors.white)))
                  .toList(),
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(DateFormat('dd/MM').format(days[idx]), style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.secondary,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.secondary.withOpacity(0.4), Colors.transparent], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
            ),
          ],
        ),
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