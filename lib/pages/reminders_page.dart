import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uas/models/reminder.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/services/notification_service.dart';

/// Halaman Pengingat Pembayaran/Tagihan
class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<FinanceRepository>();
    final items = await repo.listReminders();
    setState(() => _reminders = items);
  }

  Future<void> _addReminderDialog() async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime due = DateTime.now().add(const Duration(days: 1));
    ReminderRepeat repeat = ReminderRepeat.none;
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Reminder>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Tambah Pengingat'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(labelText: 'Judul'),
                    validator: (v) => (v == null || v.trim().length < 2) ? 'Judul minimal 2 karakter' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Nominal (opsional)'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final parsed = double.tryParse(v.replaceAll(',', '.'));
                      if (parsed == null || parsed < 0) return 'Nominal tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Jatuh Tempo'),
                    subtitle: Text(DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(due)),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: due,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) {
                          final t = await showTimePicker(context: ctx, initialTime: TimeOfDay.fromDateTime(due));
                          final dt = DateTime(d.year, d.month, d.day, t?.hour ?? 9, t?.minute ?? 0);
                          due = dt;
                          (ctx as Element).markNeedsBuild();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ReminderRepeat>(
                    value: repeat,
                    decoration: const InputDecoration(labelText: 'Pengulangan'),
                    items: const [
                      DropdownMenuItem(value: ReminderRepeat.none, child: Text('Tidak ada')),
                      DropdownMenuItem(value: ReminderRepeat.daily, child: Text('Harian')),
                      DropdownMenuItem(value: ReminderRepeat.weekly, child: Text('Mingguan')),
                      DropdownMenuItem(value: ReminderRepeat.monthly, child: Text('Bulanan')),
                    ],
                    onChanged: (v) => repeat = v ?? ReminderRepeat.none,
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
                final amt = amountCtrl.text.trim().isEmpty ? null : double.parse(amountCtrl.text.replaceAll(',', '.'));
                final r = Reminder(title: titleCtrl.text.trim(), amount: amt, dueDate: due, repeat: repeat);
                Navigator.pop(ctx, r);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    if (result != null) {
      final repo = context.read<FinanceRepository>();
      final id = await repo.addReminder(result);
      final notif = context.read<NotificationService>();
      await notif.scheduleReminderNotification(result.copyWith(id: id));
      await _load();
    }
  }

  Future<void> _togglePaid(Reminder r) async {
    final repo = context.read<FinanceRepository>();
    final updated = r.copyWith(isPaid: !r.isPaid);
    await repo.updateReminder(updated);
    if (updated.isPaid && updated.id != null) {
      await context.read<NotificationService>().cancel(updated.id!);
    }
    await _load();
  }

  Future<void> _delete(int id) async {
    await context.read<FinanceRepository>().deleteReminder(id);
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
          itemCount: _reminders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (ctx, i) {
            final r = _reminders[i];
            final repeatStr = {
              ReminderRepeat.none: 'Sekali',
              ReminderRepeat.daily: 'Harian',
              ReminderRepeat.weekly: 'Mingguan',
              ReminderRepeat.monthly: 'Bulanan',
            }[r.repeat]!;
            return Card(
              child: ListTile(
                leading: Icon(r.isPaid ? Icons.check_circle : Icons.schedule, color: r.isPaid ? Colors.green : Colors.orange),
                title: Text(r.title),
                subtitle: Text('Jatuh tempo: ${DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(r.dueDate)} • $repeatStr'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(r.amount == null ? '-' : fmt.format(r.amount)),
                  ],
                ),
                onTap: () => _togglePaid(r),
                onLongPress: r.id == null ? null : () => _delete(r.id!),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _addReminderDialog, child: const Icon(Icons.add)),
    );
  }
}