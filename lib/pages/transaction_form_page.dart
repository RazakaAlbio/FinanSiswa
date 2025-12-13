import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/models/category.dart';
import 'package:uas/models/category.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/repositories/category_repository.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/repositories/budget_repository.dart';
import 'package:uas/models/budget.dart';
import 'package:uas/pages/categories_page.dart';

/// Form transaksi dengan validasi input
class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});

  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _customCategoryCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  String _uiType = 'expense'; // 'income', 'expense', 'savings'
  DateTime _date = DateTime.now();
  List<Category> _categories = [];
  List<SavingGoal> _savingGoals = [];
  List<Budget> _budgets = [];
  String? _selectedCategoryId;
  int? _selectedSavingGoalId;
  int? _selectedBudgetId;

  @override
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadSavingGoals();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    final repo = context.read<FinanceRepository>();
    final items = await repo.listBudgets();
    setState(() => _budgets = items);
  }

  Future<void> _loadCategories() async {
    final repo = context.read<CategoryRepository>();
    final items = await repo.getCategories();
    setState(() => _categories = items);
  }

  Future<void> _loadSavingGoals() async {
    final repo = context.read<FinanceRepository>();
    final items = await repo.listSavingGoals();
    setState(() => _savingGoals = items);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _customCategoryCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountCtrl.text.replaceAll(',', '.'));
    
    if (_uiType == 'savings') {
       // Handle Savings Transaction
       if (_selectedSavingGoalId == null) return;
       final goal = _savingGoals.firstWhere((g) => g.id == _selectedSavingGoalId);
       
       // Update Saving Goal
       final repo = context.read<FinanceRepository>();
       final updatedGoal = goal.copyWith(savedAmount: goal.savedAmount + amount);
       await repo.updateSavingGoal(updatedGoal);

       // Create Transaction
       final txn = FinanceTransaction(
         amount: amount,
         category: 'Tabungan',
         type: TransactionType.expense,
         date: _date,
         note: _noteCtrl.text.trim().isEmpty ? 'Tabungan: ${goal.name}' : _noteCtrl.text.trim(),
       );
       if (!mounted) return;
       Navigator.of(context).pop(txn);
    } else {
      // Normal Transaction
      String categoryName;
      if (_selectedCategoryId == 'custom') {
        if (_selectedBudgetId == null) return;
        categoryName = _budgets.firstWhere((b) => b.id == _selectedBudgetId).name;
      } else {
        categoryName = _categories.firstWhere((c) => c.id == _selectedCategoryId).name;
      }

      final txn = FinanceTransaction(
        amount: amount,
        category: categoryName,
        type: _type,
        date: _date,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
      Navigator.of(context).pop(txn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _uiType,
                decoration: const InputDecoration(
                  labelText: 'Tipe',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                  DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                  DropdownMenuItem(value: 'savings', child: Text('Tabungan')),
                ],
                onChanged: (v) {
                  setState(() {
                    _uiType = v ?? 'expense';
                    if (_uiType == 'income') _type = TransactionType.income;
                    else _type = TransactionType.expense;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Nominal (${fmt.currencySymbol})',
                  border: const OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty)
                    return 'Nominal wajib diisi';
                  final parsed = double.tryParse(v.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0)
                    return 'Nominal harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              if (_uiType == 'savings')
                if (_savingGoals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Belum ada target tabungan. Buat target terlebih dahulu di menu Tabungan.', style: TextStyle(color: Colors.red)),
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _savingGoals.any((g) => g.id == _selectedSavingGoalId) ? _selectedSavingGoalId : null,
                    decoration: const InputDecoration(
                      labelText: 'Target Tabungan',
                      border: OutlineInputBorder(),
                    ),
                    items: _savingGoals.map((g) => DropdownMenuItem(
                      value: g.id,
                      child: Text(g.name),
                    )).toList(),
                    onChanged: (v) => setState(() => _selectedSavingGoalId = v),
                    validator: (v) => v == null ? 'Pilih target tabungan' : null,
                  )
              else
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              ..._categories
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
                                      )),
                              const DropdownMenuItem(
                                value: 'custom',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('Lainnya (Custom)'),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (v) => setState(() => _selectedCategoryId = v),
                            validator: (v) => v == null ? 'Pilih kategori' : null,
                          ),
                          if (_selectedCategoryId == 'custom') ...[
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: _selectedBudgetId,
                              decoration: const InputDecoration(
                                labelText: 'Pilih Anggaran (Budget)',
                                border: OutlineInputBorder(),
                                helperText: 'Pilih anggaran yang sesuai',
                              ),
                              items: _budgets.map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name),
                              )).toList(),
                              onChanged: (v) => setState(() => _selectedBudgetId = v),
                              validator: (v) {
                                if (_selectedCategoryId == 'custom' && v == null) {
                                  return 'Pilih anggaran';
                                }
                                return null;
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Color(0xFF00BFA5)),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CategoriesPage()),
                        );
                        _loadCategories();
                      },
                      tooltip: 'Kelola Kategori',
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal'),
                subtitle: Text(
                  DateFormat('dd MMM yyyy', 'id_ID').format(_date),
                ),
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
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Simpan Transaksi',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
