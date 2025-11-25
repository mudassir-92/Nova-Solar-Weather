// lib/UIscreens/historical_data_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/space_weather_data.dart';
import '../services/alert_database_service.dart';
import '../widgets/charts.dart';

class HistoricalDataScreen extends StatefulWidget {
  const HistoricalDataScreen({Key? key}) : super(key: key);

  @override
  _HistoricalDataScreenState createState() => _HistoricalDataScreenState();
}

class _HistoricalDataScreenState extends State<HistoricalDataScreen> {
  int _selectedDays = 7;
  List<SpaceAlert> _historicalAlerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }

  Future<void> _loadHistoricalData() async {
    setState(() => _isLoading = true);
    try {
      final alerts = await AlertDatabaseService.getAllAlerts();
      final cutoffDate = DateTime.now().subtract(Duration(days: _selectedDays));
      _historicalAlerts = alerts
          .where((alert) => alert.issuedTime.isAfter(cutoffDate))
          .toList();
    } catch (e) {
      print('Error loading historical data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Historical Data'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _selectedDays = value);
              _loadHistoricalData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 days')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary Card
                  Card(
                    color: Colors.blueGrey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Summary',
                            style: TextStyle(
                              color: Colors.blue.shade300,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Total Alerts',
                                  '${_historicalAlerts.length}',
                                  Icons.warning,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'Period',
                                  '$_selectedDays days',
                                  Icons.calendar_today,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Alerts List
                  if (_historicalAlerts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No historical data',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._historicalAlerts.map((alert) => _buildAlertCard(alert)),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade300, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildAlertCard(SpaceAlert alert) {
    return Card(
      color: Colors.blueGrey[900],
      margin: const EdgeInsets.only(bottom: 12),
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
                    alert.level,
                    style: TextStyle(
                      color: _getAlertColor(alert.level),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(alert.issuedTime.toLocal()),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert.type,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              alert.message.length > 150
                  ? '${alert.message.substring(0, 150)}...'
                  : alert.message,
              style: TextStyle(color: Colors.grey[300], fontSize: 14),
            ),
            if (alert.kpIndex != null) ...[
              const SizedBox(height: 8),
              Text(
                'Kp Index: ${alert.kpIndex}',
                style: TextStyle(color: Colors.blue.shade300, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getAlertColor(String level) {
    switch (level) {
      case 'Alert':
        return Colors.red;
      case 'Warning':
        return Colors.orange;
      case 'Watch':
        return Colors.yellow;
      default:
        return Colors.green;
    }
  }
}








