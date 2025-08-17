import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Function to request location permission
Future<bool> requestLocationPermission() async {
  var status = await Permission.location.request();
  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    // Show a dialog or snackbar explaining why location is needed
    return false;
  } else if (status.isPermanentlyDenied) {
    // Open app settings
    await openAppSettings();
    return false;
  }
  return false;
}

// Function to get current location
Future<Position?> getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Services disabled, show message
    return null;
  }
  if (await requestLocationPermission()) {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      // Handle error
      return null;
    }
  }
  return null;
}