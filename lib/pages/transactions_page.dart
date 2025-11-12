import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/pages/transaction_form_page.dart';
import 'package:uas/repositories/finance_repository.dart';

/// Halaman daftar transaksi (pemasukan/pengeluaran)
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
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

  Future<void> _add() async {
    final res = await Navigator.of(context).push<FinanceTransaction>(
      MaterialPageRoute(builder: (_) => const TransactionFormPage()),
    );
    if (res != null) {
      await context.read<FinanceRepository>().addTransaction(res);
      await _load();
    }
  }

  Future<void> _delete(int id) async {
    await context.read<FinanceRepository>().deleteTransaction(id);
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
          itemCount: _txns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final t = _txns[i];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.type == TransactionType.income ? Colors.green : Colors.red,
                  child: Icon(t.type == TransactionType.income ? Icons.call_received : Icons.call_made, color: Colors.white),
                ),
                title: Text(t.category),
                subtitle: Text(DateFormat('dd MMM yyyy').format(t.date)),
                trailing: Text(fmt.format(t.amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                onLongPress: t.id == null ? null : () => _delete(t.id!),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _add, child: const Icon(Icons.add)),
    );
  }
}