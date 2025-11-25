// lib/UIscreens/about_screen.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('About Us'),
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
            child: Container(color: Colors.black.withOpacity(0.7)),
          ),
          // Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // App Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.blue.shade400.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.blue.shade800.withOpacity(0.8),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // App Name
                const Text(
                  'NOVA',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'SPACE WEATHER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Colors.blue,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 40),

                // Card 1: Our Mission
                _buildContentCard(
                  'Our Mission',
                  'Nova Space Weather provides real-time space weather data and accurate Aurora forecasts to connect you with the cosmos. We track critical phenomena to ensure you stay informed about geomagnetic activity and potential solar impacts.',
                  Icons.rocket_launch,
                ),

                const SizedBox(height: 24),

                // Card 2: Core Features & Tech
                _buildContentCard(
                  'Core Features & Technology',
                  '• Real-Time Monitoring: Instant access to Kp Index, Solar Wind speed, and X-Ray Flux data\n\n'
                  '• Localized Aurora Forecasts: Visibility predictions and optimal viewing times for your location\n\n'
                  '• Customizable Alerts: Push notifications for high Kp Index events (Kp > 5.0), Solar Flares, and Radio Blackouts\n\n'
                  '• Technical Specifications: Version 1.0.0 with data refreshed every 15 minutes',
                  Icons.analytics,
                ),

                const SizedBox(height: 24),

                // Card 3: Reliable Data Sources
                _buildContentCard(
                  'Reliable Data Sources',
                  'We are committed to providing accurate data through integration with leading global space weather agencies:\n\n'
                  '• NOAA / SWPC: Primary source for official geomagnetic storm and solar wind data\n\n'
                  '• NASA: Satellite data streams including DSCOVR for upstream solar wind measurements\n\n'
                  '• Global Observatories: Ground-based magnetometer data for comprehensive activity tracking',
                  Icons.data_usage,
                ),

                const SizedBox(height: 24),

                // Card 4: Meet the Team
                _buildContentCard(
                  'Meet the Team',
                  'Nova Space Weather is a student-led project built with passion and scientific curiosity, dedicated to making space weather accessible to everyone.\n\n'
                  '• Mentor: Dr. Shehrbano\n\n'
                  '• Project Lead: Mudassir\n'
                  '• Development: Mudassir, Nasir\n'
                  '• Data Analysis: Shiza, Hannan\n'
                  '• UI/UX Design: Zahra, Rida\n'
                  '• Research: Mujeeb, Shahzad,Amin',
                  Icons.people,
                ),

                const SizedBox(height: 24),

                // Card 5: Connect With Us
                _buildContentCard(
                  'Connect With Us',
                  'We value your feedback and are here to support your space weather journey.\n\n'
                  '• Support Email: netcode920@gmail.com\n'
                  '• Social Media: https://www.youtube.com/@netCode920\n\n'
                  'Stay connected for the latest updates and cosmic discoveries!',
                  Icons.connect_without_contact,
                ),

                const SizedBox(height: 32),
                
                // Version Info
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 Nova Space Weather',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(String title, String content, IconData icon) {
    return Card(
      color: Colors.blueGrey[900]?.withOpacity(0.9),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.blue.shade700.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with Icon
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.blue.shade300,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Content
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}