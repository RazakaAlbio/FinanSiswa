import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:uas/pages/dashboard_page.dart';
import 'package:uas/pages/transactions_page.dart';
import 'package:uas/pages/budgets_page.dart';
import 'package:uas/pages/savings_page.dart';
import 'package:uas/pages/reminders_page.dart';
import 'package:uas/pages/settings_page.dart';
import 'package:uas/repositories/finance_repository.dart';
import 'package:uas/services/notification_service.dart';
import 'package:uas/services/preferences_service.dart';
import 'package:uas/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final repo = FinanceRepository();
  final prefs = PreferencesService();
  final notif = NotificationService();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  /// Inisialisasi repository, preferences, dan notifikasi
  Future<void> _init() async {
    await repo.init();
    await prefs.init();
    await notif.init();
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FinanceRepository>.value(value: repo),
        Provider<PreferencesService>.value(value: prefs),
        Provider<NotificationService>.value(value: notif),
      ],
      child: MaterialApp(
        title: 'FinanSiswa',
        locale: const Locale('id', 'ID'),
        supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: buildAppTheme(dark: prefs.theme == 'dark'),
        home: _ready ? const HomeShell() : const _LoadingScreen(),
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Shell dengan BottomNavigation untuk halaman utama
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _pages = const [
    DashboardPage(),
    TransactionsPage(),
    BudgetsPage(),
    SavingsPage(),
    RemindersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanSiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.sync_alt), selectedIcon: Icon(Icons.sync), label: 'Transaksi'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Anggaran'),
          NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: 'Tabungan'),
          NavigationDestination(icon: Icon(Icons.notifications_none), selectedIcon: Icon(Icons.notifications), label: 'Pengingat'),
        ],
      ),
    );
  }
}