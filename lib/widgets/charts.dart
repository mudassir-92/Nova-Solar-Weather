// lib/widgets/charts.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/space_weather_data.dart';

class KpChart extends StatelessWidget {
  final List<KpData> kpData;

  const KpChart({Key? key, required this.kpData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kpData.isEmpty) return _buildEmptyChart('No Kp data available');

    // Sort data by timestamp to ensure correct order
    final sortedData = List<KpData>.from(kpData)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Find current Kp index (closest to now)
    final now = DateTime.now();
    final currentIndex = _findCurrentKpIndex(sortedData, now);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey[800]!,
                strokeWidth: 0.5,
              );
            },
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 8 == 0 && value < sortedData.length) {
                    final dataPoint = sortedData[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _formatDateTime(dataPoint.timestamp),
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 2 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(color: Colors.grey[400], fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey[700]!, width: 1),
          ),
          lineBarsData: [
            // Main Kp line
            LineChartBarData(
              spots: sortedData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.kpIndex);
              }).toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              belowBarData: BarAreaData(show: false),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Highlight current point with different color
                  if (index == currentIndex) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: Colors.white,
                      strokeWidth: 2,
                      strokeColor: Colors.blue,
                    );
                  }
                  // Show smaller dots for other points
                  return FlDotCirclePainter(
                    radius: 2,
                    color: Colors.blue.withOpacity(0.6),
                  );
                },
              ),
            ),
          ],
          minY: 0,
          maxY: 9,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              // tooltipBgColor: Colors.blueGrey[800]!,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((touchedSpot) {
                  final index = touchedSpot.spotIndex.toInt();
                  final dataPoint = sortedData[index];
                  final isCurrent = index == currentIndex;

                  return LineTooltipItem(
                    '${isCurrent ? '🟢 ' : ''}Kp ${dataPoint.kpIndex.toStringAsFixed(1)}\n${_formatDateTime(dataPoint.timestamp)}',
                    TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal
                    ),
                  );
                }).toList();
              },
            ),
          ),
          // Remove the showingTooltipIndicators line completely, or use this alternative:
          // showingTooltipIndicators: currentIndex != -1
          //   ? [
          //       ShowingTooltipIndicator(
          //         showingSpots: [FlSpot(currentIndex.toDouble(), sortedData[currentIndex].kpIndex)],
          //       )
          //     ]
          //   : [],
        ),
      ),
    );
  }

  int _findCurrentKpIndex(List<KpData> data, DateTime now) {
    if (data.isEmpty) return -1;

    int closestIndex = 0;
    Duration smallestDifference = data[0].timestamp.difference(now).abs();

    for (int i = 1; i < data.length; i++) {
      final difference = data[i].timestamp.difference(now).abs();
      if (difference < smallestDifference) {
        smallestDifference = difference;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  String _formatDateTime(DateTime date) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(localDate.year, localDate.month, localDate.day);

    if (dateDay == today) {
      return DateFormat('HH:mm').format(localDate); // Today - show time only
    } else if (dateDay == today.subtract(Duration(days: 1))) {
      return 'Yesterday'; // Yesterday
    } else {
      return DateFormat('MM/dd').format(localDate); // Other days - show date
    }
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }
}
class SolarWindChart extends StatelessWidget {
  final SolarWindData? currentWind;

  const SolarWindChart({Key? key, required this.currentWind}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentWind == null) {
      return _buildEmptyChart('No solar wind data');
    }

    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large speed value
          Text(
            '${currentWind!.speed.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _getSpeedColor(currentWind!.speed),
            ),
          ),
          SizedBox(height: 8),
          // Unit label
          Text(
            'km/s',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 12),
          // Status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getSpeedColor(currentWind!.speed).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getSpeedColor(currentWind!.speed)),
            ),
            child: Text(
              _getSpeedStatus(currentWind!.speed),
              style: TextStyle(
                color: _getSpeedColor(currentWind!.speed),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 8),
          // Additional info
          Text(
            'Solar Wind Speed',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[700]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }
}

class XRayFluxChart extends StatelessWidget {
  final List<XRayFluxData> xRayData;

  const XRayFluxChart({Key? key, required this.xRayData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (xRayData.isEmpty) return _buildEmptyChart('No X-ray flux data');

    return Container(
      height: 150,
      padding: const EdgeInsets.all(8),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % 4 == 0 && value < xRayData.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        DateFormat('HH:mm').format(xRayData[value.toInt()].timestamp.toLocal()),
                        style: TextStyle(color: Colors.grey[400], fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${(value * 1e7).toInt()}e-7',
                    style: TextStyle(color: Colors.grey[400], fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: xRayData.asMap().entries.map((e) {
            final value = e.value.shortTerm;
            final color = _getColorForValue(value);
            // Scale value for better visibility (convert from W/m² to scaled value)
            // X-ray flux values are typically 1e-7 to 1e-3, so multiply by 1e7 to get 0.1 to 10000 range
            final scaledValue = value * 1e7;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: scaledValue.clamp(0.0, 10000.0), // Clamp to reasonable range
                  color: color,
                  width: 4,
                ),
              ],
            );
          }).toList(),
          minY: 0,
          maxY: 100, // Max value for scaled data (represents 1e-5 W/m²)
        ),
      ),
    );
  }

  Widget _buildEmptyChart(String message) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(color: Colors.grey[400]),
      ),
    );
  }

  Color _getColorForValue(double value) {
    if (value > 1e-3) return Colors.red;
    if (value > 1e-4) return Colors.orange;
    if (value > 1e-5) return Colors.yellow;
    if (value > 1e-6) return Colors.blue;
    return Colors.green;
  }
}