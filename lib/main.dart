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
import 'package:uas/repositories/budget_repository.dart';
import 'package:uas/repositories/savings_repository.dart';
import 'package:uas/repositories/category_repository.dart';
import 'package:uas/services/notification_service.dart';
import 'package:uas/services/preferences_service.dart';
import 'package:uas/theme/app_theme.dart';
import 'package:uas/pages/transactions_page.dart'; 
import 'package:uas/pages/budgets_page.dart'; 
import 'package:uas/pages/savings_page.dart'; 
import 'package:uas/pages/belajar_page.dart'; 
import 'package:uas/services/navigation_service.dart';
import 'package:uas/pages/welcome_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print('FinanSiswa: App Started with Fixes');
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
        ChangeNotifierProvider<PreferencesService>.value(value: prefs),
        Provider<NotificationService>.value(value: notif),
        ChangeNotifierProvider<NavigationService>(
          create: (_) => NavigationService(),
        ),
        Provider<SavingsRepository>(create: (_) => SavingsRepository()),
        Provider<BudgetRepository>(create: (_) => BudgetRepository()),
        Provider<CategoryRepository>(create: (_) => CategoryRepository()),
      ],
      child: Consumer<PreferencesService>(
        builder: (context, p, _) {
          final themeMode = switch (p.theme) {
            'dark' => ThemeMode.dark,
            'light' => ThemeMode.light,
            _ => ThemeMode.light,
          };
          return MaterialApp(
            title: 'FinanSiswa',
            locale: const Locale('id', 'ID'),
            supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: buildAppTheme(dark: false),
            darkTheme: buildAppTheme(dark: true),
            themeMode: themeMode,
            home: _ready
                ? (p.isFirstLaunch ? const WelcomePage() : const HomeShell())
                : const _LoadingScreen(),
          );
        },
      ),
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
    TransactionsPage(), // Laporan
    SavingsPage(), // Target
    BudgetsPage(), // Budget
    BelajarPage(), // Belajar
  ];

  @override
  Widget build(BuildContext context) {
    final navigationService = context.watch<NavigationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanSiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
        ],
      ),
      body: _pages[navigationService.currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationService.currentIndex,
        onTap: (i) => navigationService.setCurrentIndex(i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.savings), label: 'Target'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Budget'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Belajar'),
        ],
      ),
    );
  }
}

// Tambahkan halaman placeholder untuk Belajar
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Halaman Belajar - Dalam Pengembangan'));
  }
}
