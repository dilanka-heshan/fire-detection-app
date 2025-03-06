import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// This needs to be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request permission for notifications
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');

      // Initialize local notifications
      const initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      final initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          debugPrint('Received iOS notification: $title');
        },
      );
      final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create notification channel for Android
      if (!kIsWeb) {
        await _createNotificationChannel();
      }

      // Set up message handlers
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle initial message when app is launched from terminated state
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      const androidChannel = AndroidNotificationChannel(
        'fire_alerts_channel',
        'Fire Alerts',
        description: 'High priority notifications for fire alerts',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);

      debugPrint('Notification channel created successfully');
    } catch (e) {
      debugPrint('Error creating notification channel: $e');
    }
  }

  Future<void> subscribeToAlerts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Cannot subscribe to alerts: User not authenticated');
        return;
      }

      // Subscribe to user-specific topic
      await _messaging.subscribeToTopic('alerts_${user.uid}');
      debugPrint('Subscribed to alerts_${user.uid}');

      // Store FCM token in Firestore
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmTokens': FieldValue.arrayUnion([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint('FCM token stored in Firestore');
      }
    } catch (e) {
      debugPrint('Error subscribing to alerts: $e');
    }
  }

  Future<void> unsubscribeFromAlerts() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('Cannot unsubscribe from alerts: User not authenticated');
        return;
      }

      await _messaging.unsubscribeFromTopic('alerts_${user.uid}');
      debugPrint('Unsubscribed from alerts_${user.uid}');

      // Remove FCM token from Firestore
      final token = await _messaging.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'fcmTokens': FieldValue.arrayRemove([token]),
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint('FCM token removed from Firestore');
      }
    } catch (e) {
      debugPrint('Error unsubscribing from alerts: $e');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      debugPrint('Received foreground message: ${message.messageId}');
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null) {
        await _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'fire_alerts_channel',
              'Fire Alerts',
              channelDescription: 'High priority notifications for fire alerts',
              importance: Importance.high,
              priority: Priority.high,
              enableVibration: true,
              enableLights: true,
              icon: android?.smallIcon,
              sound: const RawResourceAndroidNotificationSound('alert_sound'),
              fullScreenIntent: true,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              sound: 'alert_sound.wav',
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
          payload: message.data['alertId'],
        );
        debugPrint('Local notification shown');
      }
    } catch (e) {
      debugPrint('Error handling foreground message: $e');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    try {
      debugPrint('Notification tapped: ${message.messageId}');
      final alertId = message.data['alertId'];
      if (alertId != null) {
        // TODO: Implement navigation to alert details
        debugPrint('Navigate to alert: $alertId');
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    try {
      debugPrint('Local notification tapped: ${response.payload}');
      if (response.payload != null) {
        // TODO: Implement navigation to alert details
        debugPrint('Navigate to alert: ${response.payload}');
      }
    } catch (e) {
      debugPrint('Error handling local notification tap: $e');
    }
  }
}
