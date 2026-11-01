// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:tom_chat/controllers/socket_manager.dart';
// import 'package:tom_chat/core/utils/my_math.dart';
// import 'package:tom_chat/core/widgets/app_image.dart';
// import 'package:tom_chat/core/widgets/profile_avatar.dart';
// import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
// import 'package:tom_chat/features/rooms/models/gift_model.dart';
// import 'package:tom_chat/models/helpers/image_model.dart';
// import 'package:tom_chat/models/user/user_model.dart';
// import 'dart:async';

// class GiftEntryWidget extends StatefulWidget {
//   final RoomController controller;
//   const GiftEntryWidget({super.key, required this.controller});

//   @override
//   State<GiftEntryWidget> createState() => _GiftEntryWidgetState();
// }

// class _GiftEntryWidgetState extends State<GiftEntryWidget>
//     with TickerProviderStateMixin {
//   final List<GiftModel> _queue = [];
//   GiftModel? _currentGift;

//   late AnimationController _slideController;
//   late Animation<Offset> _slideAnimation;

//   bool _isShowing = false;
//   bool _isHiding = false;

//   bool _disposed = false;
//   Timer? _stayTimer;

//   void Function(dynamic)? _socketHandler;

//   static const Duration stayDuration = Duration(seconds: 4);
//   static Offset offLeft = Offset(-1, 0);
//   static Offset center = Offset((180.w / Get.width) * 0.5, 0);
//   static Offset offRight = Offset(1, 0);

//   @override
//   void initState() {
//     super.initState();

//     _slideController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: offLeft,
//       end: center,
//     ).animate(
//       CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
//     );

//     _socketHandler = (data) {
//       if (_disposed) return;
//       if (data is List) {
//         for (var item in data) {
//           final gift = _convertToGiftModel(item);
//           _queue.add(gift);
//         }
//         _tryShowNext();
//       }
//     };

//     SocketManager.instance.on("roomGift", _socketHandler!);
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     try {
//       if (_socketHandler != null) {
//         SocketManager.instance.off("roomGift", _socketHandler);
//       }
//     } catch (_) {}
//     _stayTimer?.cancel();
//     _slideController.dispose();
//     super.dispose();
//   }

//   GiftModel _convertToGiftModel(Map data) {
//     final sender = UserModel(
//       userId: MyMath.toInt(data["uid"]),
//       pos: UserPosition.user,
//       name: data["uName"] ?? "",
//       avatar: data["uAvatar"] != null ? ImageModel.fromMap(data["uAvatar"]) : null,
//     );

//     final receiver = UserModel(
//       userId: MyMath.toInt(data["touid"]),
//       pos: UserPosition.user,
//       name: data["toName"] ?? "",
//       avatar: data["toAvatar"] != null ? ImageModel.fromMap(data["toAvatar"]) : null,
//     );

//     final map = {
//       "send_id": "${data["uid"]}-${data["touid"]}-${DateTime.now()}",
//       "id": data["gid"],
//       "name": data["name"] ?? "",
//       "count": data["count"] ?? 1,
//       "icon": data["img"],
//       "coins": data["coin_number"] ?? 0,
//       "anim": data["anim"],
//       "type": 0,
//       "mark": 0,
//       "isAllNotify": data["is_all_notify"],
//       "isCp": 0,
//       "rid": data["rid"],
//       "room_level": data["room_level"],
//       "roomImg": data["roomImg"],
//       "uAvatar": data["uAvatar"],
//       "liveuid": data["liveuid"],
//     };

//     return GiftModel.fromJson(map, sender: sender, to: receiver);
//   }

//   // ---------------------------
//   //       QUEUE CONTROL
//   // ---------------------------
//   void _tryShowNext() {
//     if (_isShowing || _isHiding) return;
//     if (_queue.isEmpty) return;
//     _showGift(_queue.first);
//   }

//   Future<void> _showGift(GiftModel gift) async {
//     _currentGift = gift;
//     _isShowing = true;

//     setState(() {});

//     // animate from left → center
//     _slideAnimation = Tween<Offset>(
//       begin: offLeft,
//       end: center,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

//     _slideController.reset();
//     await _slideController.forward();

//     // stay 10 seconds
//     _stayTimer?.cancel();
//     _stayTimer = Timer(stayDuration, () => _hideCurrent());
//   }

//   Future<void> _hideCurrent() async {
//     if (_isHiding || !_isShowing) return;
//     if (_currentGift == null) return;

//     _isHiding = true;

//     setState(() {
//       // animate center → right to vanish
//       _slideAnimation = Tween<Offset>(
//         begin: center,
//         end: offRight,
//       ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeIn));
//     });

//     await _slideController.forward(from: 0);

//     // remove item
//     if (mounted) {
//       setState(() {
//         if (_queue.isNotEmpty) _queue.removeAt(0);
//         _currentGift = null;
//       });
//     }

//     _isShowing = false;
//     _isHiding = false;

//     // show next if exists
//     Future.delayed(const Duration(milliseconds: 150), _tryShowNext);
//   }

//   // ---------------------------
//   //          UI WIDGET
//   // ---------------------------
//   Widget _giftCard(GiftModel gift) {
//     return GestureDetector(
//       onTap: ()async{
//         await widget.controller.moveOnClickOnGloablGift(gift);
//       },
//       child: Row(
//         children: [
//           ProfileAvatar(
//             user: gift.sender!,
//             radius: 15.r,
//           ),
//           const SizedBox(width: 6),
//           Flexible(
//             child: Text(
//               gift.sender?.name ?? "",
//               style: Theme.of(context).textTheme.labelSmall!.copyWith(
//                 fontWeight: FontWeight.bold
//               ),
//             ),
//           ),
//           SizedBox(width: 5.w),
//           AppImage(image: gift.giftImage,width: 15.r,),
//           Text(
//             /*${gift.name} */ "× ${gift.count}",
//             style: Theme.of(context).textTheme.labelSmall!.copyWith(
//               fontWeight: FontWeight.bold
//             ),
//           ),
//           SizedBox(width: 5.w),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(10).r,
//             child: AppImage(
//               image:_currentGift?.uAvatar,
//               width: 30.r,
//               height: 30.r,
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_currentGift == null) return const SizedBox.shrink();

