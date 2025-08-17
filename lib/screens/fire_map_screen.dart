import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../nearby_services_search.dart';
import 'package:url_launcher/url_launcher.dart';

class FireMapScreen extends StatefulWidget {
  const FireMapScreen({super.key}); // Simplified constructor
  @override
  _FireMapScreenState createState() => _FireMapScreenState();
}

class _FireMapScreenState extends State<FireMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};
  Position? _currentPosition;
  List<NearbyService> _nearbyServices = [];
  bool _loadingServices = false;
  String _selectedServiceType = 'fire_station';
  double _searchRadius = 10000; // Default radius in meters
  final Map<String, String> _serviceTypes = {
    'Bomberos': 'fire_station',
    'Policia': 'police',
    'Hospital': 'hospital',
    'Protección Civil': 'local_government_office',
  };

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  void _initializeLocation() async {
    _currentPosition = await getCurrentLocation();
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  Future<void> _searchAndShowServices(LatLng position) async {
    setState(() {
      _loadingServices = true;
      _nearbyServices = [];
    });
  final type = _selectedServiceType;
  final services = await searchNearbyServices(position.latitude, position.longitude, type, radius: _searchRadius.toInt());
    setState(() {
      _nearbyServices = services;
      _loadingServices = false;
    });
    if (services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No nearby services found.')),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) => ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            final distanceKm = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              service.lat,
              service.lng,
            ) / 1000;
            return ListTile(
              title: Text(service.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.address),
                  if (service.phoneNumber != null)
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri(scheme: 'tel', path: service.phoneNumber);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      child: Text(
                        'Tel: ${service.phoneNumber}',
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                ],
              ),
              trailing: Text('${distanceKm.toStringAsFixed(1)} km'),
            );
          },
        ),
      );
    }
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
                Row(
                  children: [
                    Text('Service type: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedServiceType,
                        items: _serviceTypes.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.value,
                            child: Text(entry.key),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedServiceType = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
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
              initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 2),
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