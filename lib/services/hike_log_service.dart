import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hike_log.dart';

class HikeLogService {
  final uid = FirebaseAuth.instance.currentUser!.uid;

  /// Reference to the user’s subcollection.
  CollectionReference<HikeLog> get _col {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('my_completed_hikes')
        .withConverter<HikeLog>(
          fromFirestore: (snap, _) => HikeLog.fromDoc(snap),
          toFirestore: (log, _) => log.toFirestore(),
        );
  }

  /// Stream all logs for the current user.
  Stream<List<HikeLog>> streamLogs() =>
      _col.snapshots().map((q) => q.docs.map((d) => d.data()).toList());

  /// Add a new log (ID auto-generated).
  Future<void> addLog(HikeLog log) => _col.add(log);

  /// Update an existing log.
  Future<void> updateLog(HikeLog log) =>
      _col.doc(log.id).set(log);

  /// Delete a log.
  Future<void> deleteLog(String id) =>
      _col.doc(id).delete();
}
