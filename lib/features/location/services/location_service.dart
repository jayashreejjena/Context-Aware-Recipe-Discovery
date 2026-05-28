import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../models/location_cuisine_context.dart';
import '../utils/cuisine_area_mapper.dart';

class LocationService {
  const LocationService();

  Future<LocationCuisineContext> getCuisineContext() async {
    final permission = await _ensurePermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission is needed for nearby cuisine suggestions.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 10),
      ),
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final placemark = placemarks.isEmpty ? null : placemarks.first;
    final country = placemark?.country?.trim();
    final countryCode = placemark?.isoCountryCode?.trim();
    final cuisineArea = CuisineAreaMapper.fromCountry(
      countryCode: countryCode,
      country: country,
    );

    return LocationCuisineContext(
      country: country?.isNotEmpty == true ? country! : 'your area',
      countryCode: countryCode,
      cuisineArea: cuisineArea,
    );
  }

  Future<LocationPermission> _ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceException(
        'Turn on location services to get cuisine suggestions.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
