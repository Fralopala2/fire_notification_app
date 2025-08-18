import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Requests location permission from the user
Future<bool> requestLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
  // Show a dialog or snackbar explaining why location access is required
    return false;
  } else if (status.isPermanentlyDenied) {
  // Open app settings for permissions
    await openAppSettings();
    return false;
  }
  return false;
}

// Gets the current location of the user
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
  // Location services are disabled, show a message
    return null;
  }
  if (await requestLocationPermission()) {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
  // Handle location error
      return null;
    }
  }
  return null;
}