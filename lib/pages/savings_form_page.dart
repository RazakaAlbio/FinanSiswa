import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/theme/app_theme.dart';

class SavingsFormPage extends StatefulWidget {
  final SavingGoal? goal;

  const SavingsFormPage({super.key, this.goal});

  @override
  State<SavingsFormPage> createState() => _SavingsFormPageState();
}

class _SavingsFormPageState extends State<SavingsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _savedCtrl = TextEditingController(text: '0');
  DateTime? _deadline;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nameCtrl.text = widget.goal!.name;
      _targetCtrl.text = widget.goal!.targetAmount.toStringAsFixed(0);
      _savedCtrl.text = widget.goal!.savedAmount.toStringAsFixed(0);
      _deadline = widget.goal!.deadline;
    }
  }

  String? _validateAmount(String? v, {bool allowZero = false}) {
    if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null) return 'Nominal tidak valid';
    if (!allowZero && parsed <= 0) return 'Nominal harus lebih dari 0';
    if (allowZero && parsed < 0) return 'Nominal tidak boleh negatif';
    return null;
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final repo = context.read<FinanceRepository>();
      final goal = SavingGoal(
        id: widget.goal?.id,
        name: _nameCtrl.text.trim(),
        targetAmount: double.parse(_targetCtrl.text.replaceAll(',', '.')),
        savedAmount: double.parse(_savedCtrl.text.replaceAll(',', '.')),
        deadline: _deadline,
      );
      
      if (widget.goal == null) {
        await repo.addSavingGoal(goal);
      } else {
        await repo.updateSavingGoal(goal);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd MMM yyyy', 'id_ID');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal == null ? 'Tambah Target Tabungan' : 'Edit Target Tabungan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama tujuan'),
                validator: (v) => (v == null || v.trim().length < 3) ? 'Nama minimal 3 karakter' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _targetCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Target nominal'),
                validator: (v) => _validateAmount(v),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _savedCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Nominal terkumpul'),
                validator: (v) => _validateAmount(v, allowZero: true),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Batas waktu (opsional)'),
                      subtitle: Text(_deadline == null ? '-' : fmt.format(_deadline!)),
                      trailing: Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDeadline),
                          if (_deadline != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() => _deadline = null),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}