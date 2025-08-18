import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../nearby_services_search.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sos_incendio/screens/service_results_screen.dart';


class FireMapScreen extends StatefulWidget {
  final String selectedServiceType;
  const FireMapScreen({Key? key, required this.selectedServiceType}) : super(key: key);
  @override
  _FireMapScreenState createState() => _FireMapScreenState();
}

class _FireMapScreenState extends State<FireMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  bool _locationInitialized = false;
  List<NearbyService> _nearbyServices = [];
  bool _loadingServices = false;
  late String _selectedServiceType;
  double _searchRadius = 10000; // Default radius in meters
  final Map<String, String> _serviceTypes = {
    'Bomberos': 'fire_station',
    'Policía': 'police',
    'Hospital': 'hospital',
    'Protección Civil': 'local_government_office',
  };
  final Map<String, IconData> _serviceIcons = {
    'fire_station': Icons.local_fire_department,
    'police': Icons.local_police,
    'hospital': Icons.local_hospital,
    'local_government_office': Icons.shield,
  };

  @override
  void initState() {
  super.initState();
  _selectedServiceType = widget.selectedServiceType;
  _initializeLocation();
  }

  void _initializeLocation() async {
    _currentPosition = await getCurrentLocation();
    if (_currentPosition != null && _mapController != null && !_locationInitialized) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15,
        ),
      );
      setState(() {
        _locationInitialized = true;
      });
    }
  }

  Future<void> _searchAndShowServices(LatLng position) async {
    setState(() {
      _loadingServices = true;
    });
    final type = _selectedServiceType;
    final services = await searchNearbyServices(position.latitude, position.longitude, type, radius: _searchRadius.toInt());
    setState(() {
      _loadingServices = false;
    });
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceResultsScreen(
          services: services,
          selectedLat: position.latitude,
          selectedLng: position.longitude,
          serviceTypeName: _serviceTypes.entries.firstWhere((e) => e.value == type).key,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('SOS REPORT'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _serviceTypes.entries.map((entry) {
                      final isSelected = _selectedServiceType == entry.value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedServiceType = entry.value;
                          });
                          if (_selectedLocation != null) {
                            _searchAndShowServices(_selectedLocation!);
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.deepOrange : Colors.grey[300],
                                shape: BoxShape.circle,
                                boxShadow: isSelected
                                    ? [BoxShadow(color: Colors.deepOrange.withOpacity(0.3), blurRadius: 8)]
                                    : [],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Icon(
                                _serviceIcons[entry.value],
                                size: 36,
                                color: isSelected ? Colors.white : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.deepOrange : Colors.black54)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: 16),
                Text('Search radius: ${(_searchRadius/1000).toStringAsFixed(1)} km'),
                Slider(
                  value: _searchRadius,
                  min: 1000,
                  max: 20000,
                  divisions: 19,
                  label: '${(_searchRadius/1000).toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() {
                      _searchRadius = value;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_selectedLocation != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'),
                ],
              ),
            ),
          if (_loadingServices)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Searching nearby services...'),
                ],
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : LatLng(0, 0),
                zoom: _currentPosition != null ? 15 : 2,
              ),
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _initializeLocation();
              },
              onTap: (LatLng position) async {
                setState(() {
                  _selectedLocation = position;
                  _markers.clear();
                  _markers.add(Marker(
                    markerId: MarkerId('selected'),
                    position: position,
                    infoWindow: InfoWindow(title: 'Punto Seleccionado'),
                  ));
                });
                await _searchAndShowServices(position);
              },
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}