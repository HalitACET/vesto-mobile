import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_provider.g.dart';

@riverpod
Future<({Position position, String city})> currentLocation(Ref ref) async {
  try {
    final position = await Future.any([
      _getCurrentLocation(),
      Future.delayed(const Duration(seconds: 10), () => throw TimeoutException('Konum alma zaman aşımına uğradı')),
    ]);

    // Reverse geocode to get city name
    String city = 'KONUMUN';
    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10'),
        headers: {'User-Agent': 'VestoApp/1.0'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        city = data['address']?['province'] ?? data['address']?['city'] ?? data['address']?['town'] ?? 'KONUMUN';
        debugPrint('DEBUG: City found: $city');
      }
    } catch (e) {
      debugPrint('DEBUG: Geocoding error: $e');
    }

    return (position: position, city: city.toUpperCase());
  } catch (e) {
    debugPrint('DEBUG: Location error: $e');
    return (position: _fallbackPosition(), city: 'BURSA');
  }
}

Future<Position> _getCurrentLocation() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return _fallbackPosition();

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return _fallbackPosition();
  }

  if (permission == LocationPermission.deniedForever) return _fallbackPosition();

  return await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 7),
    ),
  );
}

Position _fallbackPosition() {
  // Fallback: Bursa (Halit'in şehri, demo için anlamlı)
  return Position(
    latitude: 40.1828,
    longitude: 29.0665,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    heading: 0,
    speed: 0,
    speedAccuracy: 0,
    altitudeAccuracy: 0,
    headingAccuracy: 0,
  );
}
