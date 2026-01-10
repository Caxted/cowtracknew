import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MilkService {
  final _milkRef =
  FirebaseFirestore.instance.collection('milk_logs');

  Future<void> addMilkLog({
    required String cattleId,
    required double quantity,
    DateTime? date,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _milkRef.add({
      'ownerId': user.uid,
      'cattleId': cattleId,
      'quantity': quantity,
      'date': Timestamp.fromDate(date ?? DateTime.now()),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
