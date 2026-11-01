import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/controllers/general_controller.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/room_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'dart:async';

class AllAppGifts extends StatefulWidget {
  const AllAppGifts({super.key});

  @override
  State<AllAppGifts> createState() => _AllAppGiftsState();
}

class _AllAppGiftsState extends State<AllAppGifts>
    with SingleTickerProviderStateMixin {
  HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showAppGifts.value) return const SizedBox.shrink();
      return IgnorePointer(
        ignoring: true,
        child: SafeArea(
          child: Column(
            children: [Spacer(), AllAppGiftListener(), Spacer(flex: 9)],
          ),
        ),
      );
    });
  }
}

class AllAppGiftListener extends StatefulWidget {
  const AllAppGiftListener({super.key});

  @override
  State<AllAppGiftListener> createState() => _AllAppGiftListenerState();
}

class _AllAppGiftListenerState extends State<AllAppGiftListener>
    with TickerProviderStateMixin {
  final List<GiftModel> _queue = [];
  GiftModel? _currentGift;

  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isShowing = false;
  bool _isHiding = false;

  bool _disposed = false;
  Timer? _stayTimer;

  void Function(dynamic)? _socketHandler;

  static const Duration stayDuration = Duration(seconds: 6);

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _socketHandler = (data) {
      if (_disposed) return;
      if (data is List) {
        for (var item in data) {
          final gift = _convertToGiftModel(item);
          if (gift.globalNotifyLvl > 0) {
            _queue.add(gift);
          }
        }
        _tryShowNext();
      }
    };

    SocketManager.instance.on("globalAnimation", _socketHandler!);
  }

  @override
  void dispose() {
    _disposed = true;
    try {
      if (_socketHandler != null) {
        SocketManager.instance.off("globalAnimation", _socketHandler);
      }
    } catch (_) {}
    _stayTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  GiftModel _convertToGiftModel(Map data) {
    final sender = UserModel(
      userId: MyMath.toInt(data["uid"]),
      pos: UserPosition.user,
      name: data["uName"] ?? "",
      avatar: data["uAvatar"] != null
          ? ImageModel.fromMap(data["uAvatar"])
          : null,
    );

    final receiver = UserModel(
      userId: MyMath.toInt(data["touid"]),
      pos: UserPosition.user,
      name: data["toName"] ?? "",
      avatar: data["toAvatar"] != null
          ? ImageModel.fromMap(data["toAvatar"])
          : null,
    );

    final map = {
      "send_id": "${data["uid"]}-${data["touid"]}-${DateTime.now()}",
      "id": data["gid"],
      "name": data["name"] ?? "",
      "count": data["count"] ?? 1,
      "icon": data["img"],
      "coins": data["coin_number"] ?? 0,
      "anim": data["anim"],
      "type": 0,
      "mark": 0,
      "isAllNotify": data["is_all_notify"],
      "isCp": 0,
      "rid": data["rid"],
      "room_level": data["room_level"],
      "roomImg": data["roomImg"],
      "uAvatar": data["uAvatar"],
      "liveuid": data["liveuid"],
      "global_notify_lvl": data["global_notify_lvl"],
    };

    return GiftModel.fromJson(map, sender: sender, to: receiver);
  }

  // ---------------------------
  //       QUEUE CONTROL
  // ---------------------------
  void _tryShowNext() {
    if (_isShowing || _isHiding) return;
    if (_queue.isEmpty) return;
    _showGift(_queue.first);
  }

  Future<void> _showGift(GiftModel gift) async {
    _currentGift = gift;
    _isShowing = true;

    if (mounted) setState(() {});

    _animController.reset();
    await _animController.forward();

    _stayTimer?.cancel();
    _stayTimer = Timer(stayDuration, () => _hideCurrent());
  }

  Future<void> _hideCurrent() async {
    if (_isHiding || !_isShowing) return;
    if (_currentGift == null) return;

    _isHiding = true;

    await _animController.reverse();

    if (mounted) {
      setState(() {
        if (_queue.isNotEmpty) _queue.removeAt(0);
        _currentGift = null;
      });
    }

    _isShowing = false;
    _isHiding = false;

    Future.delayed(const Duration(milliseconds: 120), _tryShowNext);
  }

  // ---------------------------
  //          UI WIDGET
  // ---------------------------
  Widget _giftCard(GiftModel gift) {
    return GestureDetector(
      onTap: () async {
        RoomController controller = Get.put(RoomController(), permanent: true);
        if (Get.currentRoute == "/RoomScreen") {
          await controller.moveOnClickOnGloablGift(gift);
        } else if (gift.rid != null && gift.liveuid != null) {
          swipToPage(
            context,
            RoomScreen(creatorId: gift.liveuid, roomId: gift.rid!),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProfileAvatar(
            user: gift.sender!,
            radius: 14.r, // كان 15
          ),
          SizedBox(width: 3.w),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gift.sender?.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                Expanded(
                  child: UserIdWidget(
                    user: gift.sender,
                    maxLines: 1,
                    size: 20.r,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          AppImage(
            image: gift.giftImage,
            width: 15.r, // كان 15
            height: 15.r,
          ),
          SizedBox(width: 4.w),
          Text(
            "× ${gift.count}",
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(width: 3.w),
          ClipOval(
            child: AppImage(
              image: _currentGift?.to?.avatar,
              width: 28.r, // كان 30
              height: 28.r,
            ),
          ),
        ],
      ),
    );
  }

  String _bannerAsset(GiftModel gift) {
    // final total = gift.roomlevel?.total ?? 0;
    // if (total < 10000) return "assets/images/gift_banner1.png";
    // if (total >= 10000 && total < 20000) return "assets/images/gift_banner2.png";
    // return "assets/images/gift_banner3.png";
    return "assets/images/gift_banner${gift.globalNotifyLvl == 0 ? 1 : gift.globalNotifyLvl}.png";
  }

  @override
  Widget build(BuildContext context) {
    if (_currentGift == null) return const SizedBox.shrink();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Align(
            alignment: Alignment.center,
            child: Container(
              height: 85.h,
              padding: EdgeInsets.symmetric(
                horizontal: 105.w,
                vertical: 20.h,
              ).copyWith(top: 33.r), // أكبر
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.contain,
                  image: AssetImage(_bannerAsset(_currentGift!)),
                ),
                borderRadius: BorderRadius.circular(120),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _giftCard(_currentGift!),
            ),
          ),
        ),
      ),
    );
  }
}
