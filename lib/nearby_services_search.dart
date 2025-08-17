import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Get API key from environment variables
final GOOGLE_API_KEY = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

class NearbyService {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? phoneNumber;

  NearbyService({required this.name, required this.address, required this.lat, required this.lng, this.phoneNumber});
}

Future<List<NearbyService>> searchNearbyServices(double lat, double lng, String serviceType, {int radius = 5000}) async {
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$serviceType&key=$GOOGLE_API_KEY'
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final results = data['results'] as List;
      // Fetch phone numbers for each place
      return Future.wait(results.map((item) async {
        final loc = item['geometry']['location'];
        String? phone;
        if (item['place_id'] != null) {
          phone = await fetchPlacePhoneNumber(item['place_id']);
        }
        return NearbyService(
          name: item['name'],
          address: item['vicinity'] ?? '',
          lat: loc['lat'],
          lng: loc['lng'],
          phoneNumber: phone,
        );
      }));
    } else {
      print('No services found: ${data['status']}');
      return [];
    }
  } else {
    print('HTTP error: ${response.statusCode}');
    return [];
  }
}

Future<String?> fetchPlacePhoneNumber(String placeId) async {
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=formatted_phone_number&key=$GOOGLE_API_KEY'
  );
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK' && data['result'] != null) {
      return data['result']['formatted_phone_number'];
    }
  }
  return null;
}