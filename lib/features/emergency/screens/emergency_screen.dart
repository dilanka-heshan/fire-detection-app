import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/alert.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  // Function to handle emergency calls
  Future<void> _makeEmergencyCall(String number) async {
    final Uri url = Uri.parse('tel:$number');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Emergency'),
            backgroundColor: Colors.red,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await provider.fetchNotifications();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Emergency Numbers Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.emergency, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Emergency Contacts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Emergency Numbers Grid
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.5,
                        children: [
                          // Fire Department
                          _EmergencyContactCard(
                            title: 'Fire Department',
                            number: '119',
                            icon: Icons.local_fire_department,
                            color: Colors.red,
                            onTap: () => _makeEmergencyCall('119'),
                          ),
                          // Police
                          _EmergencyContactCard(
                            title: 'Police',
                            number: '119',
                            icon: Icons.local_police,
                            color: Colors.blue,
                            onTap: () => _makeEmergencyCall('119'),
                          ),
                          // Ambulance
                          _EmergencyContactCard(
                            title: 'Ambulance',
                            number: '110',
                            icon: Icons.medical_services,
                            color: Colors.green,
                            onTap: () => _makeEmergencyCall('110'),
                          ),
                          // Emergency Hotline
                          _EmergencyContactCard(
                            title: 'Emergency Hotline',
                            number: '112',
                            icon: Icons.phone_in_talk,
                            color: Colors.orange,
                            onTap: () => _makeEmergencyCall('112'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Active Alerts Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Active Alerts',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Active alerts list
                      if (provider.alerts.isEmpty)
                        const Center(
                          child: Text(
                            'No active alerts',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...provider.alerts.map((alert) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: const Icon(Icons.warning,
                                    color: Colors.red),
                                title: Text(alert.type.toString()),
                                subtitle: Text(
                                  DateFormat.yMMMd()
                                      .add_Hm()
                                      .format(alert.timestamp),
                                ),
                              ),
                            )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Previous Notifications Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            'Previous Notifications',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (provider.notifications.isEmpty)
                        const Center(
                          child: Text(
                            'No previous notifications',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...provider.notifications.map((notification) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(
                                  notification['type'] == 'alert'
                                      ? Icons.warning
                                      : Icons.notifications,
                                  color: notification['type'] == 'alert'
                                      ? Colors.red
                                      : Colors.blue,
                                ),
                                title: Text(notification['message'] ?? ''),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(notification['houseName'] ?? ''),
                                    Text(
                                      DateFormat.yMMMd().add_Hm().format(
                                          (notification['timestamp']
                                                  as Timestamp)
                                              .toDate()),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                    ],
                  ),
                ),
              ],
            ),
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

// Emergency Contact Card Widget
class _EmergencyContactCard extends StatelessWidget {
  final String title;
  final String number;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _EmergencyContactCard({
    required this.title,
    required this.number,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                number,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
