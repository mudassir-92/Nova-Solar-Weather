// lib/UIscreens/help_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.blue.shade400.withOpacity(0.3),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.help_outline, color: Colors.blue.shade300, size: 20);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('Help & Education'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Lottie.asset(
              'assets/bg.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kp Index Section
                _buildSection(
                  context,
                  'What is Kp Index?',
                  Icons.compass_calibration,
                  'The Kp index measures geomagnetic activity on a scale from 0 to 9. Higher values indicate stronger geomagnetic storms.\n\n'
                  '• Kp 0-2: Quiet conditions\n'
                  '• Kp 3-4: Unsettled to active\n'
                  '• Kp 5: Minor geomagnetic storm\n'
                  '• Kp 6: Moderate storm\n'
                  '• Kp 7-9: Strong to extreme storm\n\n'
                  'Higher Kp values can cause aurora to be visible at lower latitudes.',
                ),
                const SizedBox(height: 16),
                // Solar Wind Section
                _buildSection(
                  context,
                  'Solar Wind',
                  Icons.air,
                  'Solar wind is a stream of charged particles released from the Sun.\n\n'
                  '• Normal speed: 300-400 km/s\n'
                  '• Moderate: 400-600 km/s\n'
                  '• High: 600-700 km/s\n'
                  '• Very High: >700 km/s\n\n'
                  'Higher solar wind speeds can enhance geomagnetic activity and aurora visibility.',
                ),
                const SizedBox(height: 16),
                // X-Ray Flux Section
                _buildSection(
                  context,
                  'X-Ray Flux',
                  Icons.flash_on,
                  'X-ray flux measures solar X-ray emissions, indicating solar flare activity.\n\n'
                  '• Normal: <1e-6 W/m²\n'
                  '• Moderate: 1e-6 to 1e-5 W/m²\n'
                  '• Strong: 1e-5 to 1e-4 W/m²\n'
                  '• Severe: 1e-4 to 1e-3 W/m²\n'
                  '• Extreme: >1e-3 W/m²\n\n'
                  'High X-ray flux can cause radio blackouts and affect satellite communications.',
                ),
                const SizedBox(height: 16),
                // Aurora Section
                _buildSection(
                  context,
                  'Aurora Viewing Tips',
                  Icons.nightlight_round,
                  'To see the aurora (Northern/Southern Lights):\n\n'
                  '• Look north (or south in Southern Hemisphere)\n'
                  '• Best time: 10 PM - 2 AM local time\n'
                  '• Find dark location away from city lights\n'
                  '• Check weather for clear skies\n'
                  '• Higher Kp index = better visibility\n'
                  '• Higher latitude = better chance\n\n'
                  'Aurora is typically visible at latitudes above 60°, but strong storms (Kp 5+) can make it visible at lower latitudes.',
                ),
                const SizedBox(height: 16),
                // Alerts Section
                _buildSection(
                  context,
                  'Understanding Alerts',
                  Icons.warning,
                  'Space weather alerts notify you of important events:\n\n'
                  '• Alert: Immediate action may be needed\n'
                  '• Warning: Significant event expected\n'
                  '• Watch: Conditions favorable for events\n\n'
                  'Alerts are location-based - you\'ll only receive alerts relevant to your area. Set your location in Settings for personalized alerts.',
                ),
                const SizedBox(height: 16),
                // Impacts Section
                _buildSection(
                  context,
                  'Space Weather Impacts',
                  Icons.satellite_alt,
                  'Space weather can affect:\n\n'
                  '• Power grids - can cause fluctuations\n'
                  '• Satellite operations - communication disruptions\n'
                  '• GPS accuracy - navigation errors\n'
                  '• Radio communications - blackouts\n'
                  '• Aviation - high-altitude radiation\n'
                  '• Aurora visibility - beautiful light displays\n\n'
                  'Most impacts are minor, but severe storms can cause significant disruptions.',
                ),
                const SizedBox(height: 16),
                // FAQ Section
                _buildSection(
                  context,
                  'Frequently Asked Questions',
                  Icons.help_outline,
                  'Q: How often is data updated?\n'
                  'A: Data is updated every 15 minutes by default. You can change this in Settings.\n\n'
                  'Q: Why don\'t I see aurora at my location?\n'
                  'A: Aurora visibility depends on your latitude and Kp index. Higher latitudes and higher Kp values increase visibility.\n\n'
                  'Q: Are alerts location-based?\n'
                  'A: Yes! Alerts are filtered based on your location to show only relevant information.\n\n'
                  'Q: Can I use the app offline?\n'
                  'A: You can view cached data offline, but new data requires an internet connection.',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    String content,
  ) {
    return Card(
      color: Colors.blueGrey[900]?.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue.shade300, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.blue.shade300,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

