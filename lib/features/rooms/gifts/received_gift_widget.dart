import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/features/rooms/models/room_model.dart';
import 'package:tom_chat/l10n/l10n.dart';

class ReceivedGiftWidget extends StatefulWidget {
  final GiftModel gift;
  final Function() onFinish;
  final Function()? onTap;
  final TextDirection directionality;
  final RoomModel room;
  const ReceivedGiftWidget({
    super.key,
    required this.gift,
    required this.onFinish,
    this.onTap,
    this.directionality = TextDirection.ltr,
    required this.room,
  });

  @override
  State<ReceivedGiftWidget> createState() => _ReceivedGiftWidgetState();
}

class _ReceivedGiftWidgetState extends State<ReceivedGiftWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  int _previousCount = 0;
  int _displayCount = 1;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Scale animation for count changes
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.5, end: 1).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.elasticOut,
      ),
    );

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

    _previousCount = widget.gift.count;

    // Start entrance animation
    _slideAnimationController.forward();
    // Start counter animation with delay
    _startCounterAnimation();
  }

  void _startCounterAnimation() {
    _displayCount = 1;
    _isAnimating = true;
    _animateToNextCount();
  }

  void _animateToNextCount() {
    _displayCount = widget.gift.count;
    Future.delayed(Duration(seconds: widget.gift.isAllNotify != 0 ? 5 : 3), () {
      widget.onFinish();
    });
    // if (_displayCount < widget.gift.count && mounted) {
    //   Future.delayed(const Duration(milliseconds: 500), () {
    //     if (mounted) {
    //       setState(() {
    //         _displayCount++;
    //       });
    //       _scaleAnimationController.reset();
    //       _scaleAnimationController.forward();
    //       _animateToNextCount();
    //     }
    //   });
    // } else {
    //   _isAnimating = false;
    //   // Finished counting, wait before calling onFinish
    //   Future.delayed(Duration(seconds: widget.gift.isAllNotify != 0 ? 20 : 10), () {
    //     if (!_isAnimating) {
    //       widget.onFinish();
    //     }
    //   });
    // }
  }

  @override
  void didUpdateWidget(ReceivedGiftWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.gift.count != _previousCount) {
      _scaleAnimationController.reset();
      _scaleAnimationController.forward();

      // Update previous count and continue animation if count increased
      _previousCount = widget.gift.count;

      // If we're not currently animating, restart the animation
      if (!_isAnimating) {
        _isAnimating = true;
        _animateToNextCount();
      }
      // If we are animating, the current animation will continue until it reaches the new count
    }
  }

  @override
  void dispose() {
    _scaleAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 4.0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    gradient: LinearGradient(
                      colors: [Colors.black45, Colors.transparent],
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProfileAvatar(radius: 18.r, user: widget.gift.sender!),
                      const SizedBox(width: 5),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 120),
                            child: Text(
                              widget.gift.sender?.name ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${context.l10n.send} ${widget.gift.name}!',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[300],
                                )
                                .apply(fontSizeDelta: -1),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      AppImage(image: widget.gift.giftImage, height: 30),
                      if (widget.gift.isAllNotify != 0) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.language, size: 20.r),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'x$_displayCount',
                            style: theme.textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                )
                                .apply(fontSizeDelta: 3),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
