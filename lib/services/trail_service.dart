// lib/services/trail_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/trail.dart';

class TrailService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// Streams all trails, ordered by name
  Stream<List<Trail>> streamTrails() {
    return _firestore
        .collection('trails')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
      final data = doc.data();
      return Trail(
        id: doc.id,
        name: data['name'] as String? ?? 'Unnamed Trail',
        location: data['location'] as String? ?? 'Unknown',
        difficulty: data['difficulty'] as String? ?? '-',
        length: (data['length'] as num?)?.toDouble() ?? 0.0,
        time: data['time'] as String? ?? '-',
        description: data['description'] as String? ?? '',
      );
    }).toList());
  }

  /// Fetches a single trail by ID, including its image URL
  Future<Trail> fetchTrailById(String id) async {
    final doc = await _firestore.collection('trails').doc(id).get();
    if (!doc.exists) throw Exception('Trail not found');
    final data = doc.data()!;

    String? imageUrl;
    try {
      imageUrl = await _storage.ref('trails/$id/main_photo.jpg').getDownloadURL();
    } catch (_) {
      imageUrl = null;
    }

    return Trail(
      id: id,
      name: data['name'] as String? ?? 'Unnamed Trail',
      location: data['location'] as String? ?? 'Unknown',
      difficulty: data['difficulty'] as String? ?? '-',
      length: (data['length'] as num?)?.toDouble() ?? 0.0,
      time: data['time'] as String? ?? '-',
      description: data['description'] as String? ?? '',
      imageUrl: imageUrl,
    );
  }

  /// For forms or basic screens: a stream of all trails
  Stream<List<Trail>> getTrails() => streamTrails();

  /// Client-side filtering; you can pass null to ignore a filter
  Stream<List<Trail>> getTrailsFiltered({
    String? difficulty,
    double? minLength,
    double? maxLength,
  }) {
    return streamTrails().map((list) {
      return list.where((t) {
        if (difficulty != null && t.difficulty != difficulty) return false;
        if (minLength != null && t.length < minLength) return false;
        if (maxLength != null && t.length > maxLength) return false;
        return true;
      }).toList();
    });
  }
}
