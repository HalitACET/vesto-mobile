import 'package:flutter/material.dart';
import 'package:mobile/app/theme/app_colors.dart';

class VestoErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const VestoErrorView({
    this.message,
    this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_outlined,
              size: 48,
              color: AppColors.stone,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Bir şeyler ters gitti',
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                color: AppColors.onyx,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'İnternet bağlantınızı kontrol edin\nve tekrar deneyin',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.stone,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onyx,
                  side: const BorderSide(color: AppColors.onyx),
                ),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
