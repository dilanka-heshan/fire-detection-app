import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/camera_feed.dart';
import '../../../core/models/alert.dart';
import '../widgets/camera_feed_card.dart';
import '../widgets/alert_list.dart';
import '../widgets/system_status_bar.dart';
import '../widgets/user_profile_header.dart';

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
                SystemStatusBar(
                  isArmed: provider.isSystemArmed,
                  onArmToggle: provider.toggleSystemArm,
                ),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            UserProfileHeader(
                              userName: provider.userName ?? 'User',
                              userLocation:
                                  provider.userLocation ?? 'Location not set',
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...provider.cameras.map((camera) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: CameraFeedCard(camera: camera),
                                )),
                            if (provider.alerts.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Recent Alerts',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AlertList(alerts: provider.alerts),
                            ],
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
}
