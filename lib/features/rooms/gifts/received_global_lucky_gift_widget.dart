import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class GlobalLuckyGiftWidget extends StatefulWidget {
  final RoomController controller;
  const GlobalLuckyGiftWidget({super.key, required this.controller});

  @override
  State<GlobalLuckyGiftWidget> createState() => _GlobalLuckyGiftWidgetState();
}

class _GlobalLuckyGiftWidgetState extends State<GlobalLuckyGiftWidget>
    with TickerProviderStateMixin {
  late List<MapEntry<String, GiftModel>> _gifts;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  Timer? _autoRemoveTimer;

  static const Duration displayDuration = Duration(seconds: 5);
  bool _isShowing = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _gifts = [];
    SocketManager.instance.on('giftLuckNot', _event);
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

  _event(data) {
    // data["percent"]
    if (MyMath.toInt(data["is_global"]) == 1) {
      final gift = GiftModel.fromJson(
        data['gift'],
        sender: UserModel.fromMap(data['user']),
      ).copyWith(count: data['count'], coins: MyMath.toInt(data["coins_back"]));
      _addGiftToTheList(MapEntry(data['liveuid'].toString(), gift));
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    _autoRemoveTimer?.cancel();
    SocketManager.instance.off('giftLuckNot', _event);
    super.dispose();
  }

  // add user to the list with slide animation
  Future<void> _addGiftToTheList(MapEntry<String, GiftModel> gift) async {
    _gifts.add(gift);

    if (!_isShowing) {
      _playSequence();
    }
  }

  Future<void> _playSequence() async {
    if (_gifts.isEmpty) {
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
    _gifts.removeAt(0);
    if (mounted) setState(() {});

    _isPlaying = false;

    /// NEXT
    _playSequence();
  }

  Widget _buildGiftCard(GiftModel gift) {
    final theme = Theme.of(context);
    return Center(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 20.w),
          Text(
            gift.sender?.name ?? 'unknown',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.surface,
            ),
            maxLines: 1,
          ),
          Text(
            ' ${context.l10n.win} ${gift.coins}',
            style: theme.textTheme.labelLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent,
                )
                .apply(fontSizeDelta: -1),
          ),
          SizedBox(width: 5.w),
          Image.asset("assets/images/coin.png", height: 14.sp),
          SizedBox(width: 5.w),
          Text(
            context.l10n.on,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.surface,
            ),
            maxLines: 1,
          ),
          AppImage(image: gift.giftImage, height: 25.r, width: 25.r),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_gifts.isEmpty) {
      return const SizedBox.shrink();
    }
    return SlideTransition(
      position: _slideAnimation,
      child: GestureDetector(
        onTap: () async {
          await widget.controller.moveOnClickOnGloablGift(_gifts[0].value);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25).r,
          child: CardWidget(
            colorIndex: 1,
            radius: 20.r,
            child: Container(
              width: double.infinity,
              height: 40.h,
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
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 3),
                child: _buildGiftCard(_gifts[0].value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
