import 'package:flutter/material.dart';

class WealthRankBackground extends StatelessWidget {
  /// تدرّج الألوان (من اليسار إلى اليمين)
  final List<Color> gradientColors;

  /// صورة الزخرفة اليمنى (مثلاً AssetImage / NetworkImage / FileImage)
  final ImageProvider? decorationImage;

  /// المحتوى اللي يُعرض فوق الخلفية (نص، أيقونة، ...).
  final Widget? child;

  /// ارتفاع الويجت (اختياري)
  final double? height;

  /// نصف القطر للحواف
  final BorderRadius borderRadius;

  /// حشوة داخلية للمحتوى
  final EdgeInsets padding;

  /// نسبة عرض صورة الزخرفة مقارنة بعرض الحاوية (0.0 - 1.0)
  final double decorationWidthFraction;

  const WealthRankBackground({
    Key? key,
    this.gradientColors = const [Color(0xFFFFF7E0), Color(0xFFFFE8B5)],
    this.decorationImage,
    this.child,
    this.height = 56.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(18.0)),
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.decorationWidthFraction = 0.35,
  }) : assert(decorationWidthFraction > 0 && decorationWidthFraction < 1),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // الخلفية المتدرجة
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            // صورة الزخرفة على الجهة اليمنى (إن وُجدت)
            if (decorationImage != null)
              Align(
                alignment: Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: decorationWidthFraction,
                  heightFactor: 1.0,
                  child: Image(
                    image: decorationImage!,
                    fit: BoxFit.cover,
                    // لو حاب تخفف التداخل مع النص تقدر تغير opacity هنا
                    // color: Colors.white.withOpacity(0.0), colorBlendMode: BlendMode.dst,
                  ),
                ),
              ),

            // محتوى فوق الخلفية
            Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.centerLeft,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
