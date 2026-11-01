import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tom_chat/core/utils/video_cache.dart';
import 'package:video_player/video_player.dart';

class VideoViewer extends StatefulWidget {
  final String? networkVideo;
  final String? assetsVideo;
  final bool repeated;
  final int? count;
  final Function()? onFinish;
  final Function()? onStart;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool withLoading;

  const VideoViewer({
    super.key,
    this.networkVideo,
    this.assetsVideo,
    this.repeated = false,
    this.count,
    this.onFinish,
    this.onStart,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.withLoading = false,
  });

  @override
  State<VideoViewer> createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  late VideoPlayerController _controller;
  bool isLoading = true;

  int _count = 0;
  bool _hasFinished = false;

  VoidCallback? _listener;

  @override
  void initState() {
    super.initState();
    _count = widget.count ?? 1;
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (widget.assetsVideo != null) {
      _controller = VideoPlayerController.asset(widget.assetsVideo!);
    } else {
      File? f = await VideoCache.getFileOnly(widget.networkVideo!);
      if (f != null) {
        _controller = VideoPlayerController.file(f);
      } else {
        VideoCache.getFile(widget.networkVideo!);
        _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.networkVideo!),
        );
      }
    }

    await _controller.initialize();

    _listener = () {
      final position = _controller.value.position;
      final duration = _controller.value.duration;

      if (position >= duration && !_hasFinished) {
        _count--;

        if (_count <= 0) {
          _hasFinished = true;
          widget.onFinish?.call();
          _controller.pause();
        } else {
          _controller.seekTo(Duration.zero);
          _controller.play();
        }
      }
    };

    _controller.addListener(_listener!);

    setState(() {
      isLoading = false;
    });

    widget.onStart?.call();

    if (widget.repeated && widget.count == null) {
      _controller.setLooping(true);
    }

    _controller.play();
  }

  @override
  void dispose() {
    if (_listener != null) {
      _controller.removeListener(_listener!);
    }
    _controller.pause();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return widget.withLoading
          ? const CupertinoActivityIndicator()
          : const SizedBox();
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
