import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'config/routes.dart';
import 'models/company.dart';
import 'models/transaction.dart';
import 'services/mongodb_service.dart';
import 'providers/company_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/time_entry_provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/companies/company_form_screen.dart';
import 'screens/companies/company_list_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/time_tracking/time_log_screen.dart';
import 'screens/time_tracking/time_tracking_screen.dart';
import 'screens/transactions/transaction_form_screen.dart';
import 'screens/transactions/transaction_list_screen.dart';

class FinBoardApp extends StatelessWidget {
  const FinBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = MongoDbService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompanyProvider(db)),
        ChangeNotifierProvider(create: (_) => TimeEntryProvider(db)),
        ChangeNotifierProvider(create: (_) => TransactionProvider(db)),
        ChangeNotifierProxyProvider2<TransactionProvider, TimeEntryProvider,
            DashboardProvider>(
          create: (ctx) => DashboardProvider(
            ctx.read<TransactionProvider>(),
            ctx.read<TimeEntryProvider>(),
          ),
          update: (_, txnProvider, timeProvider, dashboard) => dashboard!,
        ),
      ],
      child: MaterialApp(
        title: 'FinBoard',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.setup: (_) => const SetupScreen(),
          AppRoutes.home: (_) => const HomeShell(),
          AppRoutes.timeLog: (_) => const TimeLogScreen(),
        },
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.companyForm:
              final company = settings.arguments as Company?;
              return MaterialPageRoute(
                builder: (_) => CompanyFormScreen(company: company),
              );
            case AppRoutes.transactionForm:
              final txn = settings.arguments as Transaction?;
              return MaterialPageRoute(
                builder: (_) => TransactionFormScreen(transaction: txn),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}

/// Bottom-navigation shell for the main screens.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  bool _dataLoaded = false;

  final _pages = const <Widget>[
    DashboardScreen(),
    CompanyListScreen(),
    TimeTrackingScreen(),
    TransactionListScreen(),
    SettingsScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_dataLoaded) {
      _dataLoaded = true;
      // Fetch initial data from MongoDB
      context.read<CompanyProvider>().fetchAll();
      context.read<TimeEntryProvider>().fetchAll();
      context.read<TransactionProvider>().fetchAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          if (_currentIndex == 2) // Time Tracking tab
            IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Time Log',
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.timeLog),
            ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Companies',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Time',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget? _buildFAB() {
    switch (_currentIndex) {
      case 1: // Companies
        return FloatingActionButton(
          heroTag: 'add_company',
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.companyForm),
          child: const Icon(Icons.add),
        );
      case 3: // Transactions
        return FloatingActionButton(
          heroTag: 'add_txn',
          onPressed: () =>
              Navigator.of(context).pushNamed(AppRoutes.transactionForm),
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }

  static const _titles = [
    'Dashboard',
    'Companies',
    'Time Tracking',
    'Transactions',
    'Settings',
  ];
}
