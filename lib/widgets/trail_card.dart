import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/trail.dart';

class TrailCard extends StatelessWidget {
  final Trail trail;
  const TrailCard(this.trail, {super.key});

  @override
  Widget build(BuildContext context) {
    final imageRef = FirebaseStorage.instance
        .ref()
        .child('trails/${trail.id}/main_photo.jpg');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            FutureBuilder<String>(
              future: imageRef.getDownloadURL(),
              builder: (ctx, snap) {
                if (snap.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      snap.data!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image,
                      size: 40, color: Colors.grey),
                );
              },
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trail.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trail.location} · ${trail.difficulty} · ${trail.length.toStringAsFixed(1)} km',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
