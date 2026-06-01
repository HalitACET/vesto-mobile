import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/stylist/data/models/app_notification.dart';
import 'package:mobile/features/stylist/presentation/providers/notifications_providers.dart';
import 'package:mobile/core/widgets/organisms/vesto_error_view.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Ekrana girilince tümünü okundu olarak işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsRepositoryProvider).markAllAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: AppBar(
        backgroundColor: AppColors.pearl,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            fontFamily: 'Cormorant',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onyx,
          ),
        ),
      ),
      body: notifsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.onyx),
        ),
        error: (e, _) => VestoErrorView(
          message: 'Bildirimler yüklenemedi',
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (notifs) {
          if (notifs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_outlined,
                    size: 48,
                    color: AppColors.stone,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz bildirim yok',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.stone,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: notifs.length,
            separatorBuilder: (_, _) =>
                const Divider(color: AppColors.mist, height: 1),
            itemBuilder: (context, index) =>
                _NotificationTile(notification: notifs[index]),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (notification.type) {
      'recommendation' => (Icons.auto_awesome, AppColors.onyx),
      'accepted' => (Icons.check_circle, Colors.green),
      'rejected' => (Icons.cancel, AppColors.stone),
      'follow' => (Icons.person_add, AppColors.onyx),
      _ => (Icons.notifications, AppColors.stone),
    };

    return Container(
      color: notification.isRead
          ? Colors.transparent
          : AppColors.onyx.withValues(alpha: 0.03),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          notification.title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.onyx,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            notification.body,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.stone,
            ),
          ),
        ),
        trailing: Text(
          _timeAgo(notification.createdAt),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: AppColors.stone,
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Şimdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    return '${diff.inDays} g';
  }
}
