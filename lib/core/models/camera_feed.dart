import 'package:cloud_firestore/cloud_firestore.dart';

enum CameraType { driveway, backyard, indoor }

enum CameraStatus { online, offline }

class CameraFeed {
  final String id;
  final String name;
  final String imageUrl;
  final CameraType type;
  final CameraStatus status;
  final DateTime lastUpdated;
  final double fileSize;

  CameraFeed({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.type,
    required this.status,
    required this.lastUpdated,
    required this.fileSize,
  });

  factory CameraFeed.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CameraFeed(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type: CameraType.values.firstWhere(
        (e) => e.toString() == 'CameraType.${data['type']}',
        orElse: () => CameraType.driveway,
      ),
      status: CameraStatus.values.firstWhere(
        (e) => e.toString() == 'CameraStatus.${data['status']}',
        orElse: () => CameraStatus.offline,
      ),
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      fileSize: (data['fileSize'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'fileSize': fileSize,
    };
  }
}
