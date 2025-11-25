// lib/UIscreens/aurora_forecast_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:geocoding/geocoding.dart';
import '../models/space_weather_data.dart';
import '../services/aurora_service.dart';
import '../services/settings_service.dart';
import '../services/location_service.dart';
import '../widgets/aurora_forecast_card.dart';

class AuroraForecastScreen extends StatefulWidget {
  final SpaceWeatherData? weatherData;

  const AuroraForecastScreen({Key? key, this.weatherData}) : super(key: key);

  @override
  _AuroraForecastScreenState createState() => _AuroraForecastScreenState();
}

class _AuroraForecastScreenState extends State<AuroraForecastScreen> {
  double? _latitude;
  double? _longitude;
  String? _locationName;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final lat = await SettingsService.getLocationLatitude();
    final lon = await SettingsService.getLocationLongitude();
    final name = await SettingsService.getLocationName();
    setState(() {
      _latitude = lat;
      _longitude = lon;
      _locationName = name;
    });
  }

  Future<void> _getCurrentLocation() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Getting your location...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );

    try {
      final locationData = await LocationService.getLocationWithName();
      
      if (locationData != null) {
        await SettingsService.setLocation(
          locationData['latitude'] as double,
          locationData['longitude'] as double,
          locationData['name'] as String,
        );
        
        setState(() {
          _latitude = locationData['latitude'] as double;
          _longitude = locationData['longitude'] as double;
          _locationName = locationData['name'] as String;
        });

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location updated: ${locationData['name']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to get location. Please check permissions.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentKp = widget.weatherData?.currentKp?.kpIndex ?? 0.0;
    final probability = _latitude != null
        ? AuroraService.calculateAuroraProbability(currentKp, _latitude!)
        : null;
    final level = probability != null
        ? AuroraService.getAuroraLevel(probability)
        : null;
    final forecast = _latitude != null
        ? AuroraService.getAuroraForecast(currentKp, _latitude!)
        : 'Set your location in Settings to get personalized aurora forecasts';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Aurora Forecast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showLocationSearch();
            },
            tooltip: 'Search Location',
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _getCurrentLocation();
            },
            tooltip: 'Get Current Location',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.pushNamed(context, '/settings');
              _loadLocation();
            },
            tooltip: 'Settings',
          ),
        ],
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
                // Main Forecast Card
                Card(
                  color: Colors.blueGrey[900]?.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          size: 64,
                          color: _getAuroraColor(probability),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          level ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: _getAuroraColor(probability),
                          ),
                        ),
                        if (probability != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '${(probability * 100).toStringAsFixed(0)}% Visibility Chance',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          forecast,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Current Conditions
                if (widget.weatherData != null) ...[
                  _buildInfoCard(
                    'Current Kp Index',
                    widget.weatherData!.currentKp?.kpIndex.toStringAsFixed(1) ?? 'N/A',
                    Icons.compass_calibration,
                  ),
                  const SizedBox(height: 12),
                ],
                // Aurora Forecast Card
                const AuroraForecastCard(),
                const SizedBox(height: 12),
                // Location Info
                _buildInfoCard(
                  'Location',
                  _locationName ?? 'Not set',
                  Icons.location_on,
                ),
                if (_latitude != null && _longitude != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    'Coordinates',
                    '${_latitude!.toStringAsFixed(2)}°, ${_longitude!.toStringAsFixed(2)}°',
                    Icons.map,
                  ),
                ],
                const SizedBox(height: 16),
                // Best Viewing Time
                Card(
                  color: Colors.blueGrey[900]?.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue.shade300),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Best Viewing Time',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AuroraService.getBestViewingTime(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Tips Card
                Card(
                  color: Colors.blueGrey[900]?.withOpacity(0.9),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.yellow.shade300),
                            const SizedBox(width: 8),
                            const Text(
                              'Viewing Tips',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTip('Look north after dark'),
                        _buildTip('Find a location away from city lights'),
                        _buildTip('Check weather forecast for clear skies'),
                        _buildTip('Aurora is most active 10 PM - 2 AM'),
                        _buildTip('Higher Kp index = better visibility'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.blueGrey[900]?.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue.shade300),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade300),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationSearch() {
    showDialog(
      context: context,
      builder: (context) => _LocationSearchDialog(
        onLocationSelected: (latitude, longitude, name) async {
          await SettingsService.setLocation(latitude, longitude, name);
          _loadLocation();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Location updated: $name'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  Color _getAuroraColor(double? probability) {
    if (probability == null) return Colors.grey;
    if (probability >= 0.8) return Colors.green;
    if (probability >= 0.6) return Colors.lightGreen;
    if (probability >= 0.4) return Colors.yellow;
    if (probability >= 0.2) return Colors.orange;
    return Colors.red;
  }
}

class _LocationSearchDialog extends StatefulWidget {
  final Function(double latitude, double longitude, String name) onLocationSelected;

  const _LocationSearchDialog({required this.onLocationSelected});

  @override
  State<_LocationSearchDialog> createState() => _LocationSearchDialogState();
}

class _LocationSearchDialogState extends State<_LocationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Location> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Add listener with debouncing
    _searchController.addListener(() {
      _debounceSearch();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Timer? _debounceTimer;

  void _debounceSearch() {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _searchLocation(_searchController.text);
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty || query.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final locations = await locationFromAddress(query).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Search timed out. Please try again.');
        },
      );

      if (mounted) {
        setState(() {
          _searchResults = locations;
          _isSearching = false;
          if (locations.isEmpty) {
            _errorMessage = 'No locations found. Try a different search term.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _errorMessage = 'Error searching: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> _selectLocation(Location location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      String locationName = '${location.latitude.toStringAsFixed(2)}°, ${location.longitude.toStringAsFixed(2)}°';
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        if (place.locality != null && place.locality!.isNotEmpty) {
          locationName = place.locality!;
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            locationName += ', ${place.administrativeArea}';
          }
        } else if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          locationName = place.administrativeArea!;
        } else if (place.country != null && place.country!.isNotEmpty) {
          locationName = place.country!;
        }
      }

      widget.onLocationSelected(location.latitude, location.longitude, locationName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.blueGrey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: Colors.cyan.shade300),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Search Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setStateField) {
                return TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter city, country, or address...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.location_on, color: Colors.cyan.shade300),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey[400]),
                            onPressed: () {
                              _debounceTimer?.cancel();
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _errorMessage = null;
                              });
                              setStateField(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.blueGrey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) {
                    setStateField(() {});
                  },
                  onSubmitted: (value) {
                    if (value.length >= 3) {
                      _searchLocation(value);
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            if (_isSearching)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Colors.cyan),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[300], size: 40),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_searchResults.isEmpty && _searchController.text.length >= 3)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, color: Colors.grey[400], size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'No locations found',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Try a different search term',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else if (_searchController.text.isEmpty || _searchController.text.length < 3)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.search, color: Colors.grey[500], size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'Type at least 3 characters to search',
                        style: TextStyle(color: Colors.grey[400]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else if (_searchResults.isNotEmpty)
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchResults.length > 10 ? 10 : _searchResults.length,
                  itemBuilder: (context, index) {
                    final location = _searchResults[index];
                    return Card(
                      color: Colors.blueGrey[800],
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(Icons.place, color: Colors.cyan.shade300),
                        title: Text(
                          '${location.latitude.toStringAsFixed(4)}°, ${location.longitude.toStringAsFixed(4)}°',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Tap to select this location',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.cyan.shade300, size: 16),
                        onTap: () => _selectLocation(location),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

