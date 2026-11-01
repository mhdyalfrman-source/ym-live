import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ChatBubblePro extends StatelessWidget {
  final String text;
  final String? bubbleUrl;
  final Widget? child;
  final double? width;
  final TextStyle? style;
  final Color textColor;

  const ChatBubblePro({
    super.key,
    required this.text,
    required this.bubbleUrl,
    this.child,
    this.style,
    this.width,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null && (bubbleUrl ?? "") == "") {
      return child ?? SizedBox();
    }
    return FutureBuilder<ui.Image>(
      future: _loadImage(bubbleUrl!),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Text(text);
        }

        final img = snap.data!;

        /// الحواف ثابتة 12px
        const edge = 0.0;

        return CustomPaint(
          painter: _FourSlicePainterPro(image: img, edge: edge),
          child: Container(
            constraints: BoxConstraints(maxWidth: width ?? Get.width / 2),
            padding: EdgeInsets.symmetric(
              vertical: text.length > 10 ? 20 : 10,
              horizontal: text.length > 10 ? 26 : 16,
            ).r,
            child:
                child ??
                Text(
                  text,
                  style: style ?? TextStyle(color: textColor),
                  softWrap: true, // يضمن تغليف النص على أسطر متعددة
                ),
          ),
        );
      },
    );
  }

  Future<ui.Image> _loadImage(String url) async {
    final provider = CachedNetworkImageProvider(url);
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(const ImageConfiguration());
    void listener(ImageInfo info, bool _) {
      completer.complete(info.image);
      stream.removeListener(ImageStreamListener(listener));
    }

    stream.addListener(ImageStreamListener(listener));
    return completer.future;
  }
}

class _FourSlicePainterPro extends CustomPainter {
  final ui.Image image;
  final double edge;

  _FourSlicePainterPro({required this.image, required this.edge});

