// lib/models/cattle.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Cattle {
  final String id;
  final String name;
  final String tagId;
  final String breed;
  final DateTime? dob;
  final String? photoUrl;
  final String? ownerId;
  final double lastMilk; // keep as double for consistency
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cattle({
    required this.id,
    required this.name,
    required this.tagId,
    required this.breed,
    this.dob,
    this.photoUrl,
    this.ownerId,
    this.lastMilk = 0.0,
    this.status = 'healthy',
    this.createdAt,
    this.updatedAt,
  });

  factory Cattle.fromMap(String id, Map<String, dynamic> map) {
    DateTime? _fromTs(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      if (v is String) return DateTime.tryParse(v);
      return null;
    }

    return Cattle(
      id: id,
      name: (map['name'] ?? '') as String,
      tagId: (map['tagId'] ?? '') as String,
      breed: (map['breed'] ?? '') as String,
      dob: _fromTs(map['dob']),
      photoUrl: map['photoUrl'] as String?,
      ownerId: map['ownerId'] as String?,
      lastMilk: (map['lastMilk'] is num) ? (map['lastMilk'] as num).toDouble() : 0.0,
      status: (map['status'] ?? 'healthy') as String,
      createdAt: _fromTs(map['createdAt']),
      updatedAt: _fromTs(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'tagId': tagId,
      'breed': breed,
      'dob': dob?.toIso8601String(),
      'photoUrl': photoUrl,
      'ownerId': ownerId,
      'lastMilk': lastMilk,
      'status': status,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    }..removeWhere((key, value) => value == null);
  }
}
