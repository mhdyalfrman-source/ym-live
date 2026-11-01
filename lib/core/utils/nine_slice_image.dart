import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A widget that implements nine-slice scaling for images.
///
/// Nine-slice scaling allows an image to be scaled without distorting its edges,
/// similar to Unity's nine-slice feature. The image is divided into nine sections,
/// where the corners maintain their original size while the edges and center are scaled.
class NineSliceImage extends StatelessWidget {
  /// The local image asset path.
  final String imagePath;

  /// The width of the left slice (in pixels).
  final double leftSlice;

  /// The width of the right slice (in pixels).
  final double rightSlice;

  /// The height of the top slice (in pixels).
  final double topSlice;

  /// The height of the bottom slice (in pixels).
  final double bottomSlice;

  /// The width of the rendered image.
  final double width;

  /// The height of the rendered image.
  final double? height;
  final double minHeight;

  /// The background color of the image.
  final Color backgroundColor;

  /// The padding between the image and background (in pixels).
  final double padding;
  final Widget child;

  /// Creates a new [NineSliceImage] widget.
  ///
  /// The [imagePath] parameter is required and should point to a local asset image.
  /// The slice parameters define the size of the non-scaling regions on each edge.
  /// If not specified, they default to 10 pixels.
  /// The [backgroundColor] parameter defines the background color of the image,
  /// defaults to black.
  /// The [padding] parameter defines the space between the image and background,
  /// defaults to 0 pixels.
  const NineSliceImage({
    super.key,
    required this.imagePath,
    required this.width,
    required this.child,
    this.height,
    this.minHeight = 50,
    this.leftSlice = 10.0,
    this.rightSlice = 10.0,
    this.topSlice = 10.0,
    this.bottomSlice = 10.0,
    this.backgroundColor = Colors.transparent,
    this.padding = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: width,
          height: height,
          constraints: BoxConstraints(minHeight: minHeight),
          child: CustomPaint(
            painter: _NineSlicePainter(
              imagePath: imagePath,
              leftSlice: leftSlice,
              rightSlice: rightSlice,
              topSlice: topSlice,
              bottomSlice: bottomSlice,
              backgroundColor: backgroundColor,
              padding: padding,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class _NineSlicePainter extends CustomPainter {
  final String imagePath;
  final double leftSlice;
  final double rightSlice;
  final double topSlice;
  final double bottomSlice;
  final Color backgroundColor;
  final double padding;

  ImageProvider? _imageProvider;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  bool _isDisposed = false;

  _NineSlicePainter({
    required this.imagePath,
    required this.leftSlice,
    required this.rightSlice,
    required this.topSlice,
    required this.bottomSlice,
    required this.backgroundColor,
    required this.padding,
  }) {
    _imageProvider = CachedNetworkImageProvider(imagePath);
    _loadImage();
  }

  void dispose() {
    _isDisposed = true;
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    _imageStream = null;
    _imageInfo?.dispose(); // مهم لإغلاق موارد الصورة
    _imageInfo = null;
    // CustomPainter doesn't have a dispose method in its superclass, so we remove the super.dispose() call
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background first
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    if (_imageInfo == null) {
      _loadImage();
      return;
    }

    final image = _imageInfo!.image;
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    // Define the nine regions of the source image
    final srcRects = _calculateSourceRects(imageWidth, imageHeight);
    final dstRects = _calculateDestinationRects(
      Size(size.width - padding * 2, size.height - padding * 2),
    );

    // Draw all nine slices with padding offset
    for (int i = 0; i < 9; i++) {
      canvas.drawImageRect(
        image,
        srcRects[i],
        dstRects[i].translate(padding, padding),
        Paint(),
      );
    }
  }

  void _loadImage() {
    if (_isDisposed) return;

    if (_imageStream != null) {
      _imageStream!.removeListener(ImageStreamListener(_updateImage));
    }

    _imageStream = _imageProvider!.resolve(ImageConfiguration.empty);
    _imageStream!.addListener(
      ImageStreamListener((ImageInfo imageInfo, bool synchronousCall) {
        if (!_isDisposed) {
          _imageInfo = imageInfo;
        }
      }, onError: (dynamic exception, StackTrace? stackTrace) {}),
    );
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;
  }

  List<Rect> _calculateSourceRects(double width, double height) {
    final List<Rect> rects = [];

    final leftX = [0.0, leftSlice, width - rightSlice];
    final topY = [0.0, topSlice, height - bottomSlice];
    final sliceWidth = [leftSlice, width - leftSlice - rightSlice, rightSlice];
    final sliceHeight = [
      topSlice,
      height - topSlice - bottomSlice,
      bottomSlice,
    ];

    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        rects.add(
          Rect.fromLTWH(leftX[x], topY[y], sliceWidth[x], sliceHeight[y]),
        );
      }
    }

    return rects;
  }

  List<Rect> _calculateDestinationRects(Size size) {
    final List<Rect> rects = [];

    final leftX = [0.0, leftSlice, size.width - rightSlice];
    final topY = [0.0, topSlice, size.height - bottomSlice];
    final sliceWidth = [
      leftSlice,
      size.width - leftSlice - rightSlice,
      rightSlice,
    ];
    final sliceHeight = [
      topSlice,
      size.height - topSlice - bottomSlice,
      bottomSlice,
    ];

    for (int y = 0; y < 3; y++) {
      for (int x = 0; x < 3; x++) {
        rects.add(
          Rect.fromLTWH(leftX[x], topY[y], sliceWidth[x], sliceHeight[y]),
        );
      }
    }

    return rects;
  }

  @override
  bool shouldRepaint(_NineSlicePainter oldDelegate) {
    return imagePath != oldDelegate.imagePath ||
        leftSlice != oldDelegate.leftSlice ||
        rightSlice != oldDelegate.rightSlice ||
        topSlice != oldDelegate.topSlice ||
        bottomSlice != oldDelegate.bottomSlice ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
