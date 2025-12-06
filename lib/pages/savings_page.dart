import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uas/models/saving_goal.dart';
import 'package:uas/models/transaction.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/pages/savings_form_page.dart';
import 'package:uas/pages/transaction_form_page.dart';

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
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Nama minimal 2 karakter'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Target nominal',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Target wajib diisi';
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed <= 0)
                        return 'Target harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: savedCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Nominal terkumpul',
                    ),
                    validator: (v) {
                      final parsed =
                          double.tryParse(v?.replaceAll(',', '.') ?? '0') ?? 0;
                      if (parsed < 0) return 'Nominal tidak boleh negatif';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Batas waktu (opsional)'),
                    subtitle: Text(
                      deadline == null
                          ? '-'
                          : DateFormat(
                              'dd MMM yyyy',
                              'id_ID',
                            ).format(deadline!),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: deadline ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              deadline = picked;
                              (ctx as StatefulElement).markNeedsBuild();
                            }
                          },
                        ),
                        if (deadline != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              deadline = null;
                              (ctx as StatefulElement).markNeedsBuild();
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
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final goal = SavingGoal(
                  name: nameCtrl.text.trim(),
                  targetAmount: double.parse(
                    targetCtrl.text.replaceAll(',', '.'),
                  ),
                  savedAmount: double.parse(
                    savedCtrl.text.replaceAll(',', '.'),
                  ),
                  deadline: deadline,
                );
                Navigator.pop(ctx, goal);
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target?'),
        content: const Text('Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<FinanceRepository>().deleteSavingGoal(id);
      await _load();
    }
  }

  Future<void> _edit(SavingGoal goal) async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavingsFormPage(goal: goal),
      ),
    );
    if (updated == true) await _load();
  }

  Future<void> _showAddFundsDialog(SavingGoal goal) async {
    // Navigate to TransactionFormPage with type 'savings' and this goal selected
    // Note: Since TransactionFormPage handles the logic, we just need to navigate to it.
    // However, TransactionFormPage doesn't currently accept arguments to pre-fill.
    // We can either modify TransactionFormPage to accept arguments or just let the user select 'Tabungan' and the goal.
    // Given the request "merujuk pada tambah transaksi bagian tabungan", it implies using that form.
    // Ideally we should pre-fill it, but for now let's just open the form and maybe show a snackbar or let the user know.
    // Actually, I can pass arguments if I modify TransactionFormPage constructor, but I'll stick to the user request which says "merujuk pada tambah transaksi".
    // Let's try to just open the form.
    
    // BETTER APPROACH: Modify TransactionFormPage to accept optional initial values?
    // Or just open it. The user said "bagian tambah dana nya merujuk pada tambah transaksi bagian tabungan".
    // This could mean "use the same logic" or "go to that page".
    // I will navigate to TransactionFormPage.
    
    final res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TransactionFormPage(), // Ideally pass initialType: 'savings', initialGoalId: goal.id
      ),
    );
    
    if (res != null) {
      await context.read<FinanceRepository>().addTransaction(res);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // HEADER ORANGE - PERSIS PROTOTYPE
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              backgroundColor: const Color(0xFFFF9800),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Tabungan',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Wujudkan impianmu dengan menabung',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BUAT TARGET BARU BUTTON
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: FilledButton.icon(
                  onPressed: () async {
                    final created = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SavingsFormPage(),
                      ),
                    );
                    if (created == true) await _load();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Buat Target Baru'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF00BFA5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            // LIST GOALS ATAU PLACEHOLDER JIKA KOSONG
            if (_goals.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.savings_outlined, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada target tabungan',
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buat target baru untuk mulai menabung!',
                        style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final g = _goals[i];
                  final progress = g.targetAmount > 0
                      ? g.savedAmount / g.targetAmount
                      : 0.0;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: _buildGoalCard(
                      icon: Icons
                          .flight, // Dummy icon, bisa diganti per goal jika ada data
                      title: g.name,
                      subtitle: g.deadline != null
                          ? DateFormat('MMM yyyy', 'id_ID').format(g.deadline!)
                          : 'Bulan Tahun',
                      progress: progress,
                      saved: g.savedAmount,
                      target: g.targetAmount,
                      percentage: (progress * 100).round(),
                      showDelete: g.id != null,
                      onDelete: g.id != null ? () => _delete(g.id!) : null,
                      onEdit: g.id != null ? () => _edit(g) : null,
                      onAddFunds: g.id != null ? () => _showAddFundsDialog(g) : null,
                      deadline: g.deadline,
                    ),
                  );
                }, childCount: _goals.length),
              ),

            // KARTU MOTIVASI BAWAH
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(
                            0xFFFF9800,
                          ).withOpacity(0.2),
                          child: const Icon(
                            Icons.lightbulb_outline,
                            color: Color(0xFFFF9800),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kenapa Harus Punya Target?',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Target tabungan membantumu tetap termotivasi dan fokus menabung. Mulai dengan target kecil.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPER UNTUK GOAL CARD
  Widget _buildGoalCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required double saved,
    required double target,
    required int percentage,
    required bool showDelete,
    VoidCallback? onDelete,
    VoidCallback? onEdit,
    VoidCallback? onAddFunds,
    DateTime? deadline,
  }) {
    final fmt = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFmt = DateFormat('dd MMM yyyy', 'id_ID');
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF00BFA5).withOpacity(0.1),
                  child: Icon(icon, color: const Color(0xFF00BFA5), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (showDelete) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: 'Edit Target',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Hapus Target',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fmt.format(saved),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  fmt.format(target),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sisa: ${fmt.format(target - saved)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (deadline != null)
                  Text(
                    'Tenggat: ${dateFmt.format(deadline)}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
