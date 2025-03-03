import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/camera_feed.dart';
import '../models/alert.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Collections
  static const String _camerasCollection = 'cameras';
  static const String _alertsCollection = 'alerts';

  // Camera Feed Methods
  Stream<List<CameraFeed>> getCameraFeeds() {
    return _firestore.collection(_camerasCollection).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => CameraFeed.fromFirestore(doc)).toList());
  }

  Future<CameraFeed?> getCameraFeed(String id) async {
    final doc = await _firestore.collection(_camerasCollection).doc(id).get();
    return doc.exists ? CameraFeed.fromFirestore(doc) : null;
  }

  // Alert Methods
  Stream<List<Alert>> getAlerts() {
    return _firestore
        .collection(_alertsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList());
  }

  Future<void> acknowledgeAlert(String alertId, String userId) async {
    await _firestore.collection(_alertsCollection).doc(alertId).update({
      'isAcknowledged': true,
      'acknowledgedBy': userId,
      'acknowledgedAt': FieldValue.serverTimestamp(),
    });
  }

  // Push Notifications
  Future<void> setupPushNotifications() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await _messaging.getToken();
      if (token != null) {
        // Store the token in Firestore for the current user
        // This would typically go in a 'users' or 'devices' collection
        print('FCM Token: $token');
      }

      // Handle incoming messages when the app is in the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print(
              'Message also contained a notification: ${message.notification}');
        }
      });
    }
  }

  // System Status Methods
  Future<void> updateSystemStatus({required bool isArmed}) async {
    await _firestore.collection('system').doc('status').set({
      'isArmed': isArmed,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<bool> getSystemArmStatus() {
    return _firestore
        .collection('system')
        .doc('status')
        .snapshots()
        .map((doc) => doc.data()?['isArmed'] ?? false);
  }
}
