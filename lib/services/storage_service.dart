import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Note: Since Firebase Storage uses paths directly, we don't need a specific bucket name
  // if you're using the default bucket. If you need a specific bucket, it's defined in Firebase initialization.

  Future<String?> uploadProfileImage(String uid, File file) async {
    try {
      final path = 'profiles/$uid.jpg';
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService Error: $e');
      if (e is FirebaseException) {
        throw e.message ?? e.toString();
      }
      throw e.toString();
    }
  }

  Future<String?> uploadIdentityDoc(String uid, String type, File file) async {
    try {
      final fileName = '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'identities/$uid/$fileName';
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService Error: $e');
      if (e is FirebaseException) {
        throw e.message ?? e.toString();
      }
      throw e.toString();
    }
  }

  Future<String?> uploadMaintenanceImage(String requestId, File file) async {
    try {
      final path = 'maintenance/$requestId.jpg';
      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('StorageService Error: $e');
      if (e is FirebaseException) {
        throw e.message ?? e.toString();
      }
      throw e.toString();
    }
  }
}
