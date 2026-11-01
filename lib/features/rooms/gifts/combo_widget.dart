// import 'package:flutter/material.dart';
// import 'package:tom_chat/core/theme/color.dart';

// class ComboWidget extends StatefulWidget {
//   final Duration duration;
//   final VoidCallback? onPress;
//   final int? initialComboCount;
//   final bool smallWidget;
//   final double? size;

//   const ComboWidget({
//     super.key,
//     this.duration = const Duration(seconds: 2),
//     this.onPress,
//     this.smallWidget = false,
//     this.initialComboCount,
//     this.size,
//   });

//   @override
//   State<ComboWidget> createState() => _ComboWidgetState();
// }

// class _ComboWidgetState extends State<ComboWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _clickAnimationController;
//   late AnimationController _waveAnimationController;
//   late Animation<double> _progressAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _clickScaleAnimation;
//   late Animation<double> _waveAnimation;
//   int _comboCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     _comboCount = widget.initialComboCount ?? 1;
//     _animationController = AnimationController(
//       duration: widget.duration,
//       vsync: this,
//     );

//     _clickAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );

//     _waveAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _progressAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.linear,
//     ));

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.elasticOut,
//     ));

//     _clickScaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.9,
//     ).animate(CurvedAnimation(
//       parent: _clickAnimationController,
//       curve: Curves.easeInOut,
//     ));

//     _waveAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _waveAnimationController,
//       curve: Curves.easeOut,
//     ));

//     _animationController.forward();
//   }

//   void _handleTap() {
//     _clickAnimationController.forward().then((_) {
//       _clickAnimationController.reverse();
//     });

//     // Start wave animation
//     _waveAnimationController.reset();
//     _waveAnimationController.forward();

//     // Increment combo count
//     setState(() {
//       _comboCount++;
//     });

//     // Restart the progress animation
//     _animationController.reset();
//     _animationController.forward();

//     if (widget.onPress != null) {
//       widget.onPress!();
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _clickAnimationController.dispose();
//     _waveAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final double size = widget.size ?? 65.0;

//     String number = '';
//     if (_comboCount == 5) {
//       number = 'Good!';
//     } else if (_comboCount == 10) {
//       number = 'Great!';
//     } else if (_comboCount == 15) {
//       number = 'Awesome!';
//     } else if (_comboCount == 30) {
//       number = 'Incredible!';
//     } else {
//       number = 'x$_comboCount';
//     }

//     final double textSize = size * 0.22;
//     final double badgeTextSize = size * 0.3;

//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _animationController,
//         _clickAnimationController,
//         _waveAnimationController
//       ]),
//       builder: (context, child) {
//         return Transform.scale(
//           scale: _scaleAnimation.value * _clickScaleAnimation.value,
//           child: GestureDetector(
//             onTap: _handleTap,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Stack(
//                   clipBehavior: Clip.none,
//                   alignment: Alignment.center,
//                   children: [
//                     SizedBox(
//                       width: size,
//                       height: size,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           // Animated circular progress indicator
//                           SizedBox(
//                             width: size,
//                             height: size,
//                             child: CircularProgressIndicator(
//                               value: _progressAnimation.value,
//                               strokeWidth: size * 0.05,
//                               backgroundColor:
//                                   theme.colorScheme.primary.withOpacity(0.3),
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 theme.colorScheme.primary,
//                               ),
//                             ),
//                           ),
//                           // Inner circle with combo text
//                           Container(
//                             width: size - 4,
//                             height: size - 4,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: RadialGradient(
//                                 colors: [
//                                   Colors.orange,
//                                   AppColors.primaryDark,
//                                 ],
//                                 stops: const [0.0, 1.0],
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                               "Combo",
//                                 style: theme.textTheme.titleLarge?.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w800,
//                                   fontStyle: FontStyle.italic,
//                                   fontSize: textSize,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     // Wave effect under the circle
//                     Transform.scale(
//                       scale: _waveAnimation.value * 1.5,
//                       child: Container(
//                         width: size + 10,
//                         height: size + 15,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: theme.colorScheme.primary.withOpacity(
//                             0.5 * (1.0 - _waveAnimation.value),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Second wave effect
//                     Transform.scale(
//                       scale: _waveAnimation.value * 2.0,
//                       child: Container(
//                         width: size + 20,
//                         height: size + 20,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: theme.colorScheme.primary.withOpacity(
//                             0.3 * (1.0 - _waveAnimation.value),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Combo counter popup label
//                     Positioned(
//                       top: -size * 0.4,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: size * 0.2,
//                           vertical: size * 0.08,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.red,
//                           borderRadius: BorderRadius.circular(100),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.3),
//                               blurRadius: 3,
//                               offset: const Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Text(
//                           number,
//                           style: theme.textTheme.bodyMedium?.copyWith(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w800,
//                             fontStyle: FontStyle.italic,
//                             fontSize: badgeTextSize,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
