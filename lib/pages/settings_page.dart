import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/services/backup_service.dart';
import 'package:uas/services/preferences_service.dart';

/// Halaman Pengaturan: mata uang, tema, backup/restore
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late PreferencesService prefs;
  String _currency = 'IDR';
  String _theme = 'system';

  @override
  void initState() {
    super.initState();
    prefs = context.read<PreferencesService>();
    _currency = prefs.currency;
    _theme = prefs.theme;
  }

  Future<void> _backup() async {
    final repo = context.read<FinanceRepository>();
    final backup = await BackupService().exportBackupJson(repo);
    final path = await BackupService().saveBackupToFile(backup);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(path.startsWith('web://') ? 'Backup siap diunduh melalui UI' : 'Backup disimpan: $path')),
    );
  }

  Future<void> _restore() async {
    final repo = context.read<FinanceRepository>();
    final payload = await BackupService().readBackupFromFile();
    await BackupService().restoreFromPayload(repo, payload);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restore selesai')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Mata uang'),
            subtitle: Text(_currency),
            trailing: DropdownButton<String>(
              value: _currency,
              items: const [
                DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp)')),
                DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _currency = v);
                await prefs.setCurrency(v);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Tema'),
            subtitle: Text(
              switch (_theme) {
                'light' => 'Terang',
                'dark' => 'Gelap',
                _ => 'Ikuti sistem',
              },
            ),
            trailing: DropdownButton<String>(
              value: _theme,
              items: const [
                DropdownMenuItem(value: 'system', child: Text('Ikuti sistem')),
                DropdownMenuItem(value: 'light', child: Text('Terang')),
                DropdownMenuItem(value: 'dark', child: Text('Gelap')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                setState(() => _theme = v);
                await prefs.setTheme(v);
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Backup & Restore', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: OutlinedButton.icon(onPressed: _backup, icon: const Icon(Icons.download), label: const Text('Backup'))),
                    const SizedBox(width: 12),
                    Expanded(child: FilledButton.icon(onPressed: _restore, icon: const Icon(Icons.upload), label: const Text('Restore'))),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}