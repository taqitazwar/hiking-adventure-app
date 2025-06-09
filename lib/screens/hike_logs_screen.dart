// lib/screens/hike_logs_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';           // ← Add this
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hike_log.dart';

class HikeLogsScreen extends StatelessWidget {
  const HikeLogsScreen({super.key});

  /// Streams the current user's logs from Firestore
  Stream<List<HikeLog>> fetchUserLogs() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('my_completed_hikes')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final d = doc.data();
      return HikeLog(
        id: doc.id,
        trailId: d['trailId'] as String,
        date: (d['date'] as Timestamp).toDate(),
        rating: d['rating'] as int,
        notes: (d['notes'] as String?) ?? '',
        photoUrl: d['photoUrl'] as String?,
      );
    }).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Hike Logs')),
      body: StreamBuilder<List<HikeLog>>(
        stream: fetchUserLogs(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final logs = snap.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No logs yet. Tap + to add one.'));
          }
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              return ListTile(
                title: FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('trails')
                      .doc(log.trailId)
                      .get(),
                  builder: (ctx, trailSnap) {
                    if (!trailSnap.hasData) {
                      return const Text('Loading trail…');
                    }
                    final trailData =
                    trailSnap.data!.data()! as Map<String, dynamic>;
                    return Text(trailData['name'] as String);
                  },
                ),
                subtitle: Text(
                  '${log.date.toLocal().toIso8601String().split("T")[0]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      tooltip: 'View',
                      onPressed: () {
                        context.push('/logs/${log.id}', extra: log);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () {
                        context.push('/logs/${log.id}/edit', extra: log);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/logs/new'),
      ),
    );
  }
}
