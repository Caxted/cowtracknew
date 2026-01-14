import 'package:cloud_firestore/cloud_firestore.dart';

class DailyMetric {
  final String date; // "yyyy-MM-dd"
  final double temperatureAvg;
  final double temperatureMax;
  final double temperatureMin;
  final int steps;
  final double milk;
  final Timestamp updatedAt;

  DailyMetric({
    required this.date,
    this.temperatureAvg = 0.0,
    this.temperatureMax = 0.0,
    this.temperatureMin = 0.0,
    this.steps = 0,
    this.milk = 0.0,
    required this.updatedAt,
  });

  /// Converts a DailyMetric instance to a map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'temperatureAvg': temperatureAvg,
      'temperatureMax': temperatureMax,
      'temperatureMin': temperatureMin,
      'steps': steps,
      'milk': milk,
      'updatedAt': updatedAt,
    };
  }

  /// Creates a DailyMetric instance from a Firestore document (existing)
  factory DailyMetric.fromDoc(DocumentSnapshot doc) {
    final Map<String, dynamic> data =
    doc.data() as Map<String, dynamic>;

    // Ensure updatedAt exists and is a Timestamp
    final rawUpdated = data['updatedAt'];
    final Timestamp updated =
    rawUpdated is Timestamp ? rawUpdated : Timestamp.now();

    return DailyMetric(
      date: doc.id, // document ID is the date
      temperatureAvg:
      (data['temperatureAvg'] as num?)?.toDouble() ?? 0.0,
      temperatureMax:
      (data['temperatureMax'] as num?)?.toDouble() ?? 0.0,
      temperatureMin:
      (data['temperatureMin'] as num?)?.toDouble() ?? 0.0,
      steps: (data['steps'] as num?)?.toInt() ?? 0,
      milk: (data['milk'] as num?)?.toDouble() ?? 0.0,
      updatedAt: updated,
    );
  }

  /// ✅ Adapter used by services (DO NOT REMOVE)
  factory DailyMetric.fromFirestore(DocumentSnapshot doc) {
    return DailyMetric.fromDoc(doc);
  }
}
