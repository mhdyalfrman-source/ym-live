import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/rooms/models/gift_model.dart';
import 'package:tom_chat/l10n/l10n.dart';

class GiftItemWidget extends StatefulWidget {
  final bool isSelected;
  final Function() onSelect;
  final Function() onIncrease;
  final Function()? onSend;
  final GiftModel giftModel;
  final bool isCombo;
  final Function(int)? onComplete;
  final String? requiredLevel;
  final bool isLocked;
  final bool userHasVip;
  final bool withoutAnimation;
  final int? initialComboCount;
  const GiftItemWidget({
    super.key,
    required this.isSelected,
    required this.onSelect,
    required this.giftModel,
    required this.isCombo,
    required this.onIncrease,
    this.onSend,
    this.onComplete,
    this.requiredLevel,
    required this.userHasVip,
    this.isLocked = false,
    this.withoutAnimation = false,
    this.initialComboCount,
  });

  @override
  State<GiftItemWidget> createState() => _GiftItemWidgetState();
}

class _GiftItemWidgetState extends State<GiftItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.withoutAnimation) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void didUpdateWidget(GiftItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected &&
        !oldWidget.isSelected &&
        !widget.withoutAnimation) {
      _animationController.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (widget.isLocked) return;
        widget.onSelect();
      },
      child: Container(
        clipBehavior: widget.isSelected ? Clip.antiAlias : Clip.none,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: widget.withoutAnimation && widget.isSelected
              ? Colors.grey.withAlpha(50)
              : null,
          border: widget.withoutAnimation && widget.isSelected
              ? Border.all(color: Colors.grey.shade200)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5).r,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: widget.isSelected
                              ? _scaleAnimation.value
                              : 1.0,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: AppImage(image: widget.giftModel.giftImage),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (!widget.isSelected || widget.withoutAnimation) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLocked) ...[
                        Container(
                          padding: const EdgeInsets.all(1),
                          color: Colors.grey.withOpacity(0.2),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          widget.giftModel.name,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                if (widget.giftModel.type == GiftType.backPack) ...[
                  Text(
                    'x${widget.giftModel.lng}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/coin.png', width: 12),
                      const SizedBox(width: 2),
                      Text(
                        '${widget.giftModel.coins}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                if (widget.isSelected && widget.onSend != null)
                  SizedBox(
                    width: double.infinity,
                    height: 25.h,
                    child: GeneralButton3(
                      color: AppColors.primaryDark,
                      fontColor: Colors.white,
                      padding: EdgeInsets.all(3),
                      onPressed:
                          widget.giftModel.type == GiftType.vip &&
                              !widget.userHasVip
                          ? null
                          : () async{
                              if (widget.isLocked || widget.onSend == null)
                                return;
                              await widget.onSend?.call();
                            },
                      title: context.l10n.send,
                    ),
                  ),
              ],
            ),
            if (widget.requiredLevel != null)
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    widget.requiredLevel!,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )
                        .apply(fontSizeDelta: -1),
                  ),
                ),
              ),
            if (widget.giftModel.isAllNotify != 0)
              Positioned(
                top: 10,
                left: 10,
                child: Icon(Icons.language_outlined, size: 15.r),
              ),
          ],
        ),
      ),
    );
  }
}
