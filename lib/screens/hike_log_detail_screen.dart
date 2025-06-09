// lib/screens/hike_log_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/hike_log.dart';

class HikeLogDetailScreen extends StatelessWidget {
  final HikeLog log;
  const HikeLogDetailScreen({ required this.log, super.key });

  Future<void> _deleteLog(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('my_completed_hikes')
        .doc(log.id)
        .delete();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike Log Details'),
        leading: BackButton(onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Log',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dctx) => AlertDialog(
                  title: const Text('Delete this log?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dctx, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(dctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _deleteLog(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show the trail name instead of its ID:
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('trails')
                  .doc(log.trailId)
                  .get(),
              builder: (ctx, trailSnap) {
                if (trailSnap.connectionState == ConnectionState.waiting) {
                  return const Text('Trail: loading…');
                }
                if (!trailSnap.hasData || !trailSnap.data!.exists) {
                  return const Text('Trail: unknown');
                }
                final data = trailSnap.data!.data()! as Map<String, dynamic>;
                return Text(
                  data['name'] as String,
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),

            const SizedBox(height: 12),

            // Date
            Text(
              'Date: ${log.date.toLocal().toIso8601String().split("T")[0]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            // Rating
            Text(
              'Rating: ${log.rating} ⭐',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            // Photo
            if (log.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  log.photoUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 12),

            // Notes
            Text(
              'Notes:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              log.notes.isNotEmpty ? log.notes : 'No notes provided.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
