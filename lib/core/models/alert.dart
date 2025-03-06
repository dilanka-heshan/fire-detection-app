import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType { fire, smoke, motion }

enum AlertSeverity { low, medium, high }

class Alert {
  final String id;
  final String cameraId;
  final String imageUrl;
  final AlertType type;
  final AlertSeverity severity;
  final DateTime timestamp;
  final bool isAcknowledged;
  final String? acknowledgedBy;
  final DateTime? acknowledgedAt;

  Alert({
    required this.id,
    required this.cameraId,
    required this.imageUrl,
    required this.type,
    required this.severity,
    required this.timestamp,
    this.isAcknowledged = false,
    this.acknowledgedBy,
    this.acknowledgedAt,
  });

  factory Alert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Alert(
      id: doc.id,
      cameraId: data['cameraId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.toString() == 'AlertType.${data['type']}',
        orElse: () => AlertType.motion,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.toString() == 'AlertSeverity.${data['severity']}',
        orElse: () => AlertSeverity.low,
      ),
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      isAcknowledged: data['isAcknowledged'] ?? false,
      acknowledgedBy: data['acknowledgedBy'],
      acknowledgedAt: data['acknowledgedAt'] != null
          ? (data['acknowledgedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cameraId': cameraId,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAcknowledged': isAcknowledged,
      'acknowledgedBy': acknowledgedBy,
      'acknowledgedAt':
          acknowledgedAt != null ? Timestamp.fromDate(acknowledgedAt!) : null,
    };
  }
}
