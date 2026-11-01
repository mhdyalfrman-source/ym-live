import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/notifications/controllers/notification_controller.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => controller.fetchSettings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<_NotificationSettingItem> items = [
      _NotificationSettingItem('live_started', context.l10n.live_started),
      _NotificationSettingItem('new_follower', context.l10n.new_follower),
      _NotificationSettingItem(
        'post_interaction',
        context.l10n.post_interaction,
      ),
      _NotificationSettingItem(
        'store_item_or_vip',
        context.l10n.store_item_or_vip,
      ),
      _NotificationSettingItem('private_message', context.l10n.private_message),
    ];
    return PageTemplete(
      title: context.l10n.notificationSettings,
      child: Obx(
        () => ListView(
          padding: EdgeInsets.all(10).r,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 8).r,
              child: Text(
                context.l10n.notificationSettingsDesc,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium!.copyWith(color: Colors.black54),
              ),
            ),
            ...items.map((item) {
              final enabled = controller.settings[item.type] ?? true;
              return Card(
                color: Colors.white,
                margin: EdgeInsets.symmetric(vertical: 4).r,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10).r,
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ).r,
                  title: Text(
                    item.title,
                    style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: enabled,
                  onChanged: (value) =>
                      controller.updateSetting(item.type, value),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _NotificationSettingItem {
  final String type;
  final String title;
  const _NotificationSettingItem(this.type, this.title);
}
