import 'package:flutter/material.dart';

class ServiceTypeSelectionScreen extends StatelessWidget {
  final Map<String, String> serviceTypes;
  final void Function(String) onTypeSelected;

  const ServiceTypeSelectionScreen({
    Key? key,
    required this.serviceTypes,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona el tipo de servicio'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: serviceTypes.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                height: 70,
                child: ElevatedButton.icon(
                  icon: Icon(_getIconForType(entry.value), size: 32),
                  label: Text(entry.key, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => onTypeSelected(entry.value),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'fire_station':
        return Icons.local_fire_department;
      case 'police':
        return Icons.local_police;
      case 'hospital':
        return Icons.local_hospital;
      case 'local_government_office':
        return Icons.shield;
      default:
        return Icons.location_on;
    }
  }
}
