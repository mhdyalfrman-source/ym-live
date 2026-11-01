// app_image.dart  (الملف الجديد المدموج)

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/svga_viewer.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

enum ImageType { profile, videoCover, store, chat, general }

///
/// ---------------  Cache System ---------------
///
class AppImageCache {
  AppImageCache._();

  static const _kProfileKey = 'app_profile_images_v1';
  static const _kVideoKey = 'app_video_images_v1';
  static const _kStoreKey = 'app_store_images_v1';
  static const _kChatKey = 'app_chat_images_v1';
  static const _kGeneralKey = 'app_general_images_v1';

  static final Map<ImageType, CacheManager> _instances = {};

  static CacheManager of(ImageType type) => _instances[type] ??= switch (type) {
    ImageType.profile => CacheManager(
      Config(
        _kProfileKey,
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 600,
      ),
    ),
    ImageType.videoCover => CacheManager(
      Config(
        _kVideoKey,
        stalePeriod: const Duration(days: 7),
        maxNrOfCacheObjects: 2500,
      ),
    ),
    ImageType.store => CacheManager(
      Config(
        _kStoreKey,
        stalePeriod: const Duration(days: 60),
        maxNrOfCacheObjects: 200,
      ),
    ),
    ImageType.chat => CacheManager(
      Config(
        _kChatKey,
        stalePeriod: const Duration(days: 60),
        maxNrOfCacheObjects: 200,
      ),
    ),
    ImageType.general => CacheManager(
      Config(
        _kGeneralKey,
        stalePeriod: const Duration(days: 100),
        maxNrOfCacheObjects: 200,
      ),
    ),
  };

  static Future<void> clear(ImageType type) => of(type).emptyCache();
  static Future<void> clearAll() async {
    for (final t in ImageType.values) {
      await of(t).emptyCache();
    }
  }
}

class CachedImage extends StatelessWidget {
  const CachedImage(
    this.src, {
    super.key,
    required this.type,
    this.width,
    this.height,
    this.fit,
    this.cacheWidth,
    this.cacheHeight,
    this.cacheKey,
    this.progressIndicatorBuilder,
    this.errorWidget = const Icon(Icons.broken_image, color: Colors.grey),
  });

  final String src;
  final ImageType type;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final int? cacheWidth;
  final int? cacheHeight;
  final String? cacheKey;
  final Widget Function(BuildContext, String, DownloadProgress)?
  progressIndicatorBuilder;
  final Widget errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: src,
      cacheManager: AppImageCache.of(type),
      cacheKey: cacheKey,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,

      errorWidget: (ctx, url, error) => errorWidget,

      progressIndicatorBuilder:
          progressIndicatorBuilder ??
          (ctx, url, progress) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryDark,
                value: progress.progress,
              ),
            ); // بسيط
          },

      imageBuilder: (context, provider) {
        return Image(image: provider, width: width, height: height, fit: fit);
      },
    );
  }
}

///
/// ---------------  AppImage (النهائي) ---------------
///
class AppImage extends StatelessWidget {
  final ImageModel? image;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget errorWidget;
  final Widget Function(BuildContext, String, DownloadProgress)?
  progressIndicatorBuilder;

  const AppImage({
    super.key,
    required this.image,
    this.width,
    this.height,
    this.progressIndicatorBuilder,
    this.fit = BoxFit.contain,
    this.errorWidget = const Icon(Icons.broken_image, color: Colors.grey),
  });

  @override
  Widget build(BuildContext context) {
    final opacity = image?.opacity ?? 1.0;
    final bgColor = _parseColor(image?.bgColor);

    Widget child;

    if ((image?.network ?? "") != "") {
      if (image!.network!.endsWith(".svga")) {
        child = SvgaViwer(
          networkSvga: image!.network!,
          width: width,
          height: height,
          fit: fit,
        );
      } else {
        child = CachedImage(
          image?.network ?? '',
          type: ImageType.profile,
          width: width,
          height: height,
          fit: fit,
          progressIndicatorBuilder: progressIndicatorBuilder,
          errorWidget: errorWidget,
        );
      }
    } else if ((image?.asset ?? "") != "") {
      child = Image.asset(
        image?.asset ?? '',
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.red),
      );
    } else if ((image?.txt ?? "") != "") {
      child = Center(
        child: Text(
          image?.txt ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else {
      child = const SizedBox();
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: height,
        color: bgColor,
        child: child,
      ),
    );
  }

  Color? _parseColor(String? hexColor) {
    if (hexColor == null) return null;
    try {
      return Color(int.parse(hexColor.replaceAll('#', '0xff')));
    } catch (_) {
      return null;
    }
  }
}
