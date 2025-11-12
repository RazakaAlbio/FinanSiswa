import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/budget.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/theme/app_theme.dart';

class BudgetFormPage extends StatefulWidget {
  const BudgetFormPage({super.key});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  BudgetPeriod _period = BudgetPeriod.monthly;
  DateTime _start = DateTime.now();
  DateTime? _end;
  bool _submitting = false;

  String? _validateAmount(String? v) {
    if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return 'Nominal harus lebih dari 0';
    return null;
  }

  Future<void> _pickDate({required bool start}) async {
    final initial = start ? _start : (_end ?? _start.add(const Duration(days: 30)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (start) {
          _start = picked;
          if (_end != null && _end!.isBefore(_start)) _end = null;
        } else {
          _end = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final repo = context.read<FinanceRepository>();
      final amt = double.parse(_amountCtrl.text.replaceAll(',', '.'));
      final budget = Budget(
        name: _nameCtrl.text.trim(),
        amount: amt,
        period: _period,
        startDate: _start,
        endDate: _end,
      );
      await repo.addBudget(budget);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anggaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Anggaran'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Nama minimal 3 karakter' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nominal'),
                validator: _validateAmount,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<BudgetPeriod>(
                value: _period,
                items: const [
                  DropdownMenuItem(value: BudgetPeriod.daily, child: Text('Harian')),
                  DropdownMenuItem(value: BudgetPeriod.weekly, child: Text('Mingguan')),
                  DropdownMenuItem(value: BudgetPeriod.monthly, child: Text('Bulanan')),
                ],
                onChanged: (v) => setState(() => _period = v ?? BudgetPeriod.monthly),
                decoration: const InputDecoration(labelText: 'Periode'),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mulai'),
                      subtitle: Text(fmt.format(_start)),
                      trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(start: true)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Selesai (opsional)'),
                      subtitle: Text(_end == null ? '-' : fmt.format(_end!)),
                      trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(start: false)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}