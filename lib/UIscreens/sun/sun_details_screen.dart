import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SunDetailsScreen extends StatefulWidget {
  const SunDetailsScreen({Key? key}) : super(key: key);

  @override
  _SunDetailsScreenState createState() => _SunDetailsScreenState();
}

class _SunDetailsScreenState extends State<SunDetailsScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.network(
      'https://sdo.gsfc.nasa.gov/assets/img/latest/mpeg/latest_1024_0193.mp4',
    )..initialize().then((_) {
        setState(() {
          _isVideoInitialized = true;
          _videoController.setLooping(true);
          _videoController.play();
        });
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solar Activity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSolarVideo(),
            const SizedBox(height: 20),
            _buildMagnetogramCard(),
            const SizedBox(height: 20),
            _buildSunspotRegionsCard(),
            const SizedBox(height: 20),
            _buildMagneticPolarityCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarVideo() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'SDO 193Å (Extreme UV)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isVideoInitialized
                ? VideoPlayer(_videoController)
                : const Center(child: CircularProgressIndicator()),
          ),
          ButtonBar(
            children: [
              IconButton(
                icon: Icon(
                  _videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                onPressed: () {
                  setState(() {
                    _videoController.value.isPlaying
                        ? _videoController.pause()
                        : _videoController.play();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMagnetogramCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Solar Magnetogram (HMI)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          GestureDetector(
            onTap: () => _showFullScreenImage(
              'https://sdo.gsfc.nasa.gov/assets/img/latest/latest_1024_HMIB.jpg',
            ),
            child: Hero(
              tag: 'magnetogram',
              child: CachedNetworkImage(
                imageUrl:
                    'https://sdo.gsfc.nasa.gov/assets/img/latest/latest_1024_HMIB.jpg',
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              'Magnetic field lines on the Sun, with black and white indicating opposite magnetic polarities.',
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunspotRegionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Sunspot Regions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('No active regions detected', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildMagneticPolarityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Magnetic Polarity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Solar Cycle 25 is currently active', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black87,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Hero(
                tag: 'magnetogram',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
