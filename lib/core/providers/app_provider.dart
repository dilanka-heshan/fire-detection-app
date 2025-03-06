import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/camera_feed.dart';
import '../models/alert.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/connected_system.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get _currentUser => _auth.currentUser;

  List<CameraFeed> _cameras = [];
  List<Alert> _alerts = [];
  bool _isSystemArmed = false;
  bool _isLoading = false;
  String? _userName;
  String? _userEmail;
  String? _userLocation;
  List<ConnectedSystem> _connectedSystems = [];
  List<Map<String, dynamic>> _notifications = [];

  // Getters
  List<CameraFeed> get cameras => _cameras;
  List<Alert> get alerts => _alerts;
  bool get isSystemArmed => _isSystemArmed;
  bool get isLoading => _isLoading;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userLocation => _userLocation;
  List<ConnectedSystem> get connectedSystems => _connectedSystems;
  List<Map<String, dynamic>> get notifications => _notifications;

  AppProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _setLoading(true);
    checkAuthStatus();

    try {
      // Add these lines to fetch connected systems and notifications
      await fetchConnectedSystems();
      await fetchNotifications();

      // Listen to user profile
      _db.getUserProfile().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _userName = data['name'];
          _userEmail = data['email'];
          _userLocation = data['location'];
          notifyListeners();
        }
      });

      // Listen to cameras
      _db.getCameras().listen((snapshot) {
        _cameras = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return CameraFeed(
            id: doc.id,
            name: data['name'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            type: _getCameraType(data['type']),
            status: data['status'] == 'online'
                ? CameraStatus.online
                : CameraStatus.offline,
            lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
            fileSize: (data['fileSize'] ?? 0.0).toDouble(),
          );
        }).toList();
        notifyListeners();
      });

      // Listen to alerts
      _db.getAlerts().listen((snapshot) {
        _alerts = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Alert(
            id: doc.id,
            cameraId: data['cameraId'] ?? '',
            imageUrl: data['imageUrl'] ?? '',
            type: _getAlertType(data['type']),
            severity: _getAlertSeverity(data['severity']),
            timestamp: (data['createdAt'] as Timestamp).toDate(),
            isAcknowledged: data['isAcknowledged'] ?? false,
            acknowledgedBy: data['acknowledgedBy'],
            acknowledgedAt: data['acknowledgedAt'] != null
                ? (data['acknowledgedAt'] as Timestamp).toDate()
                : null,
          );
        }).toList();
        notifyListeners();
      });

      // Listen to system status
      _db.getSystemStatus().listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          _isSystemArmed = data['isArmed'] ?? false;
          notifyListeners();
        }
      });
    } catch (e) {
      debugPrint('Error initializing app: $e');
    }

    _setLoading(false);
  }

  Future<void> toggleSystemArm() async {
    try {
      await _db.updateSystemStatus(!_isSystemArmed);
    } catch (e) {
      debugPrint('Error toggling system arm status: $e');
    }
  }

  Future<void> acknowledgeAlert(String alertId) async {
    try {
      await _db.acknowledgeAlert(alertId);
    } catch (e) {
      debugPrint('Error acknowledging alert: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  CameraType _getCameraType(String? type) {
    switch (type?.toLowerCase()) {
      case 'driveway':
        return CameraType.driveway;
      case 'backyard':
        return CameraType.backyard;
      case 'indoor':
        return CameraType.indoor;
      default:
        return CameraType.driveway;
    }
  }

  AlertType _getAlertType(String? type) {
    switch (type?.toLowerCase()) {
      case 'fire':
        return AlertType.fire;
      case 'smoke':
        return AlertType.smoke;
      case 'motion':
        return AlertType.motion;
      default:
        return AlertType.motion;
    }
  }

  AlertSeverity _getAlertSeverity(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'high':
        return AlertSeverity.high;
      case 'medium':
        return AlertSeverity.medium;
      case 'low':
        return AlertSeverity.low;
      default:
        return AlertSeverity.low;
    }
  }

  void checkAuthStatus() {
    final user = _auth.currentUser;
    print('DEBUG - Auth Status:');
    print('Current user: ${user?.uid}');
    print('Email: ${user?.email}');
    if (user == null) {
      print('❌ No user is logged in');
    } else {
      print('✅ User is logged in with ID: ${user.uid}');
    }
  }

  Future<void> fetchConnectedSystems() async {
    checkAuthStatus();

    if (_currentUser == null) {
      print('❌ No user logged in - cannot fetch systems');
      return;
    }

    try {
      print('🔍 Attempting to fetch connected systems');
      print('Looking for userId: ${_currentUser?.uid}');

      final snapshot = await FirebaseFirestore.instance
          .collection('connected_systems')
          .where('userId', isEqualTo: _currentUser?.uid)
          .get();

      print('📊 Query results:');
      print('Documents found: ${snapshot.docs.length}');

      // Print each document for debugging
      snapshot.docs.forEach((doc) {
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
      });

      _connectedSystems = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ConnectedSystem.fromMap(data);
      }).toList();

      print('✅ Connected systems processed: ${_connectedSystems.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching connected systems: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> addConnectedSystem(String houseName, String location) async {
    if (_currentUser == null) return;

    try {
      print('Adding new connected system');
      print('House Name: $houseName');
      print('Location: $location');
      print('User ID: ${_currentUser?.uid}');

      final docRef =
          await FirebaseFirestore.instance.collection('connected_systems').add({
        'userId': _currentUser?.uid,
        'houseName': houseName,
        'location': location,
        'isConnected': true,
        'connectedAt': Timestamp.now(),
        'deviceCount': 0,
      });

      print('Document added with ID: ${docRef.id}');

      final newSystem = ConnectedSystem(
        id: docRef.id,
        userId: _currentUser?.uid,
        houseName: houseName,
        isConnected: true,
        connectedAt: DateTime.now(),
        location: location,
        deviceCount: 0,
      );

      _connectedSystems.add(newSystem);
      notifyListeners();

      print('Successfully added new system');
    } catch (e) {
      print('❌ Error adding connected system: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> fetchNotifications() async {
    if (_currentUser == null) {
      print('❌ No user logged in - cannot fetch notifications');
      return;
    }

    try {
      print('🔍 Attempting to fetch notifications');
      print('Looking for userId: ${_currentUser?.uid}');

      // Temporary query without ordering while index is being created
      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: _currentUser?.uid)
          // .orderBy('timestamp', descending: true)  // Comment this temporarily
          .limit(10)
          .get();

      print('📊 Query results:');
      print('Notifications found: ${snapshot.docs.length}');

      // Print each document for debugging
      snapshot.docs.forEach((doc) {
        print('Document ID: ${doc.id}');
        print('Document data: ${doc.data()}');
      });

      _notifications = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // Sort notifications in memory temporarily
      _notifications.sort((a, b) {
        final aTime = (a['timestamp'] as Timestamp).toDate();
        final bTime = (b['timestamp'] as Timestamp).toDate();
        return bTime.compareTo(aTime); // Descending order
      });

      print('✅ Notifications processed: ${_notifications.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  Future<void> addConnectedSystemWithId({
    required String documentId,
    required String houseName,
    required String location,
    required int deviceCount,
    required bool isConnected,
  }) async {
    if (_currentUser == null) return;

    try {
      print('Adding new connected system with ID: $documentId');

      // Create the document with specific ID
      await FirebaseFirestore.instance
          .collection('connected_systems')
          .doc(documentId) // Use the provided ID
          .set({
        'userId': _currentUser?.uid,
        'houseName': houseName,
        'location': location,
        'isConnected': isConnected,
        'connectedAt': Timestamp.now(),
        'deviceCount': deviceCount,
      });

      final newSystem = ConnectedSystem(
        id: documentId,
        userId: _currentUser?.uid,
        houseName: houseName,
        isConnected: isConnected,
        connectedAt: DateTime.now(),
        location: location,
        deviceCount: deviceCount,
      );

      _connectedSystems.add(newSystem);
      notifyListeners();

      print('Successfully added new system with ID: $documentId');
    } catch (e) {
      print('❌ Error adding connected system: $e');
      print('Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }
}
