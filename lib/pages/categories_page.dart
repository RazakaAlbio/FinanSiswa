import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/category.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/pages/category_form_page.dart';
import 'package:uas/repositories/category_repository.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<CategoryRepository>();
    final items = await repo.getCategories();
    setState(() => _categories = items);
  }

  Future<void> _add() async {
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(builder: (_) => const CategoryFormPage()),
    );
    if (result != null) {
      await context.read<CategoryRepository>().addCategory(result);
      _load();
    }
  }

  Future<void> _edit(Category category) async {
    final result = await Navigator.push<Category>(
      context,
      MaterialPageRoute(builder: (_) => CategoryFormPage(category: category)),
    );
    if (result != null) {
      await context.read<CategoryRepository>().updateCategory(result);
      _load();
    }
  }

  Future<void> _delete(Category category) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kategori?'),
        content: Text('Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<CategoryRepository>().deleteCategory(category.id);
      _load();
    }
  }

  Widget _buildList(TransactionType type) {
    final filtered = _categories.where((c) => c.type == type).toList();
    
    if (filtered.isEmpty) {
      return const Center(child: Text('Belum ada kategori'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final cat = filtered[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: cat.color.withOpacity(0.2),
            child: Icon(cat.icon, color: cat.color),
          ),
          title: Text(cat.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _edit(cat),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _delete(cat),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pengeluaran'),
            Tab(text: 'Pemasukan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(TransactionType.expense),
          _buildList(TransactionType.income),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
