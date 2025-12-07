// lib/services/storage_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  /// Upload file and return the download URL
  Future<String?> uploadCattlePhoto(File file, {required String cattleId}) async {
    try {
      final name = 'cattle_photos/$cattleId/${_uuid.v4()}.jpg';
      final ref = _storage.ref().child(name);
      final taskSnapshot = await ref.putFile(file);
      final url = await taskSnapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      // keep error visible in logs
      print('StorageService.upload error: $e');
      return null;
    }
  }

  /// Delete by download URL (optional)
  Future<void> deleteFileByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('StorageService.delete error: $e');
    }
  }
}
