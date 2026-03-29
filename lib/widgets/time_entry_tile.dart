import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/time_entry.dart';
import '../utils/formatters.dart';

class TimeEntryTile extends StatelessWidget {
  final TimeEntry entry;
  final VoidCallback? onTap;

  const TimeEntryTile({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: entry.isActive
              ? AppTheme.incomeGreen.withOpacity(0.15)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          entry.isActive ? Icons.timer : Icons.timer_off_outlined,
          color: entry.isActive ? AppTheme.incomeGreen : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(
        entry.companyName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        entry.isActive
            ? 'Clocked in at ${Formatters.time(entry.clockIn)}'
            : '${Formatters.time(entry.clockIn)} – ${Formatters.time(entry.clockOut!)}  •  ${Formatters.durationFromMinutes(entry.durationMinutes ?? 0)}',
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: entry.earnings != null
          ? Text(
              Formatters.currency(entry.earnings!),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.incomeGreen,
                fontSize: 15,
              ),
            )
          : entry.isActive
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.incomeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.incomeGreen,
                    ),
                  ),
                )
              : null,
    );
  }
}
