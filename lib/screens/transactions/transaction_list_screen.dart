import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../config/routes.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/transaction_tile.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  TransactionType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Transaction> filtered = provider.transactions;
        if (_typeFilter != null) {
          filtered = provider.filterByType(_typeFilter!);
        }

        return Column(
          children: [
            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _typeFilter == null,
                    onTap: () => setState(() => _typeFilter = null),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Income',
                    isSelected: _typeFilter == TransactionType.income,
                    color: AppTheme.incomeGreen,
                    onTap: () =>
                        setState(() => _typeFilter = TransactionType.income),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Expense',
                    isSelected: _typeFilter == TransactionType.expense,
                    color: AppTheme.expenseRed,
                    onTap: () =>
                        setState(() => _typeFilter = TransactionType.expense),
                  ),
                ],
              ),
            ),

            // Summary row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} transactions',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  Text(
                    'Balance: ${Formatters.currency(provider.balance)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: provider.balance >= 0
                          ? AppTheme.incomeGreen
                          : AppTheme.expenseRed,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text('No transactions',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: provider.fetchAll,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final txn = filtered[index];
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) {
                                    if (txn.id != null) {
                                      provider.delete(txn.id!);
                                    }
                                  },
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: 'Delete',
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ],
                            ),
                            child: TransactionTile(
                              transaction: txn,
                              onTap: () => Navigator.of(context).pushNamed(
                                AppRoutes.transactionForm,
                                arguments: txn,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
