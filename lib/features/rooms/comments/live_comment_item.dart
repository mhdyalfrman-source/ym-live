import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/image/image_gallery.dart';
import 'package:tom_chat/core/utils/chat_bubble.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/badges/components/medals_widget.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';
import 'package:tom_chat/features/profile/components/levels_widget.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/comments/comment_field_widget.dart';
import 'package:tom_chat/features/rooms/comments/live_comment_actions_bottom_sheet.dart';
import 'package:tom_chat/features/rooms/controllers/room_comments_controller.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class LiveCommentItem extends StatefulWidget {
  final LiveCommentModel comment;
  final Function(UserModel)? onTap;
  final Animation<double>? animation;
  final bool isNew;
  final UserModel currentUser;
  final RoomController controller;
  final RoomModel room;
  final Function(UserModel) onBlock;
  final Function(UserModel) onSilence;
  final Function(UserModel) onMakeAdmin;
  final Function(UserModel) onRemoveAdmin;
  const LiveCommentItem({
    super.key,
    required this.comment,
    this.onTap,
    this.animation,
    this.isNew = false,
    required this.currentUser,
    required this.onBlock,
    required this.onSilence,
    required this.onMakeAdmin,
    required this.onRemoveAdmin,
    required this.controller,
    required this.room,
  });

  @override
  State<LiveCommentItem> createState() => _LiveCommentItemState();
}

