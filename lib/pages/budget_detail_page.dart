import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uas/models/budget.dart';

/// Halaman detail budget untuk melihat, edit, dan menghapus
class BudgetDetailPage extends StatefulWidget {
  final Budget budget;
  final Function(Budget) onUpdate;
  final Function(int) onDelete;

  const BudgetDetailPage({
    super.key,
    required this.budget,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<BudgetDetailPage> createState() => _BudgetDetailPageState();
}

class _BudgetDetailPageState extends State<BudgetDetailPage> {
  late Budget _budget;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  late BudgetPeriod _period;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _budget = widget.budget;
    _initializeForm();
  }

  void _initializeForm() {
    _nameCtrl.text = _budget.name;
    _amountCtrl.text = _budget.amount.toStringAsFixed(0);
    _period = _budget.period;
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final updatedBudget = Budget(
      id: _budget.id,
      name: _nameCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      period: _period,
      startDate: _budget.startDate,
      endDate: _budget.endDate,
    );

    widget.onUpdate(updatedBudget);
    setState(() {
      _budget = updatedBudget;
      _isEditing = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Budget berhasil diperbarui')));
  }

  void _deleteBudget() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Budget'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus budget ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              widget.onDelete(_budget.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyView() {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nama', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          _budget.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text('Nominal', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          fmt.format(_budget.amount),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text('Periode', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(_budget.period.toString().split('.').last.capitalize()),
        const SizedBox(height: 16),
        Text('Tanggal Mulai', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(DateFormat('dd MMM yyyy', 'id_ID').format(_budget.startDate)),
        if (_budget.endDate != null) ...[
          const SizedBox(height: 16),
          Text('Tanggal Selesai', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(DateFormat('dd MMM yyyy', 'id_ID').format(_budget.endDate!)),
        ],
      ],
    );
  }

  Widget _buildEditView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(
              labelText: 'Nama',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.trim().length < 2
                ? 'Nama minimal 2 karakter'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Nominal',
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Nominal wajib diisi';
              final parsed = double.tryParse(v.replaceAll(',', '.'));
              if (parsed == null || parsed <= 0)
                return 'Nominal harus lebih dari 0';
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<BudgetPeriod>(
            value: _period,
            decoration: const InputDecoration(
              labelText: 'Periode',
              border: OutlineInputBorder(),
            ),
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
            onChanged: (v) => setState(() => _period = v!),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _saveChanges,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Budget' : 'Detail Budget'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Budget',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteBudget,
              tooltip: 'Hapus Budget',
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isEditing ? _buildEditView() : _buildReadOnlyView(),
      ),
    );
  }
}

// EXTENSION UNTUK CAPITALIZE
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
