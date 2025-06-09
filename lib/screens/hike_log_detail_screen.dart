// lib/screens/hike_log_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hike_log.dart';

class HikeLogDetailScreen extends StatelessWidget {
  final HikeLog log;
  const HikeLogDetailScreen({ required this.log, super.key });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hike Log Details'),          // no ID here
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Show the trail name instead of its ID:
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

            // 2) Date
            Text(
              'Date: ${log.date.toLocal().toIso8601String().split("T")[0]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            // 3) Rating
            Text(
              'Rating: ${log.rating} ⭐',
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            // 4) Photo
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

            // 5) Notes
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
