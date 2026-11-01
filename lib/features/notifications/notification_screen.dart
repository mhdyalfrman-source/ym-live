import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/notifications/controllers/notification_controller.dart';
import 'package:tom_chat/features/notifications/models/notification_model.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';

class NotificationScreen extends StatefulWidget {
  final String title;
  final List<NotificationType> types;
  const NotificationScreen({
    super.key,
    required this.title,
    this.types = const [
      NotificationType.liveStarted,
      NotificationType.newFollower,
      NotificationType.postInteraction,
      NotificationType.storeItemOrVip,
      NotificationType.privateMessage,
    ],
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller;
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllNotification(widget.types, refresh: true);
    });
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent <=
          scrollController.offset + 80) {
        controller.fetchAllNotification(widget.types);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: widget.title,
      child: Obx(() {
        if (controller.notification.isEmpty && controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notification.isEmpty) {
          return Center(
            child: Text(
              context.l10n.therAreNoNotificationsYet,
              style: Theme.of(
                context,
              ).textTheme.displaySmall!.copyWith(color: Colors.black),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () =>
              controller.fetchAllNotification(widget.types, refresh: true),
          child: ListView.separated(
            controller: scrollController,
            padding: EdgeInsets.all(10).r,
            itemCount:
                controller.notification.length +
                (controller.hasMoreNotification.value ? 1 : 0),
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              if (index >= controller.notification.length) {
                return const Center(child: CircularProgressIndicator());
              }
              final item = controller.notification[index];
              return ListTile(
                tileColor: item.isRead ? Colors.white : const Color(0xfffff6ed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10).r,
                ),
                leading: item.user != null
                    ? ProfileAvatar(user: item.user!, radius: 22.r)
                    : Icon(
                        Icons.notifications_outlined,
                        size: 28.r,
                        color: Theme.of(context).primaryColor,
                      ),
                title: Text(
                  item.displayTitle(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.black,
                    fontWeight: item.isRead ? FontWeight.w500 : FontWeight.bold,
                  ),
                ),
                subtitle: item.title.isEmpty
                    ? null
                    : Text(
                        item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium!
                            .copyWith(color: Colors.black54),
                      ),
                trailing: item.isRead
                    ? null
                    : Container(
                        width: 9.r,
                        height: 9.r,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
              );
            },
          ),
        );
      }),
    );
  }
}
