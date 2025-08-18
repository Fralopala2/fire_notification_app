import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sos_incendio/screens/fire_map_screen.dart';
import 'package:sos_incendio/screens/service_type_selection_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOSIncendio',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FireMapScreen(selectedServiceType: 'fire_station'),
    );
  }
}

class ServiceTypeSelectionEntry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ServiceTypeSelectionScreen(
      serviceTypes: {
        'Bomberos': 'fire_station',
        'Policía': 'police',
        'Hospital': 'hospital',
        'Protección Civil': 'local_government_office',
      },
      onTypeSelected: (type) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FireMapScreen(selectedServiceType: type),
          ),
        );
      },
    );
  }
}