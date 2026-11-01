import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:tom_chat/models/user/user_model.dart';

class UserNameWidget extends StatelessWidget {
  final UserModel? user;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextAlign? textAlign;
  final double? width;
  const UserNameWidget({
    super.key,
    required this.user,
    required this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // if(user?.vip?.color != null){
    //   return ClipRRect(
    //     borderRadius: BorderRadius.circular(10).r,
    //     child: BackdropFilter(
    //       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    //       child: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.grey.shade200.withOpacity(0.4),
    //           borderRadius: BorderRadius.circular(10).r
    //         ),
    //         padding: EdgeInsets.symmetric(vertical: 2,horizontal: 4).r,
    //         child:  AutoScrollText(
    //           text:user?.name??"",
    //           style: style?.copyWith(
    //             color: user?.vip?.color,
    //           ),
    //           maxLines: maxLines,
    //           overflow: overflow,
    //           textAlign: textAlign,
    //           width: width,
    //         )
    //       ),
    //     ),
    //   );
    // }
    return AutoScrollText(
      text: user?.name ?? "",
      style: style?.copyWith(color: user?.vip?.color),
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      width: width,
    );
  }
}

class AutoScrollText extends StatelessWidget {
  final double? width;
  final String text;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;
  final TextAlign? textAlign;

  const AutoScrollText({
    super.key,
    this.width,
    required this.text,
    this.maxLines,
    this.overflow,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? DefaultTextStyle.of(context).style;

    // حساب طول النص
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      maxLines: maxLines ?? 1,
      textDirection: TextDirection.ltr,
    )..layout();

    // النص يحتاج عرض هذا
    final textWidth = textPainter.size.width;

    // نأخذ أصغر قيمة بين العرض الممرر و عرض النص
    double finalWidth = width != null ? width!.clamp(0, textWidth) : textWidth;

    // if(finalWidth < 80 && width! > 80){
    //   finalWidth = 80;
    // }

    if (width == null ||
        (textWidth <= (width ?? 0) && width != double.infinity)) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    return SizedBox(
      height: (textStyle.fontSize ?? 22) + 5,
      width: finalWidth,
      child: Align(
        alignment: textAlign == TextAlign.start
            ? AlignmentDirectional.centerStart
            : textAlign == TextAlign.end
            ? AlignmentDirectional.centerEnd
            : Alignment.center,
        child: Marquee(
          text: text,
          style: textStyle,
          scrollAxis: Axis.horizontal,
          blankSpace: textWidth / 2, // intervalSpaces
          velocity: 50.0, // نفس pixelsPerSecond
          startAfter: const Duration(seconds: 1), // delayBefore
          pauseAfterRound: const Duration(milliseconds: 0), // pauseBetween
          showFadingOnlyWhenScrolling: true,
          fadingEdgeStartFraction: 0.1,
          fadingEdgeEndFraction: 0.1,
          textDirection: Directionality.of(context) == TextDirection.rtl
              ? TextDirection.ltr
              : TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
      ),
    );
  }
}
