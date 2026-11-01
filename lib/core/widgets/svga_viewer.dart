import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:tom_chat/core/theme/color.dart';

class SvgaViwer extends StatefulWidget {
  final String networkSvga;
  final String? assetsSvga;
  final bool repeated;
  final Function()? onFinish;
  final Function()? onStart;
  final double? width;
  final double? height;
  final int? count;
  final BoxFit? fit;
  final bool pauseOnLastFrame;
  final bool withLoading;
  const SvgaViwer({
    super.key,
    this.networkSvga = "",
    this.assetsSvga,
    this.pauseOnLastFrame = false,
    this.withLoading = false,
    this.repeated = true,
    this.onFinish,
    this.onStart,
    this.width,
    this.height,
    this.count,
    this.fit,
  });

  @override
  State<SvgaViwer> createState() => _SvgaViwerState();
}

class _SvgaViwerState extends State<SvgaViwer>
    with SingleTickerProviderStateMixin {
  late SVGAAnimationController _controller;
  int _count = 0;
  bool _hasFinished = false;
  VoidCallback? _animationListener;

  @override
  void initState() {
    super.initState();
    _controller = SVGAAnimationController(vsync: this);
    _count = widget.count ?? 1;
    _loadAnimation();
  }

  @override
  void dispose() {
    if (_animationListener != null) {
      _controller.removeListener(_animationListener!);
    }
    _controller.dispose();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(SvgaViwer oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   if (oldWidget.networkSvga != widget.networkSvga) {
  //     _loadAnimation();
  //   }
  // }

  bool isLoading = true;

  void _loadAnimation() async {
    MovieEntity videoItem;
    try {
      if (widget.assetsSvga != null) {
        videoItem = await SVGAParser.shared
            .decodeFromAssets(widget.assetsSvga!)
            .whenComplete(() {
              setState(() {
                isLoading = false;
              });
            });
      } else {
        videoItem = await SVGAParser.shared
            .decodeFromURL(widget.networkSvga)
            .whenComplete(() {
              setState(() {
                isLoading = false;
              });
            });
      }

      SVGACache.shared.setMaxCacheSize(300 * 1024 * 1024);
      SVGACache.shared.setMaxAge(const Duration(days: 60));

      _controller.videoItem = videoItem;

      // Create and store the listener
      _animationListener = () {
        if (_controller.isCompleted && !_hasFinished) {
          _count--;
          if (_count <= 0) {
            _hasFinished = true;
            if (widget.onFinish != null) {
              widget.onFinish!();
            }
            _controller.stop();
          } else {
            // Reset and continue animation for remaining count
            _controller.reset();
            _controller.forward();
          }
        }
      };

      _controller.addListener(_animationListener!);

      if (widget.repeated && widget.count != null) {
        _controller.forward();
      } else if (widget.repeated) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    } catch (_) {
      widget.onFinish?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? Center(
              child: widget.withLoading
                  ? CupertinoActivityIndicator(
                      radius: 20.r,
                      color: AppColors.primaryDark,
                    )
                  : SizedBox.shrink(),
            )
          : SVGAImage(
              _controller,
              clearsAfterStop: !widget.pauseOnLastFrame,
              fit: widget.fit ?? BoxFit.contain,
              preferredSize: widget.width != null && widget.height != null
                  ? Size(widget.width!, widget.height!)
                  : null,
            ),
    );
  }
}
