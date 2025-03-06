import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/camera_feed.dart';
import '../../../core/models/alert.dart';
import '../widgets/camera_feed_card.dart';
import '../widgets/alert_list.dart';
import '../widgets/system_status_bar.dart';
import '../widgets/user_profile_header.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Enhanced Header Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Logo and Title Row
                      Row(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Image.asset(
                              'assets/images/fire_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fire Detection System',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Connected Properties: ${provider.connectedSystems.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // System Status Switch
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                provider.isSystemArmed ? 'Armed' : 'Disarmed',
                                style: TextStyle(
                                  color: provider.isSystemArmed
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Switch(
                                value: provider.isSystemArmed,
                                onChanged: (_) => provider.toggleSystemArm(),
                                activeColor: Colors.green,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await provider.fetchConnectedSystems();
                      await provider.fetchNotifications();
                    },
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Connected Systems Section
                        const Text(
                          'Connected Houses',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (provider.connectedSystems.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No connected systems found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...provider.connectedSystems.map((system) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.home),
                                  title: Text(system.houseName),
                                  subtitle:
                                      Text(system.location ?? 'No location'),
                                  trailing: Icon(
                                    system.isConnected
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: system.isConnected
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              )),

                        const SizedBox(height: 20),

                        // Notifications Section
                        const Text(
                          'Recent Notifications',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (provider.notifications.isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'No notifications found',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          ...provider.notifications.map((notification) => Card(
                                margin: const EdgeInsets.only(bottom: 10),
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
                                  subtitle: Text(
                                    notification['houseName'] ??
                                        'Unknown Location',
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
