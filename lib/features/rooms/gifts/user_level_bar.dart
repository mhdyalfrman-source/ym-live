import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class UserLevelBar extends StatelessWidget {
  final bool inCombo;
  final RoomController controller;
  final int selectedGiftIndex;
  const UserLevelBar({
    super.key,
    this.inCombo = false,
    required this.controller,
    required this.selectedGiftIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        color: Colors.black,
      ),
      child: SizedBox(
        height: 50,
        child: _buildAvailableUsersForSendGift(theme),
      ),
    );
  }

  Widget _buildAvailableUsersForSendGift(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                colors: [Colors.white, theme.colorScheme.onSurface],
                stops: [0.9, 1],
              ).createShader(rect);
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Obx(
                () => Row(
                  spacing: 8,
                  children: [
                    // const SizedBox(width: 12),
                    ...List.generate(
                      controller.seats.length,
                      (index) => _buildUserAvatar(
                        controller.seatsUsers[index],
                        theme,
                        controller.selectedGuestUsers.contains(
                          controller.seatsUsers[index].userId,
                        ),
                        controller.seats[index].seatNumber,
                      ),
                    ),
                    ...List.generate(
                      controller.selectedCommentUsers.length,
                      (index) => _buildUserAvatar(
                        controller.selectedCommentUsers[index],
                        theme,
                        controller.selectedGuestUsers.contains(
                          controller.selectedCommentUsers[index].userId,
                        ),
                        null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Obx(() {
          bool isAllSelected =
              controller.selectedGuestUsers.length ==
              controller.seats.length + controller.selectedCommentUsers.length;
          return GestureDetector(
            onTap: () {
              if (isAllSelected) {
                controller.clearSelectedGuestUsers();
              } else {
                controller.selectAllGuestUsers(
                  controller.seatsUsers + controller.selectedCommentUsers,
                );
              }
            },
            child: AnimatedContainer(
              width: 30,
              height: 30,
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: isAllSelected
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isAllSelected
                    ? null
                    : theme.colorScheme.surface.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isAllSelected
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.colorScheme.surface.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isAllSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedScale(
                scale: isAllSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  Get.context!.l10n.all,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isAllSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                // child: Icon(
                //   HugeIcons.strokeRoundedMic01,
                //   color: widget.giftsController.selectedGuestUsers.length ==
                //           widget.controller.seats.length
                //       ? theme.colorScheme.onPrimary
                //       : theme.colorScheme.onSurface.withOpacity(0.7),
                //   size: 16,
                // ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildUserAvatar(
    UserModel user,
    ThemeData theme,
    bool isSelected,
    int? seatNumber,
  ) {
    return GestureDetector(
      onTap: () {
        if (isSelected) {
          controller.removeSelectedGuestUser(user.userId);
        } else {
          controller.addSelectedGuestUser(user.userId);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey,
                child: ProfileAvatar(user: user, radius: 25),
              ),
              const SizedBox(height: 4),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: user.userId == controller.room.value.owner?.userId
                    ? 3
                    : 6,
              ),
              decoration: BoxDecoration(
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: user.userId == controller.room.value.owner?.userId
                  ? Icon(
                      HugeIcons.strokeRoundedHome06,
                      color: Colors.white,
                      size: 14.r,
                    )
                  : Text(
                      '${seatNumber ?? ""}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
