import 'package:flutter/material.dart';
import '../nearby_services_search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceResultsScreen extends StatelessWidget {
  final List<NearbyService> services;
  final double selectedLat;
  final double selectedLng;
  final String serviceTypeName;

  const ServiceResultsScreen({
    Key? key,
    required this.services,
    required this.selectedLat,
    required this.selectedLng,
    required this.serviceTypeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados: $serviceTypeName'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: services.isEmpty
          ? Center(child: Text('No se encontraron servicios cercanos.', style: TextStyle(fontSize: 20, color: Colors.grey[700])))
          : ListView.builder(
              itemCount: services.length,
              itemBuilder: (context, index) {
                final service = services[index];
                final distanceKm = Geolocator.distanceBetween(
                  selectedLat,
                  selectedLng,
                  service.lat,
                  service.lng,
                ) / 1000;
                final mapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=${service.lat},${service.lng}';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  elevation: 8,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(service.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red, size: 28),
                            const SizedBox(width: 8),
                            Expanded(child: Text(service.address, style: const TextStyle(fontSize: 18, color: Colors.black87))),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.directions, size: 38),
                                label: const Text('Ruta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 4,
                                ),
                                onPressed: () async {
                                  final uri = Uri.parse(mapsUrl);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 24),
                            if (service.phoneNumber != null)
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.phone, size: 38),
                                  label: const Text('Llamar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 4,
                                  ),
                                  onPressed: () async {
                                    final uri = Uri(scheme: 'tel', path: service.phoneNumber);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Icon(Icons.social_distance, color: Colors.deepOrange, size: 24),
                            const SizedBox(width: 8),
                            Text('Distancia: ${distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 20, color: Colors.black87)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
