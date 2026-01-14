import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cattle.dart';
import '../models/daily_metric.dart';

class CattleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _cattleRef =>
      _firestore.collection('cattle');

  /// ===================== CATTLE =====================

  Stream<List<Cattle>> streamAllCattleForOwner(String ownerId) {
    return _cattleRef
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((d) => Cattle.fromFirestore(d)).toList());
  }

  Future<String> createCattleAndReturnId(
      Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();
    final doc = await _cattleRef.add(data);
    return doc.id;
  }

  Future<void> updateCattle(
      String cattleId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _cattleRef.doc(cattleId).update(data);
  }

  Future<void> deleteCattle(String cattleId) async {
    await _cattleRef.doc(cattleId).delete();
  }

  /// ===================== DAILY METRICS =====================

  CollectionReference _metricRef(String cattleId) =>
      _cattleRef.doc(cattleId).collection('dailyMetrics');

  /// ➕ Save / update daily metric (one per date)
  Future<void> saveDailyMetric(
      String cattleId, DailyMetric metric) async {
    await _metricRef(cattleId)
        .doc(metric.date)
        .set(metric.toMap(), SetOptions(merge: true));
  }

  /// 🔄 Stream metrics (latest first)
  Stream<List<DailyMetric>> streamDailyMetrics(
      String cattleId, {
        int days = 30,
      }) {
    final fromDate = DateTime.now().subtract(Duration(days: days));

    return _metricRef(cattleId)
        .where(
      'updatedAt',
      isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
    )
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
          snap.docs.map((d) => DailyMetric.fromFirestore(d)).toList(),
    );
  }
}
