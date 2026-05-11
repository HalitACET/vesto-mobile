
enum WeatherCondition {
  clearSky,
  mainlyClear,
  partlyCloudy,
  cloudy,
  fog,
  drizzle,
  rain,
  heavyRain,
  snow,
  thunderstorm,
  unknown;

  String get description {
    switch (this) {
      case WeatherCondition.clearSky: return 'Açık Gökyüzü';
      case WeatherCondition.mainlyClear: return 'Çoğunlukla Açık';
      case WeatherCondition.partlyCloudy: return 'Parçalı Bulutlu';
      case WeatherCondition.cloudy: return 'Bulutlu';
      case WeatherCondition.fog: return 'Sisli';
      case WeatherCondition.drizzle: return 'Çiseleme';
      case WeatherCondition.rain: return 'Yağmurlu';
      case WeatherCondition.heavyRain: return 'Şiddetli Yağmur';
      case WeatherCondition.snow: return 'Karlı';
      case WeatherCondition.thunderstorm: return 'Fırtınalı';
      case WeatherCondition.unknown: return 'Bilinmiyor';
    }
  }
}

class WeatherData {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final WeatherCondition condition;
  final double precipitationMm;
  final double windSpeedKmh;
  final int humidityPercent;
  final int uvIndex;
  final DateTime fetchedAt;

  WeatherData({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.precipitationMm,
    required this.windSpeedKmh,
    required this.humidityPercent,
    required this.uvIndex,
    required this.fetchedAt,
  });

  factory WeatherData.fromOpenMeteoJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;
    final weatherCode = current['weather_code'] as int;

    return WeatherData(
      temperature: (current['temperature_2m'] as num).toDouble(),
      feelsLike: (current['apparent_temperature'] as num).toDouble(),
      tempMin: (daily['temperature_2m_min'][0] as num).toDouble(),
      tempMax: (daily['temperature_2m_max'][0] as num).toDouble(),
      condition: _mapWmoCodeToCondition(weatherCode),
      precipitationMm: (current['precipitation'] as num).toDouble(),
      windSpeedKmh: (current['wind_speed_10m'] as num).toDouble(),
      humidityPercent: current['relative_humidity_2m'] as int,
      uvIndex: (current['uv_index'] as num).toInt(),
      fetchedAt: DateTime.now(),
    );
  }

  static WeatherCondition _mapWmoCodeToCondition(int code) {
    if (code == 0) return WeatherCondition.clearSky;
    if (code >= 1 && code <= 3) return WeatherCondition.partlyCloudy;
    if (code == 45 || code == 48) return WeatherCondition.fog;
    if (code >= 51 && code <= 57) return WeatherCondition.drizzle;
    if (code >= 61 && code <= 67) return WeatherCondition.rain;
    if (code >= 71 && code <= 77) return WeatherCondition.snow;
    if (code >= 80 && code <= 82) return WeatherCondition.rain;
    if (code >= 85 && code <= 86) return WeatherCondition.snow;
    if (code >= 95 && code <= 99) return WeatherCondition.thunderstorm;
    return WeatherCondition.unknown;
  }
}
