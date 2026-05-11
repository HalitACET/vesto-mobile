import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/features/today/data/models/weather_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'weather_service.g.dart';

class WeatherService {
  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse('$_baseUrl?'
        'latitude=$latitude&'
        'longitude=$longitude&'
        'current=temperature_2m,apparent_temperature,weather_code,precipitation,wind_speed_10m,relative_humidity_2m,uv_index&'
        'daily=temperature_2m_max,temperature_2m_min&'
        'timezone=auto&'
        'forecast_days=1');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Hava bilgisi alınamadı (Kod: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);
      return WeatherData.fromOpenMeteoJson(data);
    } catch (e) {
      throw Exception('Bağlantı hatası: $e');
    }
  }
}

@riverpod
WeatherService weatherService(Ref ref) {
  return WeatherService();
}
