import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../config/app_theme.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/summary_card.dart';
import '../../widgets/transaction_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(
      builder: (context, dashboard, _) {
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<TransactionProvider>().fetchAll();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                Formatters.monthYear(DateTime.now()),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),

              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Income',
                      value: Formatters.currency(dashboard.monthlyIncome),
                      icon: Icons.arrow_downward_rounded,
                      color: AppTheme.incomeGreen,
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      title: 'Expenses',
                      value: Formatters.currency(dashboard.monthlyExpense),
                      icon: Icons.arrow_upward_rounded,
                      color: AppTheme.expenseRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Net Balance',
                      value: Formatters.currency(dashboard.monthlyBalance),
                      icon: Icons.account_balance_wallet_outlined,
                      color: dashboard.monthlyBalance >= 0
                          ? AppTheme.incomeGreen
                          : AppTheme.expenseRed,
                    ),
                  ),
                  Expanded(
                    child: SummaryCard(
                      title: 'Time Earnings',
                      value: Formatters.currency(dashboard.totalTimeEarnings),
                      icon: Icons.timer_outlined,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Expense breakdown chart
              if (dashboard.categoryBreakdown.isNotEmpty) ...[
                Text(
                  'Expense Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: _buildPieChart(dashboard.categoryBreakdown),
                ),
                const SizedBox(height: 24),
              ],

              // Recent transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (dashboard.isClockedIn)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.incomeGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer, size: 14,
                              color: AppTheme.incomeGreen),
                          SizedBox(width: 4),
                          Text(
                            'Clocked In',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.incomeGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              if (dashboard.recentTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'No transactions yet',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...dashboard.recentTransactions.map(
                  (t) => TransactionTile(transaction: t),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPieChart(Map<String, double> breakdown) {
    final colors = [
      const Color(0xFF42A5F5),
      const Color(0xFFEF5350),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFF26C6DA),
      const Color(0xFFEC407A),
      const Color(0xFF8D6E63),
      const Color(0xFF78909C),
    ];

    final entries = breakdown.entries.toList();
    final total = entries.fold(0.0, (s, e) => s + e.value);

    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30,
              sections: entries.asMap().entries.map((e) {
                final idx = e.key;
                final entry = e.value;
                return PieChartSectionData(
                  value: entry.value,
                  color: colors[idx % colors.length],
                  radius: 50,
                  title:
                      '${(entry.value / total * 100).toStringAsFixed(0)}%',
                  titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: entries.asMap().entries.map((e) {
            final idx = e.key;
            final entry = e.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[idx % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
