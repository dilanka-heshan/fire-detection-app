import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/camera_feed.dart';
import '../../../core/models/connected_system.dart';
import 'package:intl/intl.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentIdController = TextEditingController();
  final _houseNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _deviceCountController = TextEditingController();
  bool _isConnected = true;

  @override
  void dispose() {
    _documentIdController.dispose();
    _houseNameController.dispose();
    _locationController.dispose();
    _deviceCountController.dispose();
    super.dispose();
  }

  void _showAddConnectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Connection'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _documentIdController,
                  decoration: const InputDecoration(
                    labelText: 'Camera Setup ID *',
                    hintText: 'Enter camera setup ID',
                    helperText: 'This ID should match your camera setup',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter camera setup ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _houseNameController,
                  decoration: const InputDecoration(
                    labelText: 'House Name *',
                    hintText: 'Enter house name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter house name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location *',
                    hintText: 'Enter location',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deviceCountController,
                  decoration: const InputDecoration(
                    labelText: 'Number of Devices *',
                    hintText: 'Enter number of devices',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of devices';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Connection Status'),
                  value: _isConnected,
                  onChanged: (bool value) {
                    setState(() {
                      _isConnected = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _clearForm();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final provider = context.read<AppProvider>();
                try {
                  await provider.addConnectedSystemWithId(
                    documentId: _documentIdController.text,
                    houseName: _houseNameController.text,
                    location: _locationController.text,
                    deviceCount: int.parse(_deviceCountController.text),
                    isConnected: _isConnected,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connection added successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  _clearForm();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _documentIdController.clear();
    _houseNameController.clear();
    _locationController.clear();
    _deviceCountController.clear();
    _isConnected = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddConnectionDialog,
        child: const Icon(Icons.add),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchConnectedSystems(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (provider.connectedSystems.isEmpty)
                  const Center(
                    child: Text(
                      'No connected systems found\nTap + to add a new connection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                else
                  ...provider.connectedSystems.map((system) => Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          leading: const Icon(Icons.home),
                          title: Text(system.houseName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(system.location ?? 'No location set'),
                              Text(
                                'Connected since: ${_formatDate(system.connectedAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            system.isConnected
                                ? Icons.check_circle
                                : Icons.error,
                            color:
                                system.isConnected ? Colors.green : Colors.red,
                          ),
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCameraCard(CameraFeed camera) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  camera.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[900],
                    child: const Icon(Icons.error),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.circle,
                          size: 8,
                          color: camera.status == CameraStatus.online
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          camera.status == CameraStatus.online
                              ? 'Live'
                              : 'Offline',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camera.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${camera.type.toString().split('.').last} camera',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
