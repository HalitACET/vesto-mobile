import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/today/data/models/weather_data.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData weather;
  final String locationName;

  const WeatherCard({
    super.key,
    required this.weather,
    this.locationName = 'KONUMUN',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.mist.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.onyx.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locationName.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: AppColors.stone,
                ),
              ),
              _ConditionIcon(condition: weather.condition),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.round()}°',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onyx,
                  height: 1,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hissedilen ${weather.feelsLike.round()}°',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.stone,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weather.condition.description} · Min ${weather.tempMin.round()}° / Max ${weather.tempMax.round()}°',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.stone,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.mist, height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _WeatherDetailItem(
                icon: Icons.air,
                value: '${weather.windSpeedKmh.round()} km/h',
              ),
              _WeatherDetailItem(
                icon: Icons.water_drop_outlined,
                value: '%${weather.humidityPercent}',
              ),
              _WeatherDetailItem(
                icon: Icons.wb_sunny_outlined,
                value: 'UV ${weather.uvIndex}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String value;

  const _WeatherDetailItem({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.stone),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.stone,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ConditionIcon extends StatelessWidget {
  final WeatherCondition condition;

  const _ConditionIcon({required this.condition});

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color color;

    switch (condition) {
      case WeatherCondition.clearSky:
      case WeatherCondition.mainlyClear:
        iconData = Icons.wb_sunny;
        color = Colors.amber;
        break;
      case WeatherCondition.partlyCloudy:
        iconData = Icons.wb_cloudy_outlined;
        color = Colors.blueGrey;
        break;
      case WeatherCondition.cloudy:
        iconData = Icons.cloud;
        color = Colors.grey;
        break;
      case WeatherCondition.fog:
        iconData = Icons.cloud_queue;
        color = AppColors.mist;
        break;
      case WeatherCondition.drizzle:
      case WeatherCondition.rain:
      case WeatherCondition.heavyRain:
        iconData = Icons.umbrella_outlined;
        color = Colors.blue;
        break;
      case WeatherCondition.snow:
        iconData = Icons.ac_unit;
        color = Colors.lightBlueAccent;
        break;
      case WeatherCondition.thunderstorm:
        iconData = Icons.thunderstorm_outlined;
        color = Colors.deepPurple;
        break;
      case WeatherCondition.unknown:
        iconData = Icons.help_outline;
        color = AppColors.mist;
        break;
    }

    return Icon(iconData, color: color, size: 28);
  }
}
