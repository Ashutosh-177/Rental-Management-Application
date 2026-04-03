import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'push_notification_service.dart';

class NotificationService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendNotification(NotificationModel notification) async {
    // 1. Save in-app notification to Firestore
    await _firestore.collection('notifications').add(notification.toMap());

    // 2. Trigger OS-level push notification via Supabase Edge Function
    try {
      final pushService = PushNotificationService();
      await pushService.sendPushNotification(
        targetUserId: notification.userId,
        title: notification.title,
        body: notification.message,
        data: {'type': notification.type},
      );
    } catch (e) {
      debugPrint('Error triggering push notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
}
