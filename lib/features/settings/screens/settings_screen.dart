import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await AuthService().signOut();
                // Navigation will be handled by auth state changes in main.dart
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            centerTitle: true,
          ),
          body: ListView(
            children: [
              _buildSection(
                'System',
                [
                  SwitchListTile(
                    title: const Text('System Armed'),
                    subtitle: Text(
                      provider.isSystemArmed
                          ? 'System is currently armed'
                          : 'System is currently disarmed',
                    ),
                    value: provider.isSystemArmed,
                    onChanged: (value) => provider.toggleSystemArm(),
                  ),
                  ListTile(
                    title: const Text('Notification Settings'),
                    subtitle: const Text('Configure alert notifications'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to notification settings
                    },
                  ),
                ],
              ),
              _buildSection(
                'Cameras',
                [
                  ListTile(
                    title: const Text('Camera Management'),
                    subtitle: const Text('Add or remove cameras'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to camera management
                    },
                  ),
                  ListTile(
                    title: const Text('Detection Sensitivity'),
                    subtitle: const Text('Adjust detection thresholds'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to sensitivity settings
                    },
                  ),
                ],
              ),
              _buildSection(
                'Account',
                [
                  ListTile(
                    title: const Text('Emergency Contacts'),
                    subtitle: const Text('Manage emergency contact numbers'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to emergency contacts
                    },
                  ),
                  ListTile(
                    title: const Text('Profile Settings'),
                    subtitle: const Text('Update your profile information'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to profile settings
                    },
                  ),
                ],
              ),
              _buildSection(
                'About',
                [
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: const Text('1.0.0'),
                  ),
                  ListTile(
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Show terms of service
                    },
                  ),
                  ListTile(
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ),
                ],
              ),
              _buildSection(
                '',
                [
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
        ...children,
      ],
    );
  }
}
