import 'dart:async';

import 'package:flutter/material.dart';

/// MyTextScroll widget automatically scrolls provided [text] according
/// to custom settings, in order to achieve 'marquee' text effect.
///
/// ### Example:
///
/// ```dart
/// MyTextScroll(
///     'This is the sample text for Flutter MyTextScroll widget. ',
///     mode: TextScrollMode.bouncing,
///     velocity: Velocity(pixelsPerSecond: Offset(150, 0)),
///     delayBefore: Duration(milliseconds: 500),
///     numberOfReps: 5,
///     pauseBetween: Duration(milliseconds: 50),
///     style: TextStyle(color: Colors.green),
///     textAlign: TextAlign.right,
///     selectable: true,
/// )
/// ```
class MyTextScroll extends StatefulWidget {
  const MyTextScroll(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection = TextDirection.ltr,
    this.numberOfReps,
    this.delayBefore,
    this.pauseBetween,
    this.pauseOnBounce,
    this.velocity = const Velocity(pixelsPerSecond: Offset(80, 0)),
    this.selectable = false,
    this.intervalSpaces,
    this.fadedBorder = false,
    this.fadedBorderWidth = 0.2,
  });

  /// The text string, that would be scrolled.
  /// In case text does fit into allocated space, it wouldn't be scrolled
  /// and would be shown as is.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll('This is the sample text for Flutter MyTextScroll widget.')
  /// ```
  final String text;

  /// Provides [TextAlign] alignment if text string is not long enough to be scrolled.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Short string',
  ///   textAlign: TextAlign.right,
  /// )
  /// ```
  final TextAlign? textAlign;

  /// Provides [TextDirection] - a direction in which text flows.
  /// Default is [TextDirection.ltr].
  /// Default scrolling direction would be opposite to [textDirection],
  /// e.g. for [TextDirection.rtl] scrolling would be from left to right
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Hey! I\'m a RTL text, check me out. Hey! I\'m a RTL text, check me out. Hey! I\'m a RTL text, check me out. ',
  ///   textDirection: TextDirection.rtl,
  /// )
  /// ```
  final TextDirection textDirection;

  /// Allows to apply custom [TextStyle] to [text].
  ///
  /// `null` by default.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Styled text',
  ///   style: TextStyle(
  ///     color: Colors.red,
  ///   ),
  /// )
  /// ```
  final TextStyle? style;

  /// Limits number of scroll animation rounds.
  ///
  /// Default is [infinity].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Limit scroll rounds to 10',
  ///   numberOfReps: 10,
  /// )
  /// ```
  final int? numberOfReps;

  /// Delay before first animation round.
  ///
  /// Default is [Duration.zero].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Start animation after 1 sec delay',
  ///   delayBefore: Duration(seconds: 1),
  /// )
  /// ```
  final Duration? delayBefore;

  /// Determines pause interval between animation rounds.
  ///
  /// Default is [Duration.zero].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Pause animation between rounds',
  ///   mode: TextScrollMode.bouncing,
  ///   pauseBetween: Duration(milliseconds: 300),
  /// )
  /// ```
  final Duration? pauseBetween;

  /// Determines pause interval before changing direction on a bounce.
  ///
  /// Default is [Duration.zero].
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Pause animation when text reaches the end',
  ///   mode: TextScrollMode.bouncing,
  ///   pauseOnBounce: Duration(milliseconds: 300),
  /// )
  /// ```
  final Duration? pauseOnBounce;

  /// Sets one of two different types of scrolling behavior.
  ///
  /// [TextScrollMode.endless] - default, scrolls text in one direction endlessly.
  ///
  /// [TextScrollMode.bouncing] - when [text] string is scrolled to its end,
  /// starts animation to opposite direction.
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Animate text string back and forth',
  ///   mode: TextScrollMode.bouncing,
  /// )

  /// Allows to customize animation speed.
  ///
  /// Default is `Velocity(pixelsPerSecond: Offset(80, 0))`
  ///
  /// ### Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Animate text at 200px per second',
  ///   velocity: Velocity(pixelsPerSecond: Offset(200, 0)),
  /// )
  final Velocity velocity;

  /// Allows users to select provided [text], copy it to clipboard etc.
  ///
  /// Default is `false`.
  ///
  /// Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'Selectable text',
  ///   selectable: true,
  /// )
  /// ```
  final bool selectable;

  /// Adds blank spaces between two nearby text sentences
  /// in case of [TextScrollMode.endless]
  ///
  /// Default is `1`.
  ///
  /// Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'This is the sample text for Flutter MyTextScroll widget. ',
  ///   blankSpaces: 10,
  /// )
  /// ```
  final int? intervalSpaces;

  /// Fades the text out to the left and right edges of the widget.
  /// Default is `false`.
  ///
  /// Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'This is the sample text for Flutter MyTextScroll widget. ',
  ///   fadedBorder: true,
  /// )
  /// ```
  final bool fadedBorder;

  /// Sets width of the faded border.
  /// Default is `0.2`.
  ///
  /// Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///   'This is the sample text for Flutter MyTextScroll widget. ',
  ///   fadedBorder: true,
  ///   fadedBorderWidth: 0.25,
  /// )
  /// ```
  final double? fadedBorderWidth;

  /// Sets which side of the widget should be faded.
  /// Default is [FadeBorderSide.both].
  ///
  /// Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///  'This is the sample text for Flutter MyTextScroll widget. ',
  ///  fadedBorder: true,
  ///  fadeBorderSide: FadeBorderSide.left,
  ///  )

  /// Sets when the fadeBorder should be shown.
  /// Default is [FadeBorderSide.auto].
  ///
  /// Example:
  ///
  /// ```dart
  /// MyTextScroll(
  ///  'This is the sample text for Flutter MyTextScroll widget. ',
  ///  fadedBorder: true,
  ///  fadeBorderVisibility: FadeBorderVisibility.always,
  ///  )

  @override
  State<MyTextScroll> createState() => _TextScrollState();
}

class _TextScrollState extends State<MyTextScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  double _textWidth = 0;
  double _containerWidth = 0;
  bool _needsScrolling = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initAnimation() {
    if (!_needsScrolling) return;

    final double distance = _textWidth - _containerWidth;

    final duration = Duration(
      milliseconds: (distance * 1000 / widget.velocity.pixelsPerSecond.dx.abs())
          .round(),
    );

    _controller.duration = duration;

    _animation = Tween<double>(
      begin: 0,
      end: -distance,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _containerWidth = constraints.maxWidth;

        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          maxLines: 1,
          textDirection: widget.textDirection,
        )..layout();

        _textWidth = textPainter.width;

        _needsScrolling = _textWidth > _containerWidth;

        // if (_needsScrolling && !_controller.isAnimating) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) {
        //     if (mounted) _initAnimation();
        //   });
        // }

        if (!_needsScrolling) {
          return Text(
            widget.text,
            style: widget.style,
            textAlign: widget.textAlign,
          );
        }

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value, 0),
                child: child,
              );
            },
            child: Text(widget.text, style: widget.style),
          ),
        );
      },
    );
  }
}
