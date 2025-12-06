import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/models/category.dart';
import 'package:uas/repositories/category_repository.dart';
import 'package:provider/provider.dart';

/// Halaman detail transaksi untuk melihat, edit, dan menghapus
class TransactionDetailPage extends StatefulWidget {
  final FinanceTransaction transaction;
  final Function(FinanceTransaction) onUpdate;
  final Function(int) onDelete;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late FinanceTransaction _transaction;
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  late TransactionType _type;
  late DateTime _date;
  List<Category> _categories = [];

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
    _initializeForm();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final repo = context.read<CategoryRepository>();
    final items = await repo.getCategories();
    setState(() => _categories = items);
  }

  void _initializeForm() {
    _amountCtrl.text = _transaction.amount.toStringAsFixed(0);
    _categoryCtrl.text = _transaction.category;
    _noteCtrl.text = _transaction.note ?? '';
    _type = _transaction.type;
    _date = _transaction.date;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) return;

    final updatedTransaction = FinanceTransaction(
      id: _transaction.id,
      amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
      category: _categoryCtrl.text.trim(),
      type: _type,
      date: _date,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    widget.onUpdate(updatedTransaction);
    setState(() {
      _transaction = updatedTransaction;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transaksi berhasil diperbarui')),
    );
  }

  void _deleteTransaction() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus transaksi ini? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (_transaction.id != null) {
                widget.onDelete(_transaction.id!);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _cancelEdit() {
    _initializeForm();
    setState(() => _isEditing = false);
  }

  Widget _buildReadOnlyView() {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan nominal dan type
        Card(
          color: _transaction.type == TransactionType.income
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  fmt.format(_transaction.amount),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _transaction.type == TransactionType.income
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    _transaction.type == TransactionType.income
                        ? 'PEMASUKAN'
                        : 'PENGELUARAN',
                    style: TextStyle(
                      color: _transaction.type == TransactionType.income
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _transaction.type == TransactionType.income
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Detail transaksi
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Transaksi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Kategori', _transaction.category),
                _buildDetailRow(
                  'Tanggal',
                  DateFormat('dd MMM yyyy', 'id_ID').format(_transaction.date),
                ),
                if (_transaction.note != null && _transaction.note!.isNotEmpty)
                  _buildDetailRow('Catatan', _transaction.note!),
                // Hapus baris "Dibuat" karena field createdAt tidak ada di model
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildEditView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          DropdownButtonFormField<TransactionType>(
            value: _type,
            decoration: const InputDecoration(
              labelText: 'Tipe',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: TransactionType.income,
                child: Text('Pemasukan'),
              ),
              DropdownMenuItem(
                value: TransactionType.expense,
                child: Text('Pengeluaran'),
              ),
            ],
            onChanged: (v) =>
                setState(() => _type = v ?? TransactionType.expense),
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
          DropdownButtonFormField<String>(
            value: _categories.any((c) => c.name == _categoryCtrl.text)
                ? _categories.firstWhere((c) => c.name == _categoryCtrl.text).id
                : null,
            decoration: const InputDecoration(
              labelText: 'Kategori',
              border: OutlineInputBorder(),
            ),
            items: _categories
                .where((c) => c.type == _type)
                .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Row(
                        children: [
                          Icon(c.icon, size: 18, color: c.color),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                final cat = _categories.firstWhere((c) => c.id == v);
                setState(() => _categoryCtrl.text = cat.name);
              }
            },
            validator: (v) => _categoryCtrl.text.isEmpty ? 'Pilih kategori' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tanggal'),
            subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(_date)),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: _pickDate,
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Catatan (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancelEdit,
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
        title: Text(_isEditing ? 'Edit Transaksi' : 'Detail Transaksi'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Edit Transaksi',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
              tooltip: 'Hapus Transaksi',
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
