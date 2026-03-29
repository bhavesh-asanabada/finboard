import 'package:flutter/foundation.dart';

import '../models/transaction.dart';
import 'transaction_provider.dart';
import 'time_entry_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final TransactionProvider _transactionProvider;
  final TimeEntryProvider _timeEntryProvider;

  DashboardProvider(this._transactionProvider, this._timeEntryProvider) {
    _transactionProvider.addListener(_onDataChanged);
    _timeEntryProvider.addListener(_onDataChanged);
  }

  void _onDataChanged() => notifyListeners();

  double get monthlyIncome => _transactionProvider.monthlyIncome();
  double get monthlyExpense => _transactionProvider.monthlyExpense();
  double get monthlyBalance => monthlyIncome - monthlyExpense;
  double get totalBalance => _transactionProvider.balance;

  List<Transaction> get recentTransactions {
    final all = _transactionProvider.transactions;
    return all.take(5).toList();
  }

  bool get isClockedIn => _timeEntryProvider.isClockedIn;

  Map<String, double> get categoryBreakdown {
    final monthly = _transactionProvider.currentMonthTransactions();
    final expenses =
        monthly.where((t) => t.type == TransactionType.expense).toList();
    final map = <String, double>{};
    for (final t in expenses) {
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  double get totalTimeEarnings {
    return _timeEntryProvider.entries
        .where((e) => e.earnings != null)
        .fold(0.0, (sum, e) => sum + e.earnings!);
  }

  @override
  void dispose() {
    _transactionProvider.removeListener(_onDataChanged);
    _timeEntryProvider.removeListener(_onDataChanged);
    super.dispose();
  }
}
