import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/company.dart';
import '../../models/transaction.dart' as model;
import '../../providers/company_provider.dart';
import '../../providers/time_entry_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/clock_button.dart';

class TimeTrackingScreen extends StatefulWidget {
  const TimeTrackingScreen({super.key});

  @override
  State<TimeTrackingScreen> createState() => _TimeTrackingScreenState();
}

class _TimeTrackingScreenState extends State<TimeTrackingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTicker();
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {}); // Rebuild to update elapsed time
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeProvider = context.watch<TimeEntryProvider>();
    final companyProvider = context.watch<CompanyProvider>();
    final activeEntry = timeProvider.activeEntry;
    final activeCompanies = companyProvider.activeCompanies;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active session
        if (activeEntry != null) ...[
          Card(
            color: AppTheme.incomeGreen.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.timer, size: 36, color: AppTheme.incomeGreen),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.duration(activeEntry.elapsed),
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.incomeGreen,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    activeEntry.companyName,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Since ${Formatters.time(activeEntry.clockIn)}',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ClockButton(
                    isClockedIn: true,
                    onPressed: () => _clockOut(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Company list for clocking in
        if (activeEntry == null) ...[
          Text(
            'Select a company to clock in',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          if (activeCompanies.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.business_outlined,
                        size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Text('No active companies',
                        style: TextStyle(color: Colors.grey[500])),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.companyForm),
                      child: const Text('Add Company'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...activeCompanies.map(
              (company) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      company.name[0].toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  title: Text(company.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${company.currency} ${company.payRate.toStringAsFixed(2)}'
                    '${company.payType == PayType.hourly ? "/hr" : "/mo"}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => _clockIn(context, company),
                    child: const Text('Clock In'),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),
        ],

        // Recent time entries link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Entries',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.timeLog),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (timeProvider.entries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('No entries yet',
                  style: TextStyle(color: Colors.grey[500])),
            ),
          )
        else
          ...timeProvider.entries.take(5).map(
                (entry) => ListTile(
                  dense: true,
                  leading: Icon(
                    entry.isActive ? Icons.timer : Icons.check_circle_outline,
                    color: entry.isActive ? AppTheme.incomeGreen : Colors.grey,
                    size: 20,
                  ),
                  title: Text(entry.companyName,
                      style: const TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '${Formatters.date(entry.clockIn)}  •  '
                    '${entry.durationMinutes != null ? Formatters.durationFromMinutes(entry.durationMinutes!) : "In progress"}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: entry.earnings != null
                      ? Text(Formatters.currency(entry.earnings!),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.incomeGreen,
                              fontSize: 13))
                      : null,
                ),
              ),
      ],
    );
  }

  Future<void> _clockIn(BuildContext context, Company company) async {
    await context.read<TimeEntryProvider>().clockIn(company);
  }

  Future<void> _clockOut(BuildContext context) async {
    final timeProvider = context.read<TimeEntryProvider>();
    final companyProvider = context.read<CompanyProvider>();
    final activeEntry = timeProvider.activeEntry;
    if (activeEntry == null) return;

    final company = companyProvider.findById(activeEntry.companyId);
    final rate = company?.payRate ?? 0.0;
    final completed = await timeProvider.clockOut(rate);

    if (completed != null && completed.earnings != null && mounted) {
      _showCreateIncomeDialog(context, completed.companyName,
          completed.earnings!, completed.companyId);
    }
  }

  void _showCreateIncomeDialog(
    BuildContext context,
    String companyName,
    double earnings,
    dynamic companyId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Income Entry?'),
        content: Text(
          'You earned ${Formatters.currency(earnings)} at $companyName. '
          'Would you like to add this as an income transaction?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<TransactionProvider>().add(
                    model.Transaction(
                      type: model.TransactionType.income,
                      amount: earnings,
                      category: 'Salary',
                      description: 'Clock-out earnings from $companyName',
                      companyId: companyId,
                      companyName: companyName,
                      date: DateTime.now(),
                    ),
                  );
            },
            child: const Text('Add Income'),
          ),
        ],
      ),
    );
  }
}
