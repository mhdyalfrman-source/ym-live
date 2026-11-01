import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/rocket_model.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/features/rooms/rocket/rocket_tops_dialog.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'dart:async';

import 'package:tom_chat/statics_values.dart';

class GlobalRocketWidget extends StatefulWidget {
  final RoomController controller;
  final Function(int?, int?) onMoveToNewLive;
  const GlobalRocketWidget({
    super.key,
    required this.onMoveToNewLive,
    required this.controller,
  });

  @override
  State<GlobalRocketWidget> createState() => _GlobalRocketWidgetState();
}

class _GlobalRocketWidgetState extends State<GlobalRocketWidget>
    with TickerProviderStateMixin {
  late List<RoomModel> rooms;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  Timer? _autoRemoveTimer;

  static const Duration displayDuration = Duration(seconds: 5);
  bool _isShowing = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    rooms = [];
    SocketManager.instance.off('rocket');
    SocketManager.instance.on('rocket', _event);
    // Future.delayed(const Duration(seconds: 2), () {
    //   repeatAddGift(Get.find<GiftsController>().gifts.first);
    // });
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: const Offset(-1.0, 0.0), // Start from left (off-screen)
          end: Offset.zero, // End at normal position
        ).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
    // Don't start auto remove timer here, start after showing gift!
  }

  @override
  void dispose() {
    _slideController.dispose();
    _autoRemoveTimer?.cancel();
    super.dispose();
  }

  void _event(data) async {
    final room = RoomModel.fromMap(data['live']);
    RocketLevel rocket = RocketLevel.fromMap(data['rocket']);
    if (room.uid == widget.controller.room.value.uid) {
      UserModel? user;
      try {
        if (data["win"]?["top3"] != null &&
            (data["win"]?["top3"] as List).isNotEmpty) {
          user = UserModel.fromMap(data["win"]?["top3"][0]);
        }
      } catch (_) {}
      widget.controller.addRocketAnimation(rocket, user);
      widget.controller.rocket.value = room.rocket;
      Future.delayed(Duration(seconds: 5), () {
        List<UserModel> tops = [];
        List<UserModel> top3 = [];
        List<RockeRewardItemModel> rewards = [];
        if (data["win"]?["list"] is List) {
          for (var i = 0; i < data["win"]["list"].length; i++) {
            UserModel user = UserModel.fromMap(data["win"]["list"][i]);
            tops.add(user);
            if (data["win"]?["list"]?[i]["reward"] != null) {
              RockeRewardItemModel reward = RockeRewardItemModel.fromJson(
                data["win"]["list"][i]["reward"],
              );
              rewards.add(reward);
              if (user.userId == StaticValue.userData.userId &&
                  reward.rewardType == RewardType.coin) {
                StaticValue.coins.value += reward.coins;
              }
            }
          }
        }
        if (data["win"]?["top3"] is List) {
          for (var i = 0; i < data["win"]["top3"].length; i++) {
            UserModel user = UserModel.fromMap(data["win"]["top3"][i]);
            top3.add(user);
            if (user.userId == StaticValue.userData.userId) {
              StaticValue.coins.value += user.coins;
            }
          }
        }
        RocketTopsDialog.show(
          Get.context!,
          widget.controller,
          top3,
          tops,
          rewards,
        );
      });
    }
    room.rocket = rocket;
    _addRoomToTheList(room);
  }

  Future<void> _addRoomToTheList(RoomModel room) async {
    rooms.add(room);

    if (!_isShowing) {
      _playSequence();
    }
  }

  Future<void> _playSequence() async {
    if (rooms.isEmpty) {
      _isShowing = false;
      return;
    }
    if (_isPlaying) return;

    _isShowing = true;
    _isPlaying = true;

    /// SLIDE IN
    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
    if (mounted) setState(() {});

    _slideController.reset();
    await _slideController.forward();

    /// WAIT
    await Future.delayed(displayDuration);

    /// SLIDE OUT
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
    if (mounted) setState(() {});

    _slideController.reset();
    await _slideController.forward();

    /// REMOVE CURRENT
    rooms.removeAt(0);
    if (mounted) setState(() {});

    _isPlaying = false;

    /// NEXT
    _playSequence();
  }

  Widget _buildRoomCard(RoomModel room) {
    final theme = Theme.of(context);
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 20.w),
          Flexible(
            child: Text(
              "lv.${(room.rocket?.lvl ?? 0) + 1}",
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.surface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            ' ${context.l10n.bomb}',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amberAccent,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '${context.l10n.inKey} ${room.title}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.surface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 20.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const SizedBox.shrink();
    }
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: () async {
          await widget.onMoveToNewLive(rooms[0].id, rooms[0].uid);
        },
        child: Container(
          width: double.infinity,
          height: 80.h,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1000),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.5,
                  child: CachedImage(
                    rooms[0].rocket?.global ?? "",
                    fit: BoxFit.contain,
                    type: ImageType.general,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 3),
                child: _buildRoomCard(rooms[0]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
