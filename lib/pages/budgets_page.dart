import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/budget.dart';
import 'package:uas/repositories/finance_repository.dart';

/// Halaman Anggaran
class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FinanceRepository>();
    final items = await repo.listBudgets();
    setState(() => _budgets = items);
  }

  Future<void> _addBudgetDialog() async {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    BudgetPeriod period = BudgetPeriod.monthly;
    DateTime start = DateTime.now();
    DateTime? end;

    final formKey = GlobalKey<FormState>();
    final result = await showDialog<Budget>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
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
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Nama minimal 2 karakter' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Nominal'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) return 'Nominal harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<BudgetPeriod>(
                    value: period,
                    items: const [
                      DropdownMenuItem(value: BudgetPeriod.daily, child: Text('Harian')),
                      DropdownMenuItem(value: BudgetPeriod.weekly, child: Text('Mingguan')),
                      DropdownMenuItem(value: BudgetPeriod.monthly, child: Text('Bulanan')),
                    ],
                    onChanged: (v) => period = v ?? BudgetPeriod.monthly,
                    decoration: const InputDecoration(labelText: 'Periode'),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mulai'),
                    subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(start)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: start,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          start = picked;
                          (ctx as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Selesai (opsional)'),
                    subtitle: Text(end == null ? '-' : DateFormat('dd MMM yyyy', 'id_ID').format(end!)),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: end ?? start,
                              firstDate: start,
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              end = picked;
                              (ctx as Element).markNeedsBuild();
                            }
                          },
                        ),
                        if (end != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              end = null;
                              (ctx as Element).markNeedsBuild();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final amt = double.parse(amountCtrl.text.replaceAll(',', '.'));
                final b = Budget(name: nameCtrl.text.trim(), amount: amt, period: period, startDate: start, endDate: end);
                Navigator.pop(ctx, b);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _budgets.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final b = _budgets[i];
            final periodStr = {
              BudgetPeriod.daily: 'Harian',
              BudgetPeriod.weekly: 'Mingguan',
              BudgetPeriod.monthly: 'Bulanan',
            }[b.period]!;
            return Card(
              child: ListTile(
                title: Text('${b.name} • $periodStr'),
                subtitle: Text('Mulai: ${DateFormat('dd MMM yyyy', 'id_ID').format(b.startDate)}' + (b.endDate == null ? '' : '\nSelesai: ${DateFormat('dd MMM yyyy', 'id_ID').format(b.endDate!)}')),
                trailing: Text(fmt.format(b.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                onLongPress: b.id == null ? null : () => _delete(b.id!),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addBudgetDialog, child: const Icon(Icons.add)),
    );
  }
}