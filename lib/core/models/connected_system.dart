import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectedSystem {
  final String id;
  final String? userId;
  final String houseName;
  final bool isConnected;
  final DateTime connectedAt;
  final String? location;
  final int? deviceCount;

  ConnectedSystem({
    required this.id,
    this.userId,
    required this.houseName,
    required this.isConnected,
    required this.connectedAt,
    this.location,
    this.deviceCount,
  });

  factory ConnectedSystem.fromMap(Map<String, dynamic> map) {
    print('Converting map to ConnectedSystem: $map'); // Debug print
    try {
      final system = ConnectedSystem(
        id: map['id'] ?? '',
        userId: map['userId'],
        houseName: map['houseName'] ?? '',
        isConnected: map['isConnected'] ?? false,
        connectedAt: map['connectedAt'] is Timestamp
            ? (map['connectedAt'] as Timestamp).toDate()
            : DateTime.now(),
        location: map['location'],
        deviceCount:
            map['deviceCount'] != null ? map['deviceCount'] as int : null,
      );
      print('Successfully created ConnectedSystem: $system');
      return system;
    } catch (e) {
      print('Error creating ConnectedSystem from map: $e');
      print('Map contents: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'houseName': houseName,
      'isConnected': isConnected,
      'connectedAt': connectedAt.toIso8601String(),
    };
  }
}
