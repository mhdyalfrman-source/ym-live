import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/l10n/l10n.dart';

class ReceivedLuckyGiftWidget extends StatefulWidget {
  final GiftModel gift;
  final Function() onFinish;
  final TextDirection directionality;
  const ReceivedLuckyGiftWidget({
    super.key,
    required this.gift,
    required this.onFinish,
    this.directionality = TextDirection.ltr,
  });

  @override
  State<ReceivedLuckyGiftWidget> createState() =>
      _ReceivedLuckyGiftWidgetState();
}

class _ReceivedLuckyGiftWidgetState extends State<ReceivedLuckyGiftWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Slide and fade animation for widget entrance
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation =
        Tween<Offset>(
          begin: widget.directionality == TextDirection.rtl
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _slideAnimationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start entrance animation
    _slideAnimationController.forward();
    // Start counter animation with delay
    _animateToNextCount();
  }

  void _animateToNextCount() {
    Future.delayed(const Duration(milliseconds: 4000), () {
      widget.onFinish();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: CardWidget(
          colorIndex: 1,
          radius: 15.r,
          child: Padding(
            padding: const EdgeInsets.all(5).r,
            child: SizedBox(
              width: Get.width * 0.6,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 15),
                  ProfileAvatar(radius: 18.r, user: widget.gift.sender),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.gift.sender?.name ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // CachedNetworkImage(
                            //   imageUrl: widget.gift.giftImage,
                            //   placeholder: (context, url) => const SizedBox.shrink(),
                            //   errorWidget: (context, url, error) =>
                            //       const Icon(Icons.error),
                            //   height: 15.r,
                            // ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${context.l10n.win} ${widget.gift.coins}',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[300],
                                  )
                                  .apply(fontSizeDelta: -1),
                            ),
                            SizedBox(width: 5.w),
                            Image.asset(
                              "assets/images/coin.png",
                              height: 12.sp,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
