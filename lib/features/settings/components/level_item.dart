import 'package:flutter/material.dart';

class LevelProgress extends StatelessWidget {
  /// القيمة الحالية (مثل: نقاط المستخدم الحالية)
  final double current;

  /// القيمة الإجمالية المطلوبة للـ level (مثل: نقاط المطلوب)
  final double total;

  /// ارتفاع الشريط
  final double height;

  /// وقت الانيميشن عند تغيّر القيمة
  final Duration animationDuration;

  /// خلفية الشريط (الخلفية غير المملوءة)
  final Color backgroundColor;

  /// لون التعبئة أو تدرج لوني (إذا أعطيت قيمة هنا سيتم تجاهل fillColor)
  final Gradient? fillGradient;

  /// لون تعبئة وحيد إذا لم تُعطَ fillGradient
  final Color fillColor;

  /// نصف القطر لحواف الشريط
  final double borderRadius;

  /// إظهار نص النسبة داخل الشريط أم لا
  final bool showPercentage;

  /// نص مخصص يعرض بجانب الشريط (مثل "مرحلة 2")
  final Widget? trailing;

  /// إظهار مؤشر دائري عند موضع القيمة الحالية
  final bool showHandle;

  /// حجم المؤشر
  final double handleSize;

  const LevelProgress({
    super.key,
    required this.current,
    required this.total,
    this.height = 14.0,
    this.animationDuration = const Duration(milliseconds: 600),
    this.backgroundColor = const Color(0xffE6E6E6),
    this.fillGradient,
    this.fillColor = const Color(0xff6DD3B0),
    this.borderRadius = 12.0,
    this.showPercentage = true,
    this.trailing,
    this.showHandle = false,
    this.handleSize = 18.0,
  });

  double _clampedPercent() {
    if (total <= 0) return 0.0;
    final p = current / total;
    if (p.isNaN) return 0.0;
    return p.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final percent = _clampedPercent();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // الشريط نفسه
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final fullWidth = constraints.maxWidth;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: percent),
                  duration: animationDuration,
                  curve: Curves.easeOutCubic,
                  builder: (context, animatedPercent, _) {
                    double fillWidth = fullWidth * animatedPercent;
                    double handleOffset = (showHandle
                        ? (fillWidth - handleSize / 2).clamp(
                            0.0,
                            fullWidth - handleSize,
                          )
                        : 0.0);

                    if (percent * 100 < 15 && percent != 0) {
                      handleOffset = 25;
                      fillWidth = 30;
                    }

                    return Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        // الخلفية
                        Container(
                          width: fullWidth,
                          height: height,
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                        ),

                        // التعبئة (الجزء الممتلئ)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(borderRadius),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: fillWidth,
                              height: height,
                              decoration: BoxDecoration(
                                color: fillGradient == null ? fillColor : null,
                                gradient: fillGradient,
                              ),
                            ),
                          ),
                        ),

                        // مؤشر دائري (اختياري)
                        if (showHandle && percent > 0)
                          Positioned(
                            left: handleOffset,
                            child: Container(
                              width: handleSize,
                              height: handleSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 3,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: handleSize * 0.6,
                                  height: handleSize * 0.6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: fillGradient == null
                                        ? fillColor
                                        : null,
                                    gradient: fillGradient,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // نص النسبة داخل الشريط (موجود في اليمين داخل الشريط)
                        if (showPercentage)
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // استخدم SizedBox لتجنب النص يتجاوز الحواف
                                  Flexible(
                                    child: Text(
                                      "${(percent * 100).toStringAsFixed(0)}%",
                                      style: TextStyle(
                                        fontSize: height * 0.8,
                                        fontWeight: FontWeight.w600,
                                        color: fillWidth == 0
                                            ? Colors.black38
                                            : Colors.white,
                                        height: 1,
                                        // color: percent > 0.45 ? Colors.white : Colors.black87,
                                        shadows: percent > 0.45
                                            ? [
                                                Shadow(
                                                  color: Colors.black26,
                                                  offset: Offset(0, 1),
                                                  blurRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // عنصر جانبي اختياري (مثلاً رقم المستوى)
          if (trailing != null) ...[SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
