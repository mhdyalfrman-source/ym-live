import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/features/chat/chat_screen.dart';
import 'package:tom_chat/features/entry/entry_screen.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/chat/models/room_chat_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class FollowButton extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final UserModel user;
  final PersonRelation relation;
  final double radius;
  final Icon? icon;
  final TextStyle? textStyle;
  final bool showFriendsButton;
  final Function(PersonRelation?) callBack;
  final EdgeInsets padding;
  const FollowButton({
    super.key,
    this.width,
    this.height,
    this.color,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.radius = 10,
    this.showFriendsButton = false,
    required this.user,
    required this.relation,
    required this.callBack,
    this.icon,
    this.textStyle,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool isLoading = false;
  Color? color;
  Color? textColor;

  // void updateFollowCountInProfile(int plusFollowers, int plusFollowing) {
  //   int? personId = AppManager.instance.user?.id;
  //   if (Get.isRegistered<ProfileController>(tag: "$personId")) {
  //     ProfileController controller = Get.find(tag: "$personId");
  //     controller.person.update((val) {
  //       val?.followers_count += plusFollowers;
  //       val?.following_count += plusFollowing;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.user.userId == StaticValue.userData.userId) {
      return SizedBox();
    }
    color =
        widget.color ??
        ([
              PersonRelation.follow,
              PersonRelation.followBack,
            ].contains(widget.relation)
            ? AppColors.primaryDark
            : AppColors.gray50);
    textColor =
        widget.textColor ??
        ([
              PersonRelation.follow,
              PersonRelation.followBack,
            ].contains(widget.relation)
            ? Colors.white
            : Colors.black);
    TextStyle style =
        widget.textStyle ??
        Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        );

    final text =
        widget.relation == PersonRelation.friends && !widget.showFriendsButton
        ? context.l10n.message
        : widget.relation.getLabel(context);

    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final textHeight = textPainter.height;
    return GestureDetector(
      onTap: () async {
        if (StaticValue.userData.userId == 0) {
          Get.to(() => EntryScreen());
          return;
        } else if (widget.relation == PersonRelation.friends &&
            !widget.showFriendsButton) {
          HomeController controller = Get.find();

          int index = controller.roomChats.indexWhere(
            (m) => m.user?.userId == widget.user.userId,
          );

          if (index >= 0) {
            controller.selectedRoom.value = index;
          } else {
            controller.roomChats.insert(
              0,
              RoomChatModel(
                chats: [],
                id: widget.user.userId,
                lastMessage: null,
                lastMessageDate: null,
                unreadMessage: 0,
                user: widget.user,
              ),
            );
            controller.selectedRoom.value = 0;
          }
          Get.to(
            () => ChatScreen(
              withAllChats: false,
              withHeader: true,
              withNotification: false,
            ),
          );
        } else if ([
          PersonRelation.block,
          PersonRelation.blockBy,
          PersonRelation.iBlock,
        ].contains(widget.relation)) {
          if (widget.relation == PersonRelation.iBlock) {
            if (isLoading) return;
            setState(() {
              isLoading = true;
            });
            var response = await CallServerAPI.post('user/attention', {
              'touid': widget.user.userId,
              'type': 2,
            });
            if (response.isNotEmpty) {
              widget.callBack(PersonRelation.follow);
            }
            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          }
        } else {
          if (isLoading) return;
          setState(() {
            isLoading = true;
          });
          var response = await CallServerAPI.post('user/attention', {
            'touid': widget.user.userId,
            'type': 1,
          });
          if (response.isNotEmpty) {
            PersonRelation newState = PersonRelation.values.firstWhere(
              (v) => v.name == response['button'],
            );

            // if ([PersonRelation.follow, PersonRelation.followBack]
            //     .contains(newState)) {
            //   FcmTopicManager.unsubscribe(
            //       "follow_${AppManager.instance.getLanguage}_${widget.user.id}");
            // } else if ([PersonRelation.following, PersonRelation.friends]
            //     .contains(newState)) {
            //   FcmTopicManager.subscribe(
            //       "follow_${AppManager.instance.getLanguage}_${widget.user.id}");
            // }

            widget.callBack(newState);
          } else {
            widget.callBack(null);
          }
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        }
      },
      child: Container(
        margin: const EdgeInsets.all(5).r,
        padding: widget.padding.r,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: textHeight,
                  height: textHeight,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    if (widget.width != null) ...[
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            text, // 🔹 localized
                            style: style,
                          ),
                        ),
                      ),
                    ] else ...[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(text, style: style),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
