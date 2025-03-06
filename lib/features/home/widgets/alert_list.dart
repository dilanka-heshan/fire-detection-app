import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/models/alert.dart';
import '../../../core/providers/app_provider.dart';

class AlertList extends StatelessWidget {
  final List<Alert> alerts;

  const AlertList({
    super.key,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alerts.length,
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: _buildAlertIcon(alert),
            title: Text(
              _getAlertTitle(alert),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              DateFormat.yMMMd().add_jm().format(alert.timestamp),
              style: TextStyle(
                color: Colors.grey[400],
              ),
            ),
            trailing: alert.isAcknowledged
                ? Icon(
                    Icons.check_circle,
                    color: Colors.green[400],
                  )
                : TextButton(
                    onPressed: () {
                      final appProvider =
                          Provider.of<AppProvider>(context, listen: false);
                      appProvider.acknowledgeAlert(alert.id);
                    },
                    child: const Text('Acknowledge'),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAlertIcon(Alert alert) {
    IconData iconData;
    Color iconColor;

    switch (alert.type) {
      case AlertType.fire:
        iconData = Icons.local_fire_department;
        iconColor = Colors.red;
        break;
      case AlertType.smoke:
        iconData = Icons.smoke_free;
        iconColor = Colors.orange;
        break;
      case AlertType.motion:
        iconData = Icons.motion_photos_on;
        iconColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
      ),
    );
  }

  String _getAlertTitle(Alert alert) {
    switch (alert.type) {
      case AlertType.fire:
        return 'Fire Detected';
      case AlertType.smoke:
        return 'Smoke Detected';
      case AlertType.motion:
        return 'Motion Detected';
    }
  }
}
