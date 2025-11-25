// lib/UIscreens/forecast_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/space_weather_data.dart';
import '../services/space_weather_service.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({Key? key}) : super(key: key);

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  SpaceWeatherData? _forecastData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadForecastData();
  }

  Future<void> _loadForecastData() async {
    setState(() => _isLoading = true);
    try {
      final data = await SpaceWeatherService.getSpaceWeatherData();
      setState(() => _forecastData = data);
    } catch (e) {
      print('Error loading forecast: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('3-Day Forecast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadForecastData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadForecastData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kp Forecast
                    if (_forecastData != null) ...[
                      _buildForecastSection(
                        'Kp Index Forecast',
                        Icons.compass_calibration,
                        _buildKpForecast(),
                      ),
                      const SizedBox(height: 16),
                      // Solar Wind Forecast
                      _buildForecastSection(
                        'Solar Wind Forecast',
                        Icons.air,
                        _buildSolarWindForecast(),
                      ),
                      const SizedBox(height: 16),
                      // X-Ray Flux Forecast
                      _buildForecastSection(
                        'X-Ray Flux Forecast',
                        Icons.flash_on,
                        _buildXRayForecast(),
                      ),
                    ] else
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No forecast data available',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildForecastSection(String title, IconData icon, Widget content) {
    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade300, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blue.shade300,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildKpForecast() {
    if (_forecastData == null || _forecastData!.kpData.isEmpty) {
      return const Text('No forecast data available', style: TextStyle(color: Colors.grey));
    }

    // Get forecast data (future timestamps)
    final forecastData = _forecastData!.kpData
        .where((kp) => kp.isForecast || kp.timestamp.isAfter(DateTime.now()))
        .take(12)
        .toList();

    if (forecastData.isEmpty) {
      return const Text('No forecast data available', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: forecastData.map((kp) => _buildForecastItem(
        DateFormat('MMM dd, HH:mm').format(kp.timestamp.toLocal()),
        'Kp ${kp.kpIndex.toStringAsFixed(1)}',
        _getKpColor(kp.kpIndex),
        kp.isForecast ? 'Forecast' : 'Observed',
      )).toList(),
    );
  }

  Widget _buildSolarWindForecast() {
    final currentWind = _forecastData?.currentSolarWind;
    if (currentWind == null) {
      return const Text('No forecast data available', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: [
        _buildForecastItem(
          'Current',
          '${currentWind.speed.toStringAsFixed(0)} km/s',
          _getSpeedColor(currentWind.speed),
          'Observed',
        ),
        _buildForecastItem(
          'Next 24h',
          '${(currentWind.speed * 0.9).toStringAsFixed(0)} km/s (estimated)',
          Colors.blue,
          'Estimated',
        ),
      ],
    );
  }

  Widget _buildXRayForecast() {
    final currentXRay = _forecastData?.currentXRayFlux;
    if (currentXRay == null) {
      return const Text('No forecast data available', style: TextStyle(color: Colors.grey));
    }

    return Column(
      children: [
        _buildForecastItem(
          'Current',
          currentXRay.level,
          _getXRayColor(currentXRay.level),
          'Observed',
        ),
        _buildForecastItem(
          'Next 24h',
          'Stable (estimated)',
          Colors.blue,
          'Estimated',
        ),
      ],
    );
  }

  Widget _buildForecastItem(String time, String value, Color color, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade800.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              type,
              style: TextStyle(color: Colors.blue.shade200, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Color _getKpColor(double kp) {
    if (kp >= 7) return Colors.red;
    if (kp >= 5) return Colors.orange;
    if (kp >= 4) return Colors.yellow;
    if (kp >= 3) return Colors.blue;
    return Colors.green;
  }

  Color _getSpeedColor(double speed) {
    if (speed > 700) return Colors.red;
    if (speed > 600) return Colors.orange;
    if (speed > 500) return Colors.yellow;
    if (speed > 400) return Colors.blue;
    return Colors.green;
  }

  Color _getXRayColor(String level) {
    switch (level) {
      case 'Extreme':
        return Colors.red;
      case 'Severe':
        return Colors.orange;
      case 'Strong':
        return Colors.yellow;
      case 'Moderate':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}








