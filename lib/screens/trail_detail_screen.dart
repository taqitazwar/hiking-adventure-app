import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class TrailDetailPage extends StatelessWidget {
  final String trailId;
  const TrailDetailPage({ required this.trailId, super.key });

  @override
  Widget build(BuildContext context) {
    final docRef = FirebaseFirestore.instance.collection('trails').doc(trailId);
    return Scaffold(
      appBar: AppBar(title: const Text('Trail Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: docRef.get(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || !snap.data!.exists) {
            return const Center(child: Text('Trail not found.'));
          }

          final data = snap.data!.data()! as Map<String, dynamic>;
          final name = data['name'] as String? ?? 'Unnamed trail';
          final location = data['location'] as String? ?? 'Unknown location';
          final difficulty = data['difficulty'] as String? ?? '-';
          final length = (data['length'] as num?)?.toDouble() ?? 0.0;
          final time = data['time'] as String? ?? '-';

          // Load the image URL
          final imageFuture = FirebaseStorage.instance
              .ref('trails/$trailId/main_photo.jpg')
              .getDownloadURL();

          return ListView(
            children: [
              FutureBuilder<String>(
                future: imageFuture,
                builder: (ctx, imgSnap) {
                  if (imgSnap.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (imgSnap.hasError) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image, size: 60)),
                    );
                  }
                  return Image.network(
                    imgSnap.data!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text('Location: $location'),
                    Text('Difficulty: $difficulty'),
                    Text('Length: ${length.toStringAsFixed(1)} km'),
                    Text('Est. time: $time'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
