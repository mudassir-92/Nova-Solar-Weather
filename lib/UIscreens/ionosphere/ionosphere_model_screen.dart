import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class IonosphereModelScreen extends StatefulWidget {
  const IonosphereModelScreen({Key? key}) : super(key: key);

  @override
  _IonosphereModelScreenState createState() => _IonosphereModelScreenState();
}

class _IonosphereModelScreenState extends State<IonosphereModelScreen> {
  final String _ionosphereImageUrl =
      'https://services.swpc.noaa.gov/images/animations/wam-ipe/ionosphere/WFS_IPE05_GLOBAL_TEC-MUF-TEC-MUF_20230802T0600_20230802T0400.png';
  int _currentFrame = 0;
  final int _totalFrames = 10; // Example total frames

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ionosphere Model'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildIonosphereImage(),
          ),
          _buildControls(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildIonosphereImage() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swipe right
          setState(() {
            _currentFrame = (_currentFrame - 1).clamp(0, _totalFrames - 1);
          });
        } else if (details.primaryVelocity! < 0) {
          // Swipe left
          setState(() {
            _currentFrame = (_currentFrame + 1).clamp(0, _totalFrames - 1);
          });
        }
      },
      child: PhotoView(
        imageProvider: NetworkImage(_ionosphereImageUrl),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 2.0,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.cyan),
            onPressed: _currentFrame > 0
                ? () => setState(() => _currentFrame--)
                : null,
          ),
          Text(
            'Frame ${_currentFrame + 1} of $_totalFrames',
            style: const TextStyle(color: Colors.white70),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.cyan),
            onPressed: _currentFrame < _totalFrames - 1
                ? () => setState(() => _currentFrame++)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Electron Content (TEC)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'TEC is measured in TEC Units (TECU) where 1 TECU = 10¹⁶ electrons/m²',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: 8),
          Text(
            'MUF (Maximum Usable Frequency)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'MUF is the highest frequency that can be used for radio communication between two points via the ionosphere.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
