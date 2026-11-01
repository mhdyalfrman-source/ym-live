import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';
import 'package:tom_chat/features/rooms/models/red_box.dart';
import 'package:tom_chat/l10n/l10n.dart';

class GlobalRedBoxQueueWidget extends StatefulWidget {
  final RoomController controller;
  final Duration displayDuration;
  final Function(RedBoxModel? red) onMoveToNewLive;

  const GlobalRedBoxQueueWidget({
    super.key,
    required this.controller,
    this.displayDuration = const Duration(seconds: 7),
    required this.onMoveToNewLive,
  });

  @override
  State<GlobalRedBoxQueueWidget> createState() =>
      _GlobalRedBoxQueueWidgetState();
}

class _GlobalRedBoxQueueWidgetState extends State<GlobalRedBoxQueueWidget>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  Timer? _autoRemoveTimer;
  bool _isRemoving = false;

  Worker? _queueWorker;

  Color goldLight = Color(0xFFFFE082); // ذهبي فاتح
  Color goldMain = Color(0xFFFFC107); // ذهبي أساسي
  Color goldDark = Color(0xFFFFA000); // ذهبي غامق
  Color redBoxMain = Color(0xFFD32F2F); // أحمر الصندوق
  Color redBoxDark = Color(0xFFB71C1C); // أحمر غامق

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    // نراقب اللستة: أول ما يصير فيها عنصر ومو شغال تايمر/حذف -> نبدأ عرض
    _queueWorker = ever<List<RedBoxModel>>(widget.controller.redBoxQueue, (
      list,
    ) {
      if (!mounted) return;
      if (list.isEmpty) {
        _autoRemoveTimer?.cancel();
        return;
      }
      // إذا عندنا عنصر جديد ولا يوجد تايمر (يعني ما في عرض قائم)
      if (_autoRemoveTimer == null && !_isRemoving) {
        _showCurrent();
      }
    });

    // لو كانت اللستة فيها عناصر من البداية
    if (widget.controller.redBoxQueue.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showCurrent());
    }
  }

  @override
  void dispose() {
    _queueWorker?.dispose();
    _autoRemoveTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _showCurrent() async {
    if (!mounted) return;
    if (widget.controller.redBoxQueue.isEmpty) return;

    // slide in
    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _slideController.reset();
    await _slideController.forward();

    _resetAutoRemoveTimer();
  }

  void _resetAutoRemoveTimer() {
    _autoRemoveTimer?.cancel();
    if (widget.controller.redBoxQueue.isEmpty) {
      _autoRemoveTimer = null;
      return;
    }

    _autoRemoveTimer = Timer(widget.displayDuration, _removeCurrent);
  }

  Future<void> _removeCurrent() async {
    if (!mounted) return;
    if (_isRemoving) return;
    if (widget.controller.redBoxQueue.isEmpty) return;

    setState(() => _isRemoving = true);

    // slide out
    _slideAnimation =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _slideController.reset();
    await _slideController.forward();

    if (!mounted) return;

    // احذف الأول
    if (widget.controller.redBoxQueue.isNotEmpty) {
      widget.controller.redBoxQueue.removeAt(0);
    }

    // نظّف التايمر الحالي (خلاص انتهى)
    _autoRemoveTimer?.cancel();
    _autoRemoveTimer = null;

    setState(() => _isRemoving = false);

    // لو في عناصر بعدها اعرض التالي
    if (widget.controller.redBoxQueue.isNotEmpty) {
      await _showCurrent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = widget.controller.redBoxQueue;
      if (list.isEmpty) return const SizedBox.shrink();

      final box = list.first;

      return SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () async {
            if (box.liveuid == widget.controller.room.value.owner?.userId)
              return;
            await widget.onMoveToNewLive(box);
          },
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [goldLight, goldMain, redBoxMain, redBoxDark],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
              borderRadius: BorderRadius.circular(1000),
              border: Border.all(
                color: goldLight.withValues(alpha: 0.8),
                width: 1.5,
              ),
              boxShadow: [
                // Glow ذهبي
                BoxShadow(
                  color: goldMain.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
                // ظل ناعم
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _buildRedBoxCard(context, box),
          ),
        ),
      );
    });
  }

  Widget _buildRedBoxCard(BuildContext context, RedBoxModel box) {
    final theme = Theme.of(context);

    final personName = box.user?.name ?? 'Unknown';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/image_treasure_3.png',
          fit: BoxFit.contain,
          width: 30.r,
          height: 30.r,
        ),
        const SizedBox(width: 8),

        Expanded(
          child: Text(
            context.l10n.userSentRedBox(personName),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(width: 8),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(1000),
          ),
          child: Row(
            children: [
              Text(
                'x${MyMath.toInt(box.coins)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Image.asset("assets/images/coin.png", height: 16.sp),
            ],
          ),
        ),
      ],
    );
  }
}
