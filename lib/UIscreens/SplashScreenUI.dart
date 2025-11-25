import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nova2/UIscreens/weather_screen.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    _scaleController.forward().then((_) {
      _fadeController.forward().then((_) {
        Future.delayed(const Duration(seconds: 1), () {
          _navigateToHome();
        });
      });
    });
  }

  // ✅ FIX: Navigation method that uses the correct context
  void _navigateToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => WeatherScreen()));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full Background Lottie Animation
          Positioned.fill(
            child: Lottie.asset(
              'assets/fsb.json',
              fit: BoxFit.cover,
              repeat: false, // Stop infinite looping
            ),
          ),

          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                          child: Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 50,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // App Name with Animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    'NOVA',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 6.0,
                      shadows: [
                        Shadow(
                          blurRadius: 15.0,
                          color: Colors.blue.shade300,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Subtitle with Animation
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'SPACE WEATHER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: Colors.blue.shade200,
                      letterSpacing: 4.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading Indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.blue.shade200, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
