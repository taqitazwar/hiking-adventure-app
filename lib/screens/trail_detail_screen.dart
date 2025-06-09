// lib/screens/trail_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/trail.dart';

class TrailDetailPage extends StatelessWidget {
  final Trail trail;
  const TrailDetailPage({ required this.trail, super.key });

  @override
  Widget build(BuildContext context) {
    // Reference to the same storage path used in TrailCard
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('trails/${trail.id}/main_photo.jpg');

    return Scaffold(
      appBar: AppBar(
        title: Text(trail.name),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Big header image with FutureBuilder
          SizedBox(
            width: double.infinity,
            height: 300,
            child: FutureBuilder<String>(
              future: imageRef.getDownloadURL(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  );
                }
                // once we have a URL, show the image
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  child: Image.network(
                    snap.data!,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          // Details beneath in a scrollable area
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trail.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Location: ${trail.location}'),
                  Text('Difficulty: ${trail.difficulty}'),
                  Text('Length: ${trail.length.toStringAsFixed(1)} km'),
                  Text('Estimated time: ${trail.time}'),
                  const SizedBox(height: 16),
                  Text(
                    trail.description ?? 'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
