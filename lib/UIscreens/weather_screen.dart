// lib/screens/weather_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/space_weather_data.dart';
import '../services/notification_service.dart';
import '../services/space_weather_service.dart';
import '../services/alert_database_service.dart';
import '../widgets/weather_cards.dart';
import '../widgets/charts.dart';
import 'alerts_screen.dart';
import 'about_screen.dart';
import 'settings_screen.dart';
import 'aurora_forecast_screen.dart';
import 'historical_data_screen.dart';
import 'forecast_screen.dart';
import 'help_screen.dart';
import '../services/location_alert_filter.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  SpaceWeatherData? _weatherData;
  bool _isLoading = true;
  SpaceWeatherData? _previousWeatherData;

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoading = true);

    try {
      final data = await SpaceWeatherService.getSpaceWeatherData();

      // ✅ DEBUG: Print the current data state
      data.debugPrint();

      // Filter alerts by location
      final locationFilteredAlerts = await LocationAlertFilter.filterAlertsByLocation(data.alerts);
      
      // Create filtered data for display
      final filteredData = SpaceWeatherData(
        kpData: data.kpData,
        solarWind: data.solarWind,
        xRayFlux: data.xRayFlux,
        alerts: locationFilteredAlerts,
      );
      
      // Check for new alerts before updating state (use filtered alerts)
      await _checkForNewAlerts(filteredData);

      // Save all alerts to database (not just filtered)
      await AlertDatabaseService.saveAlerts(data.alerts);

      setState(() {
        _previousWeatherData = _weatherData;
        _weatherData = filteredData;
      });
    } catch (e) {
      print('Error loading weather data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _checkForNewAlerts(SpaceWeatherData newData) async {
    if (_weatherData == null) return; // Skip first load

    await NotificationService.checkForNewAlerts(
      newData.alerts,
      _weatherData!.alerts,
    );
  }

  void _navigateToAlerts() {
    if (_weatherData?.alerts != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AlertsScreen(alerts: _weatherData!.alerts),
        ),
      );
    }
  }

  void _navigateToAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  void _navigateToAurora() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuroraForecastScreen(weatherData: _weatherData),
      ),
    );
  }

  void _navigateToHistorical() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HistoricalDataScreen(),
      ),
    );
  }

  void _navigateToForecast() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForecastScreen(),
      ),
    );
  }

  void _navigateToHelp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpScreen(),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'Aurora Forecast',
            Icons.nightlight_round,
            Colors.purple,
            _navigateToAurora,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'Forecast',
            Icons.trending_up,
            Colors.orange,
            _navigateToForecast,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'History',
            Icons.history,
            Colors.blue,
            _navigateToHistorical,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.blueGrey[900],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', () {}),
            _buildNavItem(Icons.nightlight_round, 'Aurora', _navigateToAurora),
            _buildNavItem(Icons.trending_up, 'Forecast', _navigateToForecast),
            _buildNavItem(Icons.history, 'History', _navigateToHistorical),
            _buildNavItem(Icons.settings, 'Settings', _navigateToSettings),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue.shade300, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.blue.shade300,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _testNotifications() {
    NotificationService.testGeomagneticAlert();
    Future.delayed(Duration(seconds: 2), () {
      NotificationService.testSolarFlareAlert();
    });
    Future.delayed(Duration(seconds: 4), () {
      NotificationService.testRadioBlackout();
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayData = _weatherData ?? SpaceWeatherData();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text('Nova Space Weather'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _testNotifications,
            tooltip: 'Test Notifications',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeatherData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _navigateToHelp,
            tooltip: 'Help',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _navigateToAbout,
            tooltip: 'About Us',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeatherData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Quick Actions Row
              _buildQuickActions(),
              const SizedBox(height: 16),
              
              // Kp Index Card with Chart
              _buildKpCard(displayData),
              const SizedBox(height: 16),

              // Solar Wind Card with Chart
              _buildSolarWindCard(displayData),
              const SizedBox(height: 16),

              // X-Ray Flux Card with Chart
              _buildXRayFluxCard(displayData),
              const SizedBox(height: 16),

              // Alerts Card (Last 2 alerts)
              _buildAlertsCard(displayData),

              // Last Updated Timestamp
              _buildLastUpdated(displayData),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Update the _buildKpCard method in WeatherScreen
  Widget _buildKpCard(SpaceWeatherData data) {
    final currentKp = data.currentKp;
    final hasData = currentKp != null;

    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.compass_calibration, size: 18, color: Colors.blue.shade300),
                const SizedBox(width: 8),
                Text(
                  'Geomagnetic Activity',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (hasData)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getKpStatusColor(currentKp.kpIndex).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getKpStatusColor(currentKp.kpIndex)),
                    ),
                    child: Text(
                      _getKpActivityLevel(currentKp.kpIndex),
                      style: TextStyle(
                        color: _getKpStatusColor(currentKp.kpIndex),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Current Kp Value
            if (hasData)
              Row(
                children: [
                  Text(
                    'Kp ${currentKp.kpIndex.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  // Removed forecast section since we're using single data source
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: currentKp.isForecast
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.blue.shade800.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentKp.isForecast ? 'Forecast' : 'Observed',
                      style: TextStyle(
                        color: currentKp.isForecast
                            ? Colors.orange.shade300
                            : Colors.blue.shade300,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Kp data not available',
                style: TextStyle(color: Colors.grey[400]),
              ),

            const SizedBox(height: 16),

            // Kp Chart - Updated to remove kpForecast parameter
            KpChart(kpData: data.kpData),

            if (hasData) ...[
              const SizedBox(height: 8),
              Text(
                'Time: ${_formatTime(currentKp.timestamp)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }
  // Updated _buildSolarWindCard method in WeatherScreen
  Widget _buildSolarWindCard(SpaceWeatherData data) {
    final hasData = data.currentSolarWind != null && data.currentSolarWind!.speed > 0;

    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.air, size: 18, color: Colors.green.shade300),
                const SizedBox(width: 8),
                Text(
                  'Solar Wind',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (hasData) ...[
              // Main metrics without chart
              _buildSolarWindMetrics(data.currentSolarWind!),
              const SizedBox(height: 8),
              Text(
                'Updated: ${_formatTime(data.currentSolarWind!.timestamp)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ] else ...[
              Container(
                height: 60,
                alignment: Alignment.center,
                child: Text(
                  'Solar wind data not available',
                  style: TextStyle(color: Colors.grey[400]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

// Updated metrics without duplicate speed
  Widget _buildSolarWindMetrics(SolarWindData solarWind) {
    return Column(
      children: [
        // Large speed display
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getSpeedColor(solarWind.speed).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                '${solarWind.speed.toStringAsFixed(0)} km/s',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getSpeedColor(solarWind.speed).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getSpeedStatus(solarWind.speed),
                  style: TextStyle(
                    color: _getSpeedColor(solarWind.speed),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Other metrics
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bubble_chart, size: 16, color: Colors.green.shade300),
                      SizedBox(width: 4),
                      Text('Density', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${solarWind.density.toStringAsFixed(1)} p/cm³',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.thermostat, size: 16, color: Colors.green.shade300),
                      SizedBox(width: 4),
                      Text('Temperature', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${solarWind.temperature.toStringAsFixed(0)} K',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

// Helper methods
  Color _getSpeedColor(double speed) {
    if (speed > 700) return Colors.red;
    if (speed > 600) return Colors.orange;
    if (speed > 500) return Colors.yellow;
    if (speed > 400) return Colors.blue;
    return Colors.green;
  }

  String _getSpeedStatus(double speed) {
    if (speed > 700) return 'Very High';
    if (speed > 600) return 'High';
    if (speed > 500) return 'Moderate';
    if (speed > 400) return 'Normal';
    return 'Low';
  }
  Widget _buildXRayFluxCard(SpaceWeatherData data) {
    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, size: 18, color: Colors.orange.shade300),
                const SizedBox(width: 8),
                Text(
                  'X-Ray Flux',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (data.currentXRayFlux != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getXRayStatusColor(data.currentXRayFlux!.level).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data.currentXRayFlux!.level,
                      style: TextStyle(
                        color: _getXRayStatusColor(data.currentXRayFlux!.level),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            if (data.currentXRayFlux != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFluxValue('Short Term', data.currentXRayFlux!.shortTerm),
                  const SizedBox(width: 16),
                  _buildFluxValue('Long Term', data.currentXRayFlux!.longTerm),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // X-Ray Flux Chart
            XRayFluxChart(xRayData: data.xRayFlux),
            if (data.currentXRayFlux?.timestamp != null) ...[
              const SizedBox(height: 8),
              Text(
                'Updated: ${_formatTime(data.currentXRayFlux!.timestamp)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFluxValue(String type, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          const SizedBox(height: 4),
          Text('${value.toStringAsExponential(1)} W/m²',
              style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildAlertsCard(SpaceWeatherData data) {
    // Sort by issued time (most recent first) and take last 2
    final sortedAlerts = List<SpaceAlert>.from(data.alerts)
      ..sort((a, b) => b.issuedTime.compareTo(a.issuedTime));
    final recentAlerts = sortedAlerts.take(2).toList();

    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, size: 18, color: Colors.orange.shade300),
                const SizedBox(width: 8),
                Text(
                  'Space Weather Alerts',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (data.alerts.isNotEmpty)
                  TextButton(
                    onPressed: _navigateToAlerts,
                    child: Text('See All (${data.alerts.length})',
                        style: TextStyle(color: Colors.blue.shade300)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (recentAlerts.isNotEmpty)
              ...recentAlerts.map((alert) => _buildAlertItem(alert)),
            if (recentAlerts.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 32),
                    const SizedBox(height: 8),
                    Text('No Active Alerts', style: TextStyle(color: Colors.green)),
                    const SizedBox(height: 4),
                    Text('All space weather systems are normal',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
              ),
            if (data.alerts.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.more_horiz, color: Colors.blue.shade300, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${data.alerts.length - 2} more alerts',
                      style: TextStyle(color: Colors.blue.shade300, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(SpaceAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getAlertColor(alert.level).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getAlertColor(alert.level).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getAlertColor(alert.level).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert.level.toUpperCase(),
                  style: TextStyle(
                    color: _getAlertColor(alert.level),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              Text(
                _formatTime(alert.issuedTime),
                style: TextStyle(color: Colors.grey[400], fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.type,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getShortMessage(alert.message),
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(SpaceWeatherData data) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
          const SizedBox(width: 4),
          Text(
            'Last updated: ${_formatDateTime(data.lastUpdated)}',
            style: TextStyle(color: Colors.grey[500], fontSize: 10),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getShortMessage(String fullMessage) {
    final sentences = fullMessage.split('\r\n');
    for (final sentence in sentences) {
      if (sentence.isNotEmpty &&
          !sentence.contains('Space Weather Message Code') &&
          !sentence.contains('NOAA Scale') &&
          !sentence.contains('www.swpc.noaa.gov')) {
        return sentence.length > 100
            ? '${sentence.substring(0, 100)}...'
            : sentence;
      }
    }
    return fullMessage.length > 100
        ? '${fullMessage.substring(0, 100)}...'
        : fullMessage;
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time.toLocal());
  }

  String _formatDateTime(DateTime time) {
    return DateFormat('MMM dd, HH:mm').format(time.toLocal());
  }

  Color _getKpStatusColor(double kp) {
    if (kp >= 7) return Colors.red;
    if (kp >= 5) return Colors.orange;
    if (kp >= 4) return Colors.yellow;
    if (kp >= 3) return Colors.blue;
    return Colors.green;
  }

  String _getKpActivityLevel(double kp) {
    if (kp >= 7) return 'Strong Storm';
    if (kp >= 5) return 'Minor Storm';
    if (kp >= 4) return 'Active';
    if (kp >= 3) return 'Unsettled';
    return 'Quiet';
  }

  Color _getXRayStatusColor(String level) {
    switch (level) {
      case 'Extreme': return Colors.red;
      case 'Severe': return Colors.orange;
      case 'Strong': return Colors.yellow;
      case 'Moderate': return Colors.blue;
      default: return Colors.green;
    }
  }

  Color _getAlertColor(String level) {
    switch (level) {
      case 'Alert': return Colors.red;
      case 'Warning': return Colors.orange;
      case 'Watch': return Colors.yellow;
      default: return Colors.green;
    }
  }
}