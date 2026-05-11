import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/today/presentation/providers/suggestions_provider.dart';
import 'package:mobile/features/today/presentation/providers/weather_provider.dart';
import 'package:mobile/features/today/presentation/providers/location_provider.dart';
import 'package:mobile/features/today/presentation/widgets/weather_card.dart';
import 'package:mobile/features/today/presentation/widgets/weather_advice_chip.dart';
import 'package:mobile/features/today/presentation/widgets/suggestion_carousel.dart';
import 'package:mobile/features/today/presentation/widgets/today_skeleton.dart';
import 'package:mobile/features/today/data/models/weather_data.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(currentWeatherProvider);
    final suggestionsAsync = ref.watch(outfitSuggestionsProvider);

    return Scaffold(
      backgroundColor: AppColors.pearl,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentWeatherProvider);
          ref.invalidate(outfitSuggestionsProvider);
          await ref.read(currentWeatherProvider.future);
          await ref.read(outfitSuggestionsProvider.future);
        },
        color: AppColors.onyx,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.pearl,
              elevation: 0,
              title: Text(
                'Bugün',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onyx,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 10),
                  _buildGreeting(ref),
                  const SizedBox(height: 24),
                  weatherAsync.when(
                    data: (weather) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WeatherCard(
                            weather: weather,
                            locationName: ref.watch(currentLocationProvider).value?.city ?? 'KONUMUN',
                          ),
                          const SizedBox(height: 16),
                          _buildAdviceChips(weather),
                        ],
                      );
                    },
                    loading: () => const TodaySkeleton(),
                    error: (err, stack) => _buildErrorState(ref),
                  ),
                  const SizedBox(height: 32),
                  if (weatherAsync.hasValue) ...[
                    Text(
                      'BUGÜN İÇİN ÖNERİLER',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.stone,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ]),
              ),
            ),
            if (weatherAsync.hasValue)
              SliverToBoxAdapter(
                child: suggestionsAsync.when(
                  data: (suggestions) => suggestions.isEmpty 
                    ? _buildEmptyWardrobeState(context)
                    : SuggestionCarousel(suggestions: suggestions),
                  loading: () => const SizedBox.shrink(), // Skeleton handles this
                  error: (err, stack) => _buildErrorState(ref),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting(WidgetRef ref) {
    final hour = DateTime.now().hour;
    final displayName = ref.watch(currentUserProvider).value?.displayName ?? '';
    final firstName = displayName.split(' ').first;
    
    String greeting;
    if (hour < 12) {
      greeting = 'Günaydın';
    } else if (hour < 18) {
      greeting = 'İyi günler';
    } else {
      greeting = 'İyi akşamlar';
    }

    return Text(
      firstName.isNotEmpty ? '$greeting, $firstName' : greeting,
      style: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: AppColors.onyx,
      ),
    );
  }

  Widget _buildEmptyWardrobeState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(Icons.checkroom_outlined, color: AppColors.mist, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Gardırobun Henüz Boş',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sana özel öneriler yapabilmem için önce birkaç parça kıyafet eklemelisin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.stone, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/wardrobe'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onyx,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('GARDIROBUMA GİT'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.stone),
            const SizedBox(height: 16),
            const Text(
              'Bir hata oluştu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                ref.invalidate(currentWeatherProvider);
                ref.invalidate(outfitSuggestionsProvider);
              },
              child: const Text('TEKRAR DENE', style: TextStyle(color: AppColors.onyx)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceChips(WeatherData weather) {
    final chips = <Widget>[];

    // Rain advice
    if (weather.precipitationMm > 0.5) {
      chips.add(const WeatherAdviceChip(label: 'Şemsiye al ☂️', icon: Icons.umbrella_outlined));
    }

    // UV advice
    if (weather.uvIndex > 7) {
      chips.add(const WeatherAdviceChip(label: 'Güneşten korun ☀️', icon: Icons.wb_sunny_outlined));
    }

    // Wind advice
    if (weather.windSpeedKmh > 30) {
      chips.add(const WeatherAdviceChip(label: 'Rüzgarlı, mont seç 🌬️', icon: Icons.air));
    }

    // Cold advice
    if (weather.temperature < 5) {
      chips.add(const WeatherAdviceChip(label: 'Soğuk, kalın giyin 🥶', icon: Icons.ac_unit));
    }

    // Hot advice
    if (weather.temperature > 30) {
      chips.add(const WeatherAdviceChip(label: 'Sıcak, hafif giyin 🌡️', icon: Icons.wb_sunny));
    }

    // Layered clothing advice
    if (weather.tempMax - weather.tempMin > 15) {
      chips.add(const WeatherAdviceChip(label: 'Katmanlı giyin 👕👔', icon: Icons.layers_outlined));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: chip,
        )).toList(),
      ),
    );
  }
}
