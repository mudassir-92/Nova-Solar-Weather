// lib/widgets/weather_cards.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/space_weather_data.dart';
import 'charts.dart';

class KpCard extends StatelessWidget {
  final SpaceWeatherData weatherData;
  final bool isLoading;

  const KpCard({
    Key? key,
    required this.weatherData,
    this.isLoading = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WeatherCard(
      title: 'Geomagnetic Activity (Kp Index)',
      icon: Icons.compass_calibration,
      isLoading: isLoading,
      lastUpdated: weatherData.currentKp?.timestamp,
      child: weatherData.currentKp != null ? _buildContent() : _buildNoData(),
    );
  }

  Widget _buildContent() {
    final currentKp = weatherData.currentKp!;
    final statusColor = _getStatusColor(currentKp.kpIndex);
    final activityLevel = _getActivityLevel(currentKp.kpIndex);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Kp ${currentKp.kpIndex.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                activityLevel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        KpChart(
          kpData: weatherData.kpData,
        ),
        SizedBox(height: 8),
        _buildDataInfo(),
      ],
    );
  }

  Widget _buildDataInfo() {
    final currentKp = weatherData.currentKp;
    if (currentKp == null) return SizedBox();

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: currentKp.isForecast
            ? Colors.orange.withOpacity(0.2)
            : Colors.blue.shade800.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            currentKp.isForecast ? Icons.arrow_forward : Icons.check_circle,
            size: 16,
            color: currentKp.isForecast ? Colors.orange.shade300 : Colors.blue.shade300,
          ),
          SizedBox(width: 8),
          Text(
            currentKp.isForecast ? 'Forecast Data' : 'Observed Data',
            style: TextStyle(
                color: currentKp.isForecast ? Colors.orange.shade300 : Colors.blue.shade300,
                fontSize: 12
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Text('Kp data not available', style: TextStyle(color: Colors.grey[400]));
  }

  String _getActivityLevel(double kp) {
    if (kp >= 7) return 'Strong Storm';
    if (kp >= 5) return 'Minor Storm';
    if (kp >= 4) return 'Active';
    if (kp >= 3) return 'Unsettled';
    return 'Quiet';
  }

  Color _getStatusColor(double kp) {
    if (kp >= 7) return Colors.red;
    if (kp >= 5) return Colors.orange;
    if (kp >= 4) return Colors.yellow;
    if (kp >= 3) return Colors.blue;
    return Colors.green;
  }
}
class SolarWindCard extends StatelessWidget {
  final SpaceWeatherData weatherData;
  final bool isLoading;

  const SolarWindCard({
    Key? key,
    required this.weatherData,
    this.isLoading = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WeatherCard(
      title: 'Solar Wind',
      icon: Icons.air,
      isLoading: isLoading,
      lastUpdated: weatherData.currentSolarWind?.timestamp,
      child: weatherData.currentSolarWind != null ? _buildContent() : _buildNoData(),
    );
  }

  Widget _buildContent() {
    final current = weatherData.currentSolarWind!;
    final statusColor = _getSpeedColor(current.speed);
    final statusText = _getSpeedStatus(current.speed);

    return Column(
      children: [
        // Large Speed Display
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Text(
                '${current.speed.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'km/s',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        // Metrics
        Row(
          children: [
            _buildMetric('Density', '${current.density.toStringAsFixed(1)} p/cm³', Icons.bubble_chart),
            SizedBox(width: 16),
            _buildMetric('Temperature', '${current.temperature.toStringAsFixed(0)} K', Icons.thermostat),
          ],
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.green.shade300),
              SizedBox(width: 4),
              Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
            ],
          ),
          SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Text('Solar wind data not available', style: TextStyle(color: Colors.grey[400]));
  }

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
}
class XRayFluxCard extends StatelessWidget {
  final SpaceWeatherData weatherData;
  final bool isLoading;

  const XRayFluxCard({
    Key? key,
    required this.weatherData,
    this.isLoading = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WeatherCard(
      title: 'X-Ray Flux',
      icon: Icons.flash_on,
      isLoading: isLoading,
      lastUpdated: weatherData.currentXRayFlux?.timestamp,
      child: weatherData.currentXRayFlux != null ? _buildContent() : _buildNoData(),
    );
  }

  Widget _buildContent() {
    final current = weatherData.currentXRayFlux!;
    final statusColor = _getStatusColor(current.level);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(current.level, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Active', style: TextStyle(color: statusColor, fontSize: 10)),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildFluxValue('Current', current.shortTerm),
            SizedBox(width: 16),
            _buildFluxValue('Avg', current.longTerm),
          ],
        ),
        SizedBox(height: 16),
        XRayFluxChart(xRayData: weatherData.xRayFlux),
      ],
    );
  }

  Widget _buildFluxValue(String type, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(type, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          SizedBox(height: 4),
          Text('${value.toStringAsExponential(1)} W/m²',
              style: TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Text('X-ray flux data not available', style: TextStyle(color: Colors.grey[400]));
  }

  Color _getStatusColor(String level) {
    switch (level) {
      case 'Extreme': return Colors.red;
      case 'Severe': return Colors.orange;
      case 'Strong': return Colors.yellow;
      case 'Moderate': return Colors.blue;
      default: return Colors.green;
    }
  }
}

class AlertsCard extends StatelessWidget {
  final List<SpaceAlert> alerts;
  final VoidCallback? onSeeAll;
  final bool isLoading;

  const AlertsCard({
    Key? key,
    required this.alerts,
    this.onSeeAll,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _WeatherCard(
      title: 'Space Weather Alerts',
      icon: Icons.warning,
      isLoading: isLoading,
      trailing: alerts.isNotEmpty ? TextButton(
        onPressed: onSeeAll,
        child: Text('See All (${alerts.length})',
            style: TextStyle(color: Colors.blue.shade300)),
      ) : null,
      child: alerts.isNotEmpty ? _buildAlertsList() : _buildNoAlerts(),
    );
  }

  Widget _buildAlertsList() {
    final displayedAlerts = alerts.take(2).toList();

    return Column(
      children: [
        ...displayedAlerts.map((alert) => _buildAlertItem(alert)),
        if (alerts.length > 2)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.more_horiz, color: Colors.blue.shade300, size: 16),
                SizedBox(width: 4),
                Text(
                  '${alerts.length - 2} more alerts',
                  style: TextStyle(color: Colors.blue.shade300, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAlertItem(SpaceAlert alert) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
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
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          SizedBox(height: 8),
          Text(
            alert.type,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
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

  Widget _buildNoAlerts() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 32),
          SizedBox(height: 8),
          Text('No Active Alerts', style: TextStyle(color: Colors.green)),
          SizedBox(height: 4),
          Text('All space weather systems are normal',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Color _getAlertColor(String level) {
    switch (level) {
      case 'Alert': return Colors.red;
      case 'Warning': return Colors.orange;
      case 'Watch': return Colors.yellow;
      default: return Colors.green;
    }
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time.toLocal());
  }
}

class _WeatherCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final bool isLoading;
  final DateTime? lastUpdated;

  const _WeatherCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.isLoading = false,
    this.lastUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 18, color: Colors.blue.shade300),
                    SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (lastUpdated != null) ...[
              SizedBox(height: 4),
              Text(
                'Updated: ${_formatTime(lastUpdated!)}',
                style: TextStyle(color: Colors.grey[500], fontSize: 10),
              ),
            ],
            SizedBox(height: 12),
            if (isLoading)
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              child,
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time.toLocal());
  }
}