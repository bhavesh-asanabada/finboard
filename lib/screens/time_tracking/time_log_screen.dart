import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../providers/time_entry_provider.dart';
import '../../utils/formatters.dart';
import '../../widgets/time_entry_tile.dart';

class TimeLogScreen extends StatelessWidget {
  const TimeLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Log')),
      body: Consumer<TimeEntryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_off_outlined,
                      size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No time entries yet',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }

          // Group by date
          final grouped = <String, List<dynamic>>{};
          for (final entry in provider.entries) {
            final key = Formatters.date(entry.clockIn);
            grouped.putIfAbsent(key, () => []).add(entry);
          }

          return RefreshIndicator(
            onRefresh: provider.fetchAll,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: grouped.length,
              itemBuilder: (context, index) {
                final dateKey = grouped.keys.elementAt(index);
                final entries = grouped[dateKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        dateKey,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ),
                    ...entries.map(
                      (entry) => Slidable(
                        endActionPane: ActionPane(
                          motion: const BehindMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (_) {
                                if (entry.id != null) {
                                  provider.delete(entry.id!);
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
                        child: TimeEntryTile(entry: entry),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