class _LiveCommentItemState extends State<LiveCommentItem>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start from right
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.0, 0.7),
      ),
    );

    // Start animation if this is a new comment
    if (widget.isNew) {
      _slideController.forward().then((_) {
        // Add a subtle scale animation after slide-in
        _scaleController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _scaleController.reverse();
            }
          });
        });
      });
    } else {
      _slideController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget commentWidget = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        if (widget.comment.user != null) {
          await widget.onTap?.call(widget.comment.user!);
        }
      },
      onLongPress: () {
        LiveCommentActionsBottomSheet.show(
          context,
          comment: widget.comment,
          currentUser: widget.currentUser,
          onBlock: widget.onBlock,
          onSilence: widget.onSilence,
          onMakeAdmin: widget.onMakeAdmin,
          onRemoveAdmin: widget.onRemoveAdmin,
          controller: widget.controller,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment: widget.comment.type != MessageType.gift
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            _buildUserAvatar(),
            const SizedBox(width: 8),
            Expanded(child: _buildUserNameAndMessage(context)),
          ],
        ),
      ),
    );

    // If this is a new comment, wrap with animations
    if (widget.isNew) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: commentWidget),
        ),
      );
    }

    // For existing comments or when used with AnimatedList
    if (widget.animation != null) {
      return SlideTransition(
        position: widget.animation!.drive(
          Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutBack)),
        ),
        child: FadeTransition(opacity: widget.animation!, child: commentWidget),
      );
    }

    return commentWidget;
  }

  Widget _buildUserAvatar() {
    if (widget.comment.type == MessageType.gift ||
        widget.comment.type == MessageType.system) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(80),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(
          widget.comment.type == MessageType.gift
              ? HugeIcons.strokeRoundedGift
              : HugeIcons.strokeRoundedNotification01,
          color: Colors.white,
          size: 16,
        ),
      );
    }

    return ProfileAvatar(radius: 18.r, user: widget.comment.user!);
  }

  Widget _buildUserNameAndMessage(BuildContext context) {
    final theme = Theme.of(context);
    List<MedalModel> medals = widget.comment.user?.medals ?? [];

    return Container(
      // padding: EdgeInsets.symmetric(vertical: 3,horizontal: 7).r,
      // decoration: BoxDecoration(
      //   image: widget.comment.user?.chatBubble == null ? null : DecorationImage(
      //     fit: BoxFit.cover,
      //     image: CachedNetworkImageProvider(widget.comment.user!.chatBubble!))
      // ),
      child: Column(
        crossAxisAlignment: widget.comment.type != MessageType.gift
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        spacing: 1,
        children: [
          if (widget.comment.user != null)
            GestureDetector(
              onTap: () {
                widget.controller.openSmallProfile(widget.comment.user!);
              },
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Wrap(
                  runAlignment: WrapAlignment.start,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if ((widget.comment.user!.levels?.consumption?.progress ??
                            0) !=
                        0) ...[
                      // UserLevelBadge(gifterLevel: widget.comment.user!.gifterLevel),
                      const SizedBox(width: 4),
                    ],
                    if (widget.comment.type == MessageType.text) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MedalsWidget(
                            medals: [],
                            vip: widget.comment.user?.vip,
                            width: 18.r,
                            size: 18.r,
                          ),
                          SizedBox(width: 3.w),
                          UserNameWidget(
                            user: widget.comment.user,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          LevelsWidget(
                            size: 12.r,
                            levels: widget.comment.user?.levels?.levels ?? [],
                            vip: null,
                            width: 150.w,
                          ),
                        ],
                      ),
                      if (medals.isNotEmpty) ...[
                        SizedBox(height: 3.h),
                        MedalsWidget(
                          medals: medals,
                          vip: null,
                          width: double.infinity,
                          size: 14.r,
                        ),
                      ],
                    ] else ...[
                      UserNameWidget(
                        user: widget.comment.user!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(width: 4),
                    // TopRankBadgeWidget(rank: widget.comment.user?.rank ?? 0),
                    if (widget.comment.type == MessageType.gift) ...[
                      const SizedBox(width: 4),
                      Text(
                        "${context.l10n.send} ${widget.comment.metadata?['name'] ?? ''}",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      CachedNetworkImage(
                        imageUrl: widget.comment.metadata?['icon'] ?? '',
                        width: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "x${widget.comment.metadata?['count'] ?? ''}",
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (widget.room.owner?.userId !=
                          widget.comment.metadata?["to"]?["uid"]) ...[
                        SizedBox(width: 4),
                        Text(
                          "${context.l10n.to} ${widget.comment.metadata?["to"]?["name"] ?? ''}",
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: Colors.white.withAlpha(200),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                    // if(widget.controller.admins.containsKey(widget.comment.user?.id) && widget.controller.admins[widget.comment.user?.id] == Role.admin)...[
                    //   SizedBox(width: 3.w,),
                    //   Image.asset("assets/icons/live/admin.png",width: 15.r,height: 15.r, color: Colors.white.withAlpha(200))
                    // ]
                  ],
                ),
              ),
            ),
          if (![
            MessageType.gift,
            MessageType.gift,
            MessageType.image,
          ].contains(widget.comment.type))
            IgnorePointer(
              ignoring: widget.comment.type == MessageType.system,
              child: GestureDetector(
                onTap: () {
                  CommentFieldWidget.showChatInput(
                    context,
                    user: widget.comment.user!,
                    textController: TextEditingController(),
                    sendMessage: (message) {
                      widget.controller.sendComment(message);
                    },
                    replyMessage: widget.comment.message,
                    mentionUserName: widget.comment.user?.username,
                  );
                },
                child: ChatBubblePro(
                  bubbleUrl:
                      widget.comment.user?.chatBubble ??
                      widget.comment.user?.vip?.bubble,
                  text: widget.comment.message!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  child: Text(
                    widget.comment.message ?? "",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          if (widget.comment.type == MessageType.sticker)
            CachedNetworkImage(
              imageUrl: widget.comment.metadata?['gift']?['icon'] ?? '',
              width: 100,
            ),
          if (widget.comment.type == MessageType.image)
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) =>
                      ImagePreview(images: [widget.comment.message!]),
                );
              },
              child: CachedNetworkImage(
                imageUrl: (widget.comment.message!),
                width: 100,
              ),
            ),
        ],
      ),
    );
  }
}
