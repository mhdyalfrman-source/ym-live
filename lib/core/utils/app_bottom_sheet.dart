import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    this.title,
    required this.child,
    this.showCloseButton = true,
    this.showHandle = true,
    this.onClose,
    this.headerHeight = 64.0,
    this.borderRadius = 32.0,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.titleStyle,
    this.handleColor,
    this.closeButtonColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.maxHeight,
    this.isScrollable = true,
    this.hideHeader = false,
    super.key,
  });

  /// The title displayed in the header
  final String? title;

  /// The main content of the bottom sheet
  final Widget child;

  /// Whether to show the close button in the header
  final bool showCloseButton;

  /// Whether to show the drag handle at the top
  final bool showHandle;

  /// Callback when close button is tapped
  final VoidCallback? onClose;

  /// Height of the header section
  final double headerHeight;

  /// Border radius for the bottom sheet
  final double borderRadius;

  /// Background color of the bottom sheet
  final Color? backgroundColor;

  /// Background color of the header section
  final Color? headerBackgroundColor;

  /// Text style for the title
  final TextStyle? titleStyle;

  /// Color of the drag handle
  final Color? handleColor;

  /// Color of the close button
  final Color? closeButtonColor;

  /// Padding for the content area
  final EdgeInsetsGeometry padding;

  /// Maximum height of the bottom sheet
  final double? maxHeight;

  /// Whether the content should be scrollable
  final bool isScrollable;

  // hide header
  final bool hideHeader;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveBackgroundColor = backgroundColor ?? theme.cardTheme.color;
    final effectiveHeaderBackgroundColor =
        headerBackgroundColor ??
        Color.lerp(effectiveBackgroundColor, Colors.grey, 0.15);

    return Container(
      constraints: maxHeight != null
          ? BoxConstraints(maxHeight: maxHeight!)
          : const BoxConstraints(),
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      margin: EdgeInsets.only(top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with title and close button
          if (!hideHeader)
            _buildHeader(context, theme, effectiveHeaderBackgroundColor),
          // Content
          Flexible(
            child: isScrollable
                ? SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: padding,
                      child: child,
                    ),
                  )
                : SafeArea(
                    top: false,
                    child: Padding(padding: padding, child: child),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ThemeData theme,
    Color? headerBgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: headerHeight,
      decoration: BoxDecoration(
        color: headerBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Drag handle
              if (showHandle) ...[
                Container(
                  height: 4,
                  width: 32,
                  decoration: BoxDecoration(
                    color:
                        handleColor ??
                        theme.cardTheme.surfaceTintColor?.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Title
              if (title != null)
                Text(
                  title!,
                  style:
                      titleStyle ??
                      Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),

          // Close button
          if (showCloseButton)
            Positioned(
              right: 0,
              child: GestureDetector(
                onTap: onClose ?? () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        backgroundColor ??
                        theme.cardTheme.color?.withOpacity(0.6),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 24,
                    color: closeButtonColor ?? Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Static method to show the bottom sheet
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget child,
    bool showCloseButton = true,
    bool showHandle = true,
    VoidCallback? onClose,
    double headerHeight = 64.0,
    double borderRadius = 32.0,
    Color? backgroundColor,
    Color? headerBackgroundColor,
    TextStyle? titleStyle,
    Color? handleColor,
    Color? closeButtonColor,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16),
    double? maxHeight,
    bool isScrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    Color? barrierColor,
    bool useSafeArea = true,
    bool hideHeader = false,
  }) async {
    return await Get.bottomSheet<T>(
      AppBottomSheet(
        title: title,
        showCloseButton: showCloseButton,
        showHandle: showHandle,
        onClose: onClose,
        headerHeight: headerHeight,
        borderRadius: borderRadius,
        backgroundColor: backgroundColor,
        headerBackgroundColor: headerBackgroundColor,
        titleStyle: titleStyle,
        handleColor: handleColor,
        closeButtonColor: closeButtonColor,
        padding: padding,
        maxHeight: maxHeight,
        isScrollable: isScrollable,
        hideHeader: hideHeader,
        child: child,
      ),
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: barrierColor,
    );
  }
}
