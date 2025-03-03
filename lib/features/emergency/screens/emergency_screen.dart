import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/alert.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Emergency'),
            centerTitle: true,
            backgroundColor: Colors.red,
            actions: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () {
                  // TODO: Implement emergency call
                },
              ),
            ],
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildEmergencyContacts(),
                    const SizedBox(height: 24),
                    const Text(
                      'Active Alerts',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...provider.alerts
                        .where((alert) => !alert.isAcknowledged)
                        .map((alert) => _buildAlertCard(context, alert)),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmergencyContacts() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactTile(
              'Fire Department',
              '911',
              Icons.local_fire_department,
              Colors.red,
            ),
            const Divider(),
            _buildContactTile(
              'Police',
              '911',
              Icons.local_police,
              Colors.blue,
            ),
            const Divider(),
            _buildContactTile(
              'Ambulance',
              '911',
              Icons.medical_services,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactTile(
    String title,
    String number,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(number),
      trailing: IconButton(
        icon: const Icon(Icons.phone),
        onPressed: () {
          // TODO: Implement phone call
        },
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Alert alert) {
    Color color;
    IconData icon;

    switch (alert.type) {
      case AlertType.fire:
        color = Colors.red;
        icon = Icons.local_fire_department;
        break;
      case AlertType.smoke:
        color = Colors.orange;
        icon = Icons.smoke_free;
        break;
      case AlertType.motion:
        color = Colors.blue;
        icon = Icons.motion_photos_on;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          alert.type.toString().split('.').last.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Camera: ${alert.cameraId}'),
        trailing: TextButton(
          onPressed: () {
            // TODO: Implement alert acknowledgment
          },
          child: const Text('Acknowledge'),
        ),
      ),
    );
  }
}
