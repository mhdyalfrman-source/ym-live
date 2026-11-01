import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/features/rooms/controllers/room_controller.dart';

class LuckyWinOnGiftBox extends StatefulWidget {
  final RoomController controller;

  const LuckyWinOnGiftBox({super.key, required this.controller});

  @override
  State<LuckyWinOnGiftBox> createState() => _LuckyWinOnGiftBoxState();
}

class _LuckyWinOnGiftBoxState extends State<LuckyWinOnGiftBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  bool _visible = false;
  bool _playing = false;

  int? _currentWin; // هذا هو اللي "انعرض" فعلا

  Worker? _worker;

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _slide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: Offset(-1, 0),
          end: const Offset(0, 0),
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 25,
      ),
      TweenSequenceItem(tween: ConstantTween<Offset>(Offset(0, 0)), weight: 75),
    ]).animate(_anim);

    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_anim);

    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onFinishedShowing();
      }
    });

    _worker = ever(widget.controller.luckyWins, (_) {
      if (!_playing) _startNext();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNext();
    });
  }

  void _startNext() {
    if (!mounted) return;
    if (_playing) return;

    final list = widget.controller.luckyWins;
    if (list.isEmpty) {
      setState(() => _visible = false);
      return;
    }

    _currentWin = list.first;
    setState(() => _visible = true);

    _playing = true;
    _anim.forward(from: 0);
  }

  void _onFinishedShowing() {
    if (!mounted) return;

    final list = widget.controller.luckyWins;
    if (_currentWin != null) {
      list.removeAt(0);
    }

    _playing = false;

    if (list.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startNext());
    } else {
      setState(() => _visible = false);
    }
  }

  @override
  void dispose() {
    _worker?.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10.h),
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6).r,
          child: Row(
            children: [
              SizedBox(width: 10.w),
              Image.asset("assets/images/lucky_win.webp", height: 15.sp),
              SizedBox(width: 5.w),
              Image.asset("assets/images/coin.png", height: 20.sp),
              SizedBox(width: 5.w),
              Text(
                "x${_currentWin ?? 0}",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
