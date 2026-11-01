import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/notifications/models/notification_model.dart';

class NotificationController extends GetxController {
  RxList<NotificationModel> notification = <NotificationModel>[].obs;
  int notificationPage = 1;
  RxBool hasMoreNotification = true.obs;
  RxBool isLoading = false.obs;
  RxInt unreadCount = 0.obs;
  RxMap<String, bool> settings = <String, bool>{}.obs;

  Future<void> fetchAllNotification(
    List<NotificationType> types, {
    bool refresh = false,
  }) async {
    if (refresh) {
      notification.clear();
      notificationPage = 1;
      hasMoreNotification.value = true;
    }
    if (!hasMoreNotification.value || isLoading.value) return;
    isLoading.value = true;
    final res = await CallServerAPI.post('notification', {
      'p': notificationPage,
      'limit': limitCount,
      'type': types.map((t) => t.apiValue).toList().join(','),
    }, withMessage: notificationPage == 1);
    if (res.isNotEmpty) {
      unreadCount.value =
          int.tryParse((res['unread_count'] ?? '0').toString()) ??
          unreadCount.value;
      if (res['list'] is List) {
        final notificationList = NotificationModel.fromList(res['list']);
        notification.addAll(notificationList);
        notification.refresh();
        hasMoreNotification.value = notificationList.length == limitCount;
        notificationPage++;
      }
    }
    isLoading.value = false;
  }

  Future<void> refreshUnreadCount() async {
    final res = await CallServerAPI.post(
      'notification/unreadCount',
      {},
      withMessage: false,
    );
    if (res.isNotEmpty) {
      unreadCount.value =
          int.tryParse((res['unread_count'] ?? '0').toString()) ?? 0;
    }
  }

  Future<void> fetchSettings() async {
    final res = await CallServerAPI.post(
      'notification/settings',
      {},
      withMessage: false,
    );
    if (res['settings'] is Map) {
      settings.value = Map<String, bool>.from(
        (res['settings'] as Map).map(
          (key, value) => MapEntry(
            key.toString(),
            value == true || value.toString() == '1',
          ),
        ),
      );
    }
  }

  Future<void> updateSetting(String type, bool enabled) async {
    settings[type] = enabled;
    settings.refresh();
    final res = await CallServerAPI.post('notification/updateSettings', {
      type: enabled ? 1 : 0,
    }, withMessage: false);
    if (res['settings'] is Map) {
      settings.value = Map<String, bool>.from(
        (res['settings'] as Map).map(
          (key, value) => MapEntry(
            key.toString(),
            value == true || value.toString() == '1',
          ),
        ),
      );
    }
  }
}
