import 'package:flutter/material.dart';

import '../models/company.dart';

class CompanyTile extends StatelessWidget {
  final Company company;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActive;

  const CompanyTile({
    super.key,
    required this.company,
    this.onTap,
    this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: company.isActive
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          child: Text(
            company.name.isNotEmpty ? company.name[0].toUpperCase() : '?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: company.isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey,
            ),
          ),
        ),
        title: Text(
          company.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: company.isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Text(
          '${company.payType.name.toUpperCase()}  •  '
          '${company.currency} ${company.payRate.toStringAsFixed(2)}'
          '${company.payType == PayType.hourly ? '/hr' : '/mo'}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: Icon(
            company.isActive
                ? Icons.toggle_on_rounded
                : Icons.toggle_off_rounded,
            color: company.isActive
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            size: 32,
          ),
          onPressed: onToggleActive,
        ),
      ),
    );
  }
}
