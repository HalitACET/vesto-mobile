import 'dart:async';
import 'package:mobile/features/today/data/models/weather_data.dart';
import 'package:mobile/features/today/data/services/weather_service.dart';
import 'package:mobile/features/today/presentation/providers/location_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather_provider.g.dart';

@riverpod
class CurrentWeather extends _$CurrentWeather {
  @override
  Future<WeatherData> build() async {
    final locationData = await ref.watch(currentLocationProvider.future);
    
    final service = ref.read(weatherServiceProvider);
    final weather = await service.getWeather(
      latitude: locationData.position.latitude,
      longitude: locationData.position.longitude,
    );

    // Cache logic: Invalidate after 5 minutes
    final timer = Timer(const Duration(minutes: 5), () {
      ref.invalidateSelf();
    });

    ref.onDispose(() => timer.cancel());

    return weather;
  }
}
