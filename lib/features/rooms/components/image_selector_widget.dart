import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ImageSelectorWidget extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color borderColor;
  final IconData placeholderIcon;
  final double placeholderIconSize;
  final Color placeholderIconColor;
  final Color placeholderBackgroundColor;
  final Widget? customPlaceholder;
  final BoxFit imageFit;

  const ImageSelectorWidget({
    super.key,
    this.imagePath,
    required this.onTap,
    this.width = 140,
    this.height = 150,
    this.borderRadius = 20,
    this.backgroundColor = const Color(
      0x26FFFFFF,
    ), // Colors.white.withOpacity(0.15)
    this.borderColor = const Color(0x33FFFFFF), // Colors.white.withOpacity(0.2)
    this.placeholderIcon = HugeIcons.strokeRoundedImageAdd01,
    this.placeholderIconSize = 32,
    this.placeholderIconColor = Colors.white,
    this.placeholderBackgroundColor = const Color(
      0x4DFFFFFF,
    ), // Colors.white.withOpacity(0.3)
    this.customPlaceholder,
    this.imageFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _buildImage(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildImage() {
    // Check if the imagePath is a URL or a local file path
    if (imagePath!.startsWith('http://') || imagePath!.startsWith('https://')) {
      // Network image
      return Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: imageFit,
        loadingBuilder: (context, _, url) => _buildLoadingPlaceholder(),
        errorBuilder: (context, url, error) => _buildPlaceholder(),
      );
    } else {
      // Local file image
      return Image.file(
        File(imagePath!),
        width: width,
        height: height,
        fit: imageFit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: placeholderBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (customPlaceholder != null) {
      return customPlaceholder!;
    }

    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: placeholderBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          placeholderIcon,
          color: placeholderIconColor,
          size: placeholderIconSize,
        ),
      ),
    );
  }
}
