import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nova2/models/space_weather_data.dart';
import 'package:nova2/services/notification_service.dart';
import 'package:nova2/services/background_alert_service.dart';
import 'package:nova2/services/location_service.dart';
import 'package:nova2/services/settings_service.dart';
import 'package:nova2/theme/space_theme.dart';
import 'package:nova2/UIscreens/SplashScreenUI.dart';
import 'package:nova2/UIscreens/aurora_forecast_screen.dart';
import 'package:nova2/UIscreens/sun/sun_details_screen.dart';
import 'package:nova2/UIscreens/ionosphere/ionosphere_model_screen.dart';
import 'package:nova2/UIscreens/forecast_screen.dart';
import 'package:nova2/UIscreens/alerts_screen.dart';
import 'package:nova2/UIscreens/settings_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize sqflite for desktop platforms using FFI
  if (!kIsWeb &&
      (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize notifications
  await NotificationService.initialize();

  // Request location permission on first app start
  final hasRequested = await SettingsService.hasLocationBeenRequested();
  if (!hasRequested) {
    final permission = await LocationService.checkPermission();
    if (permission == LocationPermission.denied) {
      await LocationService.requestPermission();
    }
    await SettingsService.setLocationRequested(true);
    
    // Try to get location and save it
    final locationData = await LocationService.getLocationWithName();
    if (locationData != null) {
      await SettingsService.setLocation(
        locationData['latitude'] as double,
        locationData['longitude'] as double,
        locationData['name'] as String,
      );
    }
  }

  // Start background alert checking service
  await BackgroundAlertService.start();

  // Run the app with proper animation settings
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova Space Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.dark(
          primary: Colors.cyan[400]!,
          secondary: Colors.amber[300]!,
          background: const Color(0xFF0A0E21),
          surface: const Color(0xFF1D1E33),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E21),
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        cardTheme: ThemeData.dark().cardTheme.copyWith(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: const Color(0xFF1D1E33),
          margin: const EdgeInsets.all(8.0),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MainHomeScreen(),
        '/aurora': (context) => const AuroraForecastScreen(),
        '/sun': (context) => const SunDetailsScreen(),
        '/ionosphere': (context) => const IonosphereModelScreen(),
        '/forecast': (context) => const ForecastScreen(),
        '/alerts': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as List<SpaceAlert>?;
          return AlertsScreen(alerts: args ?? []);
        },
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Space Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 32),
              _buildFeatureGrid(context, theme),
              const SizedBox(height: 24),
              _buildQuickAccess(context, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        const Icon(Icons.rocket_launch, size: 80, color: Colors.cyan)
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .shimmer(delay: 200.ms, duration: 1000.ms),
        const SizedBox(height: 16),
        Text(
          'Welcome to Nova Space Weather!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 800.ms),
        const SizedBox(height: 8),
        Text(
          'Monitor space weather conditions and get real-time alerts',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
      ],
    );
  }

  Widget _buildFeatureGrid(BuildContext context, ThemeData theme) {
    final features = [
      {
        'title': 'Aurora Forecast',
        'icon': Icons.nightlight_round,
        'route': '/aurora',
        'color': Colors.purple,
      },
      {
        'title': 'Sun Activity',
        'icon': Icons.wb_sunny,
        'route': '/sun',
        'color': Colors.amber,
      },
      {
        'title': 'Ionosphere',
        'icon': Icons.waves,
        'route': '/ionosphere',
        'color': Colors.blue,
      },
      {
        'title': 'Space Weather',
        'icon': Icons.cloud,
        'route': '/forecast',
        'color': Colors.green,
      },
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: features.map((feature) {
        return _buildFeatureCard(
          context: context,
          title: feature['title'] as String,
          icon: feature['icon'] as IconData,
          color: feature['color'] as Color,
          onTap: () => Navigator.pushNamed(context, feature['route'] as String),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.notifications_active,
                  color: Colors.red,
                ),
                title: const Text('Alerts & Notifications'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/alerts'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blueGrey),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
