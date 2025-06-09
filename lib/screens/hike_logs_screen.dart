import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/hike_log_service.dart';
import '../models/hike_log.dart';

class HikeLogsScreen extends StatelessWidget {
  const HikeLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Hiking Logs')),
      body: StreamBuilder<List<HikeLog>>(
        stream: HikeLogService().streamLogs(),
        builder: (context, snap) {
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snap.data!;
          if (logs.isEmpty) {
            return const Center(child: Text('No logs yet. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              return ListTile(
                title: Text(log.notes),
                subtitle: Text(
                  '${log.date.toLocal().toIso8601String().split("T").first} • ${log.rating}/5',
                ),
                onTap: () {
                  // Navigate to the edit form, passing the log as extra
                  context.push(
                    '/logs/${log.id}/edit',
                    extra: log,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to the "new log" form (push onto stack)
          context.push('/logs/new');
        },
      ),
    );
  }
}
