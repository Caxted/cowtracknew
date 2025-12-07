// lib/services/cattle_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cowtrack/models/cattle.dart';
import 'package:cowtrack/models/daily_metric.dart';

class CattleService {
  final CollectionReference _cattleCol = FirebaseFirestore.instance.collection('cattle');

  /// Streams all cattle documents for an ownerId (ownerId stored in doc)
  Stream<List<Cattle>> streamAllCattleForOwner(String ownerId) {
    return _cattleCol
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Cattle.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  /// Creates a cattle document and returns the generated doc id
  Future<String> createCattleAndReturnId(Map<String, dynamic> data) async {
    final docRef = _cattleCol.doc();
    final payload = Map<String, dynamic>.from(data);
    payload['createdAt'] = FieldValue.serverTimestamp();
    await docRef.set(payload);
    return docRef.id;
  }

  /// Create cattle using add (if you used elsewhere)
  Future<void> createCattle(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data);
    payload['createdAt'] = FieldValue.serverTimestamp();
    await _cattleCol.add(payload);
  }

  /// Update cattle fields
  Future<void> updateCattle(String id, Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data);
    payload['updatedAt'] = FieldValue.serverTimestamp();
    await _cattleCol.doc(id).update(payload);
  }

  /// Delete cattle document
  Future<void> deleteCattle(String id) async {
    await _cattleCol.doc(id).delete();
  }

  /// Optional helper: fetch single cattle by id
  Future<Cattle?> getCattleById(String id) async {
    final snap = await _cattleCol.doc(id).get();
    if (!snap.exists) return null;
    return Cattle.fromMap(snap.id, snap.data() as Map<String, dynamic>);
  }

  // ------------------------
  // Daily metric helpers
  // ------------------------

  /// Save or update a daily metric using a DailyMetric object.
  /// Saves under: cattle/{cattleId}/daily_metrics/{metric.date}
  Future<void> saveDailyMetric(String cattleId, DailyMetric metric) async {
    final col = _cattleCol.doc(cattleId).collection('daily_metrics');

    // Use the metric.date (expected format yyyy-MM-dd) as the document id
    final docRef = col.doc(metric.date);

    // Convert metric to a map and set updatedAt to server timestamp for consistency
    final payload = Map<String, dynamic>.from(metric.toMap());
    payload['updatedAt'] = FieldValue.serverTimestamp();

    // Merge to avoid overwriting unrelated fields
    await docRef.set(payload, SetOptions(merge: true));
  }

  /// Stream daily metrics for a cattle ordered oldest -> newest (ascending).
  /// If `days` provided, limits to last N docs (newest N) and returns them ascending.
  Stream<List<DailyMetric>> streamDailyMetrics(String cattleId, {int? days}) {
    Query q = _cattleCol.doc(cattleId).collection('daily_metrics').orderBy('updatedAt', descending: true);

    if (days != null && days > 0) {
      q = q.limit(days);
    }

    return q.snapshots().map((snap) {
      final list = snap.docs.map((d) => DailyMetric.fromDoc(d)).toList();
      // Reverse newest->oldest to oldest->newest for charts
      final asc = list.reversed.toList();
      return asc;
    });
  }
}
