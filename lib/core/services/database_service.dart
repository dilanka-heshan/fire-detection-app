import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Collections
  static const String users = 'users';
  static const String cameras = 'cameras';
  static const String alerts = 'alerts';
  static const String system = 'system';

  // User Operations
  Future<void> createUserProfile(User user, String name) async {
    await _db.collection(users).doc(user.uid).set({
      'name': name,
      'email': user.email,
      'location': 'Not set', // Default location
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
      'role': 'user',
      'profileComplete': false,
    });

    // Create default system status for the user
    await _db.collection(system).doc(user.uid).set({
      'isArmed': false,
      'lastUpdated': FieldValue.serverTimestamp(),
      'notificationsEnabled': true,
    });
  }

  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    if (userId == null) return;
    await _db.collection(users).doc(userId).update(data);
  }

  Future<void> updateUserLocation(String location) async {
    if (userId == null) return;
    await _db.collection(users).doc(userId).update({
      'location': location,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getUserProfile() {
    if (userId == null) throw Exception('User not authenticated');
    return _db.collection(users).doc(userId).snapshots();
  }

  // Camera Operations
  Future<void> addCamera({
    required String name,
    required String type,
    required String imageUrl,
  }) async {
    if (userId == null) return;

    await _db.collection(users).doc(userId).collection(cameras).add({
      'name': name,
      'type': type,
      'imageUrl': imageUrl,
      'status': 'online',
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getCameras() {
    if (userId == null) throw Exception('User not authenticated');
    return _db
        .collection(users)
        .doc(userId)
        .collection(cameras)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Alert Operations
  Future<void> createAlert({
    required String type,
    required String cameraId,
    required String imageUrl,
    required String severity,
  }) async {
    if (userId == null) return;

    await _db.collection(users).doc(userId).collection(alerts).add({
      'type': type,
      'cameraId': cameraId,
      'imageUrl': imageUrl,
      'severity': severity,
      'isAcknowledged': false,
      'createdAt': FieldValue.serverTimestamp(),
      'acknowledgedAt': null,
      'acknowledgedBy': null,
    });
  }

  Stream<QuerySnapshot> getAlerts() {
    if (userId == null) throw Exception('User not authenticated');
    return _db
        .collection(users)
        .doc(userId)
        .collection(alerts)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> acknowledgeAlert(String alertId) async {
    if (userId == null) return;

    await _db
        .collection(users)
        .doc(userId)
        .collection(alerts)
        .doc(alertId)
        .update({
      'isAcknowledged': true,
      'acknowledgedAt': FieldValue.serverTimestamp(),
      'acknowledgedBy': userId,
    });
  }

  // System Status Operations
  Future<void> updateSystemStatus(bool isArmed) async {
    if (userId == null) return;

    await _db.collection(system).doc(userId).update({
      'isArmed': isArmed,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getSystemStatus() {
    if (userId == null) throw Exception('User not authenticated');
    return _db.collection(system).doc(userId).snapshots();
  }
}
