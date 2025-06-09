import 'package:cloud_firestore/cloud_firestore.dart';

/// A user’s completed hike log entry.
class HikeLog {
  final String id;
  final String trailId;
  final DateTime date;
  final String notes;
  final int rating;
  final String? photoUrl;

  HikeLog({
    required this.id,
    required this.trailId,
    required this.date,
    required this.notes,
    required this.rating,
    this.photoUrl,
  });

  factory HikeLog.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return HikeLog(
      id: doc.id,
      trailId: data['trailId'] as String,
      date: (data['date'] as Timestamp).toDate(),
      notes: data['notes'] as String,
      rating: (data['rating'] as num).toInt(),
      photoUrl: data['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'trailId': trailId,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'rating': rating,
        'photoUrl': photoUrl,
      };
}
