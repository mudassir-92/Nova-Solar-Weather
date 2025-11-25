// lib/screens/alerts_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../models/space_weather_data.dart';
import '../services/location_alert_filter.dart';

class AlertsScreen extends StatefulWidget {
  final List<SpaceAlert> alerts;

  const AlertsScreen({Key? key, required this.alerts}) : super(key: key);

  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late List<SpaceAlert> _alerts;

  @override
  void initState() {
    super.initState();
    _loadFilteredAlerts();
  }

  Future<void> _loadFilteredAlerts() async {
    // Filter alerts by location
    final filteredAlerts = await LocationAlertFilter.filterAlertsByLocation(widget.alerts);
    
    // Sort by issued time (most recent first) and take last 50
    final sortedAlerts = List<SpaceAlert>.from(filteredAlerts)
      ..sort((a, b) => b.issuedTime.compareTo(a.issuedTime));
    
    setState(() {
      _alerts = sortedAlerts.take(50).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Space Weather Alerts (${_alerts.length}${widget.alerts.length > 50 ? '/${widget.alerts.length}' : ''})'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Lottie Animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/bg.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          // Content
          _alerts.isNotEmpty
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _alerts.length,
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return _buildAlertCard(alert);
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 64),
                      const SizedBox(height: 16),
                      Text('No Active Alerts',
                          style: TextStyle(color: Colors.green, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text('All space weather systems are normal',
                          style: TextStyle(color: Colors.grey[400])),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  // ✅ ADDED: Missing _buildAlertCard method
  Widget _buildAlertCard(SpaceAlert alert) {
    return Card(
      color: Colors.blueGrey[900],
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAlertColor(alert.level).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getAlertColor(alert.level)),
                  ),
                  child: Text(
                    '${alert.level.toUpperCase()} • ${alert.type}',
                    style: TextStyle(
                      color: _getAlertColor(alert.level),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (alert.kpIndex != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Kp ${alert.kpIndex}',
                      style: TextStyle(
                        color: Colors.blue.shade200,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatMessage(alert.message),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            if (alert.affectedAreas.isNotEmpty)
              _buildAffectedAreasSection(alert.affectedAreas),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Issued: ${_formatDateTime(alert.issuedTime)}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (alert.expiresTime != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.timer_off, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${_formatDateTime(alert.expiresTime!)}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${alert.id}',
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ ADDED: Missing _buildAffectedAreasSection method
  Widget _buildAffectedAreasSection(List<GeoCoordinate> areas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📍 Affected Areas:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: areas.map((area) => Chip(
            backgroundColor: Colors.blue.shade800.withOpacity(0.3),
            label: Text(
              area.locationName,
              style: TextStyle(
                color: Colors.blue.shade200,
                fontSize: 12,
              ),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          )).toList(),
        ),
      ],
    );
  }

  // ✅ ADDED: Missing _formatMessage method
  String _formatMessage(String message) {
    return message
        .replaceAll('\r\n', '\n')
        .replaceAll(RegExp(r'\n+'), '\n')
        .trim();
  }

  // ✅ ADDED: Missing _formatDateTime method
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, HH:mm').format(dateTime.toLocal());
  }

  // ✅ ADDED: Missing _getAlertColor method
  Color _getAlertColor(String level) {
    switch (level) {
      case 'Alert': return Colors.red;
      case 'Warning': return Colors.orange;
      case 'Watch': return Colors.yellow;
      default: return Colors.green;
    }
  }
}