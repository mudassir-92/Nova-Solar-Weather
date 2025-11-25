// lib/UIscreens/settings_screen.dart
import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/location_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _notificationSound = true;
  bool _notificationVibration = true;
  bool _auroraAlertsEnabled = false;
  double _kpThreshold = 5.0;
  int _updateFrequency = 15;
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notificationsEnabled = await SettingsService.getNotificationsEnabled();
    final notificationSound = await SettingsService.getNotificationSound();
    final notificationVibration = await SettingsService.getNotificationVibration();
    final auroraAlertsEnabled = await SettingsService.getAuroraAlertsEnabled();
    final kpThreshold = await SettingsService.getKpThreshold();
    final updateFrequency = await SettingsService.getUpdateFrequency();
    final locationName = await SettingsService.getLocationName();
    
    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _notificationSound = notificationSound;
      _notificationVibration = notificationVibration;
      _auroraAlertsEnabled = auroraAlertsEnabled;
      _kpThreshold = kpThreshold;
      _updateFrequency = updateFrequency;
      _locationName = locationName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            'Enable Notifications',
            'Receive alerts for space weather events',
            _notificationsEnabled,
            (value) async {
              await SettingsService.setNotificationsEnabled(value);
              setState(() => _notificationsEnabled = value);
            },
            icon: Icons.notifications,
          ),
          if (_notificationsEnabled) ...[
            _buildSwitchTile(
              'Notification Sound',
              'Play sound when notifications arrive',
              _notificationSound,
              (value) async {
                await SettingsService.setNotificationSound(value);
                setState(() => _notificationSound = value);
              },
              icon: Icons.volume_up,
            ),
            _buildSwitchTile(
              'Notification Vibration',
              'Vibrate when notifications arrive',
              _notificationVibration,
              (value) async {
                await SettingsService.setNotificationVibration(value);
                setState(() => _notificationVibration = value);
              },
              icon: Icons.vibration,
            ),
            _buildSliderTile(
              'Kp Index Threshold',
              'Only notify when Kp index exceeds this value',
              _kpThreshold,
              2.0,
              9.0,
              (value) async {
                await SettingsService.setKpThreshold(value);
                setState(() => _kpThreshold = value);
              },
              icon: Icons.trending_up,
            ),
          ],
          const SizedBox(height: 24),
          _buildSectionHeader('Aurora Alerts'),
          _buildSwitchTile(
            'Aurora Visibility Alerts',
            'Get notified when aurora may be visible at your location',
            _auroraAlertsEnabled,
            (value) async {
              await SettingsService.setAuroraAlertsEnabled(value);
              setState(() => _auroraAlertsEnabled = value);
            },
            icon: Icons.nightlight_round,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Location'),
          _buildLocationTile(),
          const SizedBox(height: 24),
          _buildSectionHeader('Data Updates'),
          _buildDropdownTile(
            'Update Frequency',
            'How often to check for new data',
            _updateFrequency,
            [15, 30, 60, 120],
            (value) async {
              await SettingsService.setUpdateFrequency(value);
              setState(() => _updateFrequency = value);
            },
            icon: Icons.refresh,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('About'),
          _buildInfoTile(
            'Version',
            '1.0.0',
            icon: Icons.info,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue.shade300,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    IconData? icon,
  }) {
    return Card(
      color: Colors.blueGrey[900],
      child: SwitchListTile(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.blue.shade300, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    IconData? icon,
  }) {
    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.blue.shade300, size: 20),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(
                    color: Colors.blue.shade300,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: ((max - min) * 10).toInt(),
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    int value,
    List<int> options,
    ValueChanged<int> onChanged, {
    IconData? icon,
  }) {
    return Card(
      color: Colors.blueGrey[900],
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: Colors.blue.shade300)
            : null,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: DropdownButton<int>(
          value: value,
          dropdownColor: Colors.blueGrey[900],
          style: const TextStyle(color: Colors.white),
          items: options.map((int option) {
            String label = option < 60
                ? '$option minutes'
                : '${option ~/ 60} hour${option ~/ 60 > 1 ? 's' : ''}';
            return DropdownMenuItem<int>(
              value: option,
              child: Text(label),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ),
    );
  }

  Widget _buildLocationTile() {
    return Card(
      color: Colors.blueGrey[900],
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.location_on, color: Colors.blue.shade300),
            title: const Text('Location', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              _locationName ?? 'Not set',
              style: TextStyle(
                color: _locationName != null ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              _showLocationDialog();
            },
          ),
          Divider(height: 1, color: Colors.grey[800]),
          ListTile(
            leading: Icon(Icons.my_location, color: Colors.green.shade300),
            title: const Text('Get Current Location', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'Use GPS to automatically detect your location',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: Icon(Icons.gps_fixed, color: Colors.green.shade300),
            onTap: () {
              _getCurrentLocation();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Getting your location...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );

    try {
      final locationData = await LocationService.getLocationWithName();
      
      if (locationData != null) {
        await SettingsService.setLocation(
          locationData['latitude'] as double,
          locationData['longitude'] as double,
          locationData['name'] as String,
        );
        
        setState(() {
          _locationName = locationData['name'] as String;
        });

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location set to: ${locationData['name']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get location. Please check permissions or try manually.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInfoTile(String title, String value, {IconData? icon}) {
    return Card(
      color: Colors.blueGrey[900],
      child: ListTile(
        leading: icon != null
            ? Icon(icon, color: Colors.blue.shade300)
            : null,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Text(
          value,
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  void _showLocationDialog() {
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final nameController = TextEditingController(text: _locationName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        title: const Text('Set Location', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Location Name',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: latController,
              decoration: InputDecoration(
                labelText: 'Latitude (-90 to 90)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: lonController,
              decoration: InputDecoration(
                labelText: 'Longitude (-180 to 180)',
                labelStyle: TextStyle(color: Colors.grey[400]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final lat = double.tryParse(latController.text);
              final lon = double.tryParse(lonController.text);
              final name = nameController.text.trim();

              if (lat != null && lon != null && name.isNotEmpty) {
                if (lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180) {
                  await SettingsService.setLocation(lat, lon, name);
                  setState(() => _locationName = name);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid coordinates')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

