// lib/widgets/aurora_forecast_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AuroraForecastCard extends StatefulWidget {
  const AuroraForecastCard({Key? key}) : super(key: key);

  @override
  State<AuroraForecastCard> createState() => _AuroraForecastCardState();
}

class _AuroraForecastCardState extends State<AuroraForecastCard> {
  bool _showNorthern = true;

  // Image URLs from NOAA
  static const String _northernImageUrl =
      'https://services.swpc.noaa.gov/images/aurora-forecast-northern-hemisphere.jpg';
  static const String _southernImageUrl =
      'https://services.swpc.noaa.gov/images/aurora-forecast-southern-hemisphere.jpg';

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[900]?.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Toggle
            Row(
              children: [
                Icon(Icons.nightlight_round, color: Colors.cyan.shade300),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Aurora Forecast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Toggle button
                ToggleButtons(
                  isSelected: [_showNorthern, !_showNorthern],
                  onPressed: (index) {
                    setState(() {
                      _showNorthern = index == 0;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  selectedColor: Colors.white,
                  fillColor: Colors.cyan.withOpacity(0.3),
                  color: Colors.grey,
                  constraints: const BoxConstraints(
                    minHeight: 32,
                    minWidth: 60,
                  ),
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('North', style: TextStyle(fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('South', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Aurora forecast image
            _buildAuroraImage(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuroraImage() {
    final imageUrl = _showNorthern ? _northernImageUrl : _southernImageUrl;
    final hemisphere = _showNorthern ? 'Northern' : 'Southern';

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.blueGrey[800],
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.blueGrey[800],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load $hemisphere hemisphere forecast',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
