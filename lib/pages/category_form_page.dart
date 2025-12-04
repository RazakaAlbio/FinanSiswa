import 'package:flutter/material.dart';
import 'package:uas/models/category.dart';
import 'package:uas/models/transaction.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  TransactionType _type = TransactionType.expense;
  IconData _selectedIcon = Icons.category;
  Color _selectedColor = Colors.blue;

  final List<IconData> _availableIcons = [
    Icons.restaurant,
    Icons.directions_bus,
    Icons.movie,
    Icons.local_hospital,
    Icons.school,
    Icons.shopping_bag,
    Icons.sports_soccer,
    Icons.flight,
    Icons.home,
    Icons.work,
    Icons.pets,
    Icons.wifi,
    Icons.phone,
    Icons.attach_money,
    Icons.card_giftcard,
    Icons.savings,
  ];

  final List<Color> _availableColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameCtrl.text = widget.category!.name;
      _type = widget.category!.type;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final category = Category(
      id: widget.category?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      type: _type,
      iconCode: _selectedIcon.codePoint,
      colorValue: _selectedColor.value,
    );

    Navigator.pop(context, category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category == null ? 'Tambah Kategori' : 'Edit Kategori'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Kategori',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransactionType>(
              value: _type,
              decoration: const InputDecoration(
                labelText: 'Tipe',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: TransactionType.expense,
                  child: Text('Pengeluaran'),
                ),
                DropdownMenuItem(
                  value: TransactionType.income,
                  child: Text('Pemasukan'),
                ),
              ],
              onChanged: widget.category == null 
                  ? (v) => setState(() => _type = v!) 
                  : null, // Disable changing type for existing category
            ),
            const SizedBox(height: 24),
            const Text('Pilih Ikon', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableIcons.map((icon) {
                final isSelected = _selectedIcon == icon;
                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00BFA5).withOpacity(0.2) : null,
                      border: isSelected ? Border.all(color: const Color(0xFF00BFA5), width: 2) : Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: isSelected ? const Color(0xFF00BFA5) : Colors.grey),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Pilih Warna', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
