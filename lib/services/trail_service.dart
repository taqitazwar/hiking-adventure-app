import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trail.dart';

class TrailService {
  final _base = FirebaseFirestore.instance.collection('trails');

  Stream<List<Trail>> getTrails() {
    return getTrailsFiltered();
  }

  Stream<List<Trail>> getTrailsFiltered({
    String? difficulty,
    String sortBy = 'length',
  }) {
    var query = _base as Query<Map<String, dynamic>>;
    if (difficulty != null) {
      query = query.where('difficulty', isEqualTo: difficulty);
    }
    // sort by either length (number) or time (string—works lexicographically for "45 min", "1 hr", etc.)
    query = query.orderBy(sortBy);

    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => Trail.fromDoc(doc)).toList());
  }
}