  @override
  void paint(Canvas canvas, Size size) {
    final w = image.width.toDouble();
    final h = image.height.toDouble();

    // تقسيم الصورة 4 شرائح: 2x2
    final src = [
      Rect.fromLTWH(0, 0, edge, edge), // top-left
      Rect.fromLTWH(edge, 0, w - edge, edge), // top-right
      Rect.fromLTWH(0, edge, edge, h - edge), // bottom-left
      Rect.fromLTWH(edge, edge, w - edge, h - edge), // bottom-right
    ];

    final dst = [
      Rect.fromLTWH(0, 0, edge, edge),
      Rect.fromLTWH(edge, 0, size.width - edge, edge),
      Rect.fromLTWH(0, edge, edge, size.height - edge),
      Rect.fromLTWH(edge, edge, size.width - edge, size.height - edge),
    ];

    for (int i = 0; i < 4; i++) {
      canvas.drawImageRect(image, src[i], dst[i], Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NineSlicePainterPro extends CustomPainter {
  final ui.Image image;
  final double edge;

  _NineSlicePainterPro({required this.image, required this.edge});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    final w = image.width.toDouble();
    final h = image.height.toDouble();

    final left = edge;
    final right = edge;
    final top = edge;
    final bottom = edge;

    /// source rects (الصورة الأصلية)
    final src = [
      Rect.fromLTWH(0, 0, left, top), //1
      Rect.fromLTWH(left, 0, w - left - right, top), //2
      Rect.fromLTWH(w - right, 0, right, top), //3

      Rect.fromLTWH(0, top, left, h - top - bottom), //4
      Rect.fromLTWH(left, top, w - left - right, h - top - bottom), //5
      Rect.fromLTWH(w - right, top, right, h - top - bottom), //6

      Rect.fromLTWH(0, h - bottom, left, bottom), //7
      Rect.fromLTWH(left, h - bottom, w - left - right, bottom), //8
      Rect.fromLTWH(w - right, h - bottom, right, bottom), //9
    ];

    /// destination rects (الحجم بعد التمدد)
    final dst = [
      Rect.fromLTWH(0, 0, left, top),
      Rect.fromLTWH(left, 0, size.width - left - right, top),
      Rect.fromLTWH(size.width - right, 0, right, top),

      Rect.fromLTWH(0, top, left, size.height - top - bottom),
      Rect.fromLTWH(
        left,
        top,
        size.width - left - right,
        size.height - top - bottom,
      ),
      Rect.fromLTWH(size.width - right, top, right, size.height - top - bottom),

      Rect.fromLTWH(0, size.height - bottom, left, bottom),
      Rect.fromLTWH(
        left,
        size.height - bottom,
        size.width - left - right,
        bottom,
      ),
      Rect.fromLTWH(size.width - right, size.height - bottom, right, bottom),
    ];

    for (int i = 0; i < 9; i++) {
      canvas.drawImageRect(image, src[i], dst[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;

// import 'package:flutter/services.dart';

// class ChatBubblePro extends StatelessWidget {
//   final String text;
//   final String? bubbleUrl;
//   final Widget? child;
//   final TextStyle? style;
//   final Color textColor;

//   const ChatBubblePro({
//     super.key,
//     required this.text,
//     required this.bubbleUrl,
//     this.child,
//     this.style,
//     this.textColor = Colors.white,
//   });

//   @override
//   Widget build(BuildContext context) {
//     if(child != null && bubbleUrl == null){
//       return child ?? SizedBox();
//     }
//     return FutureBuilder<ui.Image>(
//       future: _loadImage(bubbleUrl!),
//       builder: (context, snap) {
//         if (!snap.hasData) {
//           return Text(text);
//         }

//         final img = snap.data!;

//         /// الحواف ثابتة 12px—تكفي لحفظ شكل الزوايا
//         const edge = 0.0;

//         return CustomPaint(
//           painter: _NineSlicePainterPro(
//             image: img,
//             left: edge,
//             right: edge,
//             top: edge,
//             bottom: edge,
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               vertical: 12,
//               horizontal: 18,
//             ),
//             child: Text(
//               text,
//               style: style ?? TextStyle(color: textColor),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<ui.Image> _loadImage(String url) async {
//     final data = await NetworkAssetBundle(Uri.parse(url)).load(url);
//     final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
//     final frame = await codec.getNextFrame();
//     return frame.image;
//   }
// }

// class _NineSlicePainterPro extends CustomPainter {
//   final ui.Image image;
//   final double left, right, top, bottom;

//   _NineSlicePainterPro({
//     required this.image,
//     required this.left,
//     required this.right,
//     required this.top,
//     required this.bottom,
//   });

//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = image.width.toDouble();
//     final h = image.height.toDouble();

//     /// تقسيم الصورة 9-شرائح
//     final src = <Rect>[
//       Rect.fromLTWH(0, 0, left, top),
//       Rect.fromLTWH(left, 0, w - left - right, top),
//       Rect.fromLTWH(w - right, 0, right, top),

//       Rect.fromLTWH(0, top, left, h - top - bottom),
//       Rect.fromLTWH(left, top, w - left - right, h - top - bottom),
//       Rect.fromLTWH(w - right, top, right, h - top - bottom),

//       Rect.fromLTWH(0, h - bottom, left, bottom),
//       Rect.fromLTWH(left, h - bottom, w - left - right, bottom),
//       Rect.fromLTWH(w - right, h - bottom, right, bottom),
//     ];

//     final dst = <Rect>[
//       Rect.fromLTWH(0, 0, left, top),
//       Rect.fromLTWH(left, 0, size.width - left - right, top),
//       Rect.fromLTWH(size.width - right, 0, right, top),

//       Rect.fromLTWH(0, top, left, size.height - top - bottom),
//       Rect.fromLTWH(left, top, size.width - left - right, size.height - top - bottom),
//       Rect.fromLTWH(size.width - right, top, right, size.height - top - bottom),

//       Rect.fromLTWH(0, size.height - bottom, left, bottom),
//       Rect.fromLTWH(left, size.height - bottom, size.width - left - right, bottom),
//       Rect.fromLTWH(size.width - right, size.height - bottom, right, bottom),
//     ];

//     for (int i = 0; i < 9; i++) {
//       canvas.drawImageRect(image, src[i], dst[i], Paint());
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
