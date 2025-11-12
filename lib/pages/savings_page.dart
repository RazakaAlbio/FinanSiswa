import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/pages/savings_form_page.dart';
import 'package:uas/theme/app_theme.dart';

/// Halaman Target Tabungan
class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  List<SavingGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FinanceRepository>();
    final items = await repo.listSavingGoals();
    setState(() => _goals = items);
  }

  Future<void> _addGoalDialog() async {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final savedCtrl = TextEditingController(text: '0');
    DateTime? deadline;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<SavingGoal>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tambah Target Tabungan'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nama tujuan'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Nama minimal 2 karakter' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Target nominal'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Target wajib diisi';
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0) return 'Target harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: savedCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Nominal terkumpul'),
                    validator: (v) {
                      final parsed = double.tryParse(v?.replaceAll(',', '.') ?? '0') ?? 0;
                      if (parsed < 0) return 'Nominal tidak boleh negatif';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Batas waktu (opsional)'),
                    subtitle: Text(deadline == null ? '-' : DateFormat('dd MMM yyyy', 'id_ID').format(deadline!)),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: deadline ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              deadline = picked;
                              (ctx as Element).markNeedsBuild();
                            }
                          },
                        ),
                        if (deadline != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              deadline = null;
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
                final target = double.parse(targetCtrl.text.replaceAll(',', '.'));
                final saved = double.parse(savedCtrl.text.replaceAll(',', '.'));
                final g = SavingGoal(name: nameCtrl.text.trim(), targetAmount: target, savedAmount: saved, deadline: deadline);
                Navigator.pop(ctx, g);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      await context.read<FinanceRepository>().addSavingGoal(result);
      await _load();
    }
  }

  Future<void> _delete(int id) async {
    await context.read<FinanceRepository>().deleteSavingGoal(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: _goals.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (ctx, i) {
            final g = _goals[i];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(g.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (g.id != null)
                          IconButton(onPressed: () => _delete(g.id!), icon: const Icon(Icons.delete_outline)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    LinearProgressIndicator(value: g.progress, minHeight: 10),
                    const SizedBox(height: AppSpacing.sm),
                    Text('${fmt.format(g.savedAmount)} / ${fmt.format(g.targetAmount)}',
                        style: Theme.of(context).textTheme.bodyMedium),
                    if (g.deadline != null)
                      Text('Target: ${DateFormat('dd MMM yyyy', 'id_ID').format(g.deadline!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SavingsFormPage()));
          if (created == true) await _load();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}