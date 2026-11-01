import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/profile/components/follow_button.dart';
import 'package:tom_chat/features/profile/components/user_name_widget.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class TreasureBoxCounterBottomSheet extends StatefulWidget {
  const TreasureBoxCounterBottomSheet({
    super.key,
    required this.box,
    required this.liveId,
    required this.onUpdateBoxValue,
  });

  final RedBoxModel box;
  final int liveId;
  final Function(RedBoxModel) onUpdateBoxValue;

  @override
  State<TreasureBoxCounterBottomSheet> createState() =>
      _TreasureBoxCounterBottomSheetState();
}

class _TreasureBoxCounterBottomSheetState
    extends State<TreasureBoxCounterBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Timer? _timer;

  late int _remainingSeconds;
  bool isEmptyBox = false;
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();

    /// --- Animation setup ---
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _scaleController.repeat(reverse: true);

    _startCurrentBox();
  }

  void _startCurrentBox() {
    final currentBox = widget.box;
    _remainingSeconds = currentBox.seconds.toInt();

    if (_remainingSeconds <= 0) {
      _remainingSeconds = 0;
    }

    isEmptyBox = currentBox.coins == 0;
    _isOpening = (currentBox.reward ?? 0) != 0 || isEmptyBox;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        // _onBoxFinished();
      } else {
        setState(() => _remainingSeconds--);
      }
    });

    setState(() {});
  }

  bool isloaded = false;

  @override
  void dispose() {
    _timer?.cancel();
    _scaleController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.box;

    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 25.h),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF6DA), Colors.white],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// --- Header ---
              if (box.user != null)
                Row(
                  children: [
                    ProfileAvatar(user: box.user, radius: 20.r),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: UserNameWidget(
                        user: box.user!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

              ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  _isOpening
                      ? 'assets/images/open_image.png'
                      : 'assets/images/image_treasure_3.png',
                  height: 120.h,
                ),
              ),

              if (!_isOpening) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/coin.png", height: 37),
                    SizedBox(width: 6),
                    Text(
                      "${box.coins}",
                      style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  context.l10n.viewersCanCollectCoins(
                    box.coinsRemaining.toString(),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.4,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 15.h),
                InkWell(
                  onTap: () async {
                    if (_remainingSeconds == 0) {
                      setState(() {
                        isloaded = true;
                      });
                      var res = await CallServerAPI.post("livebox/use", {
                        "box_id": box.id,
                        "liveuid": widget.liveId,
                      });
                      if (res.isNotEmpty && res["done"] == 1) {
                        setState(() {
                          _isOpening = true;
                          box.coinsRemaining = res["coins"];
                          box.reward = res["reward"];
                        });
                        widget.onUpdateBoxValue.call(box);
                      }
                      setState(() {
                        isloaded = false;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: _remainingSeconds == 0
                          ? AppColors.primaryDark
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: isloaded
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            _remainingSeconds == 0
                                ? context.l10n.getIt
                                : _formatTime(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: _remainingSeconds == 0
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                  ),
                ),
              ] else if (isEmptyBox) ...[
                Text(
                  context.l10n.treasureBoxEmpty,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                Text(
                  context.l10n.allCoinsCollected,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.black.withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 65.h),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/coin.png", height: 37),
                    SizedBox(width: 6),
                    Text(
                      "${box.reward}",
                      style: TextStyle(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  context.l10n.youGetCoins(box.reward.toString()),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                SizedBox(height: 20.h),
                InkWell(
                  onTap: Get.back,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      context.l10n.close,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }
}
