import 'package:flutter/material.dart';
import '../models/camera_feed.dart';
import '../models/alert.dart';
import '../services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<CameraFeed> _cameras = [];
  List<Alert> _alerts = [];
  bool _isSystemArmed = false;
  bool _isLoading = false;
  String? _userName;
  String? _userEmail;
  String? _userLocation;

  // Getters
  List<CameraFeed> get cameras => _cameras;
  List<Alert> get alerts => _alerts;
  bool get isSystemArmed => _isSystemArmed;
  bool get isLoading => _isLoading;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userLocation => _userLocation;

  AppProvider() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _setLoading(true);

    try {
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
}
