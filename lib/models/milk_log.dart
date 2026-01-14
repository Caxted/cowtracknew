import 'package:cloud_firestore/cloud_firestore.dart';

class MilkLog {
  final String id;
  final String cowId;
  final DateTime date;
  final double quantity;

  MilkLog({
    required this.id,
    required this.cowId,
    required this.date,
    required this.quantity,
  });

  factory MilkLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MilkLog(
      id: doc.id,
      cowId: data['cowId'],
      date: (data['date'] as Timestamp).toDate(),
      quantity: (data['quantity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cowId': cowId,
      'date': Timestamp.fromDate(date),
      'quantity': quantity,
    };
  }
}
