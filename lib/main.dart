import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sos_reports/screens/fire_map_screen.dart';
import 'package:sos_reports/screens/service_type_selection_screen.dart';
import 'package:sos_reports/banner_ad_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Reports',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: FireMapScreen(selectedServiceType: 'fire_station'),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
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