//     return Directionality(
//       textDirection: TextDirection.ltr,
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: Align(
//           alignment: Alignment.centerLeft,
//           child: Container(
//             width: 180.w,
//             padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               // gradient: LinearGradient(colors: colors[1]),
//               image: DecorationImage(image: AssetImage(
//                 (_currentGift?.roomlevel?.total??0) > 10000 && (_currentGift?.roomlevel?.total??0) < 40000 ?
//                 "assets/images/gift_banner1.png" :
//                 (_currentGift?.roomlevel?.total??0) > 40000 && (_currentGift?.roomlevel?.total??0) < 90000 ?
//                 "assets/images/gift_banner2.png" :
//                 "assets/images/gift_banner3.png"

//                 )),
//               borderRadius: BorderRadius.circular(100),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 8,
//                 ),
//               ],
//             ),
//             child: _giftCard(_currentGift!),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/profile/components/user_id_widget.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'dart:async';

class GiftEntryWidget extends StatefulWidget {
  final RoomController controller;
  const GiftEntryWidget({super.key, required this.controller});

  @override
  State<GiftEntryWidget> createState() => _GiftEntryWidgetState();
}

class _GiftEntryWidgetState extends State<GiftEntryWidget>
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

  static const Duration stayDuration = Duration(seconds: 4);

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
          if (gift.isAllNotify ==
              1 /* && gift.rid != widget.controller.room.value.id*/ ) {
            _queue.add(gift);
          }
        }
        _tryShowNext();
      }
    };

    SocketManager.instance.on("roomGift", _socketHandler!);
  }

  @override
  void dispose() {
    _disposed = true;
    try {
      if (_socketHandler != null) {
        SocketManager.instance.off("roomGift", _socketHandler);
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
      specialId: data['uSpecialId'] != null
          ? SpecialId.fromMap(data['uSpecialId'])
          : null,
    );

    final receiver = UserModel(
      userId: MyMath.toInt(data["touid"]),
      pos: UserPosition.user,
      name: data["toName"] ?? "",
      avatar: data["toAvatar"] != null
          ? ImageModel.fromMap(data["toAvatar"])
          : null,
      specialId: data['toSpecialId'] != null
          ? SpecialId.fromMap(data['toSpecialId'])
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
        await widget.controller.moveOnClickOnGloablGift(gift);
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
                    size: 15.r,
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
