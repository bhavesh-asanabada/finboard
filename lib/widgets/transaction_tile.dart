import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? AppTheme.incomeGreen : AppTheme.expenseRed;
    final prefix = isIncome ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: color,
          size: 20,
        ),
      ),
      title: Text(
        transaction.category,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        transaction.description?.isNotEmpty == true
            ? transaction.description!
            : Formatters.date(transaction.date),
        style: TextStyle(color: Colors.grey[600], fontSize: 13),
      ),
      trailing: Text(
        '$prefix${Formatters.currency(transaction.amount)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
