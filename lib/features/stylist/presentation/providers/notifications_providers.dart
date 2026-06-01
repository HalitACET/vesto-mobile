import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/stylist/data/models/app_notification.dart';
import 'package:mobile/features/stylist/data/repositories/notifications_repository.dart';

part 'notifications_providers.g.dart';

@riverpod
NotificationsRepository notificationsRepository(Ref ref) {
  return NotificationsRepository(firestore: ref.watch(firestoreProvider));
}

@riverpod
Stream<List<AppNotification>> notifications(Ref ref) {
  return ref.read(notificationsRepositoryProvider).watchNotifications();
}

@riverpod
int unreadNotificationCount(Ref ref) {
  final notifs = ref.watch(notificationsProvider).value ?? [];
  return notifs.where((n) => !n.isRead).length;
}
