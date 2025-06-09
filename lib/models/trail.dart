import 'package:cloud_firestore/cloud_firestore.dart';

/// A hiking trail fetched from Firestore.
class Trail {
  final String id;
  final String name;
  final String location;
  final String difficulty;
  final double length;
  final String time;
  final String description;
  final String? imageUrl; // later, we’ll load this from Storage

  Trail({
    required this.id,
    required this.name,
    required this.location,
    required this.difficulty,
    required this.length,
    required this.time,
    required this.description,
    this.imageUrl,
  });

  /// Construct a Trail from a Firestore document snapshot.
  factory Trail.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Trail(
      id: doc.id,
      name: data['name'] as String,
      location: data['location'] as String,
      difficulty: data['difficulty'] as String,
      length: (data['length'] as num).toDouble(),
      time: data['time'] as String,
      description: data['description'] as String,
      imageUrl: null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Trail && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
