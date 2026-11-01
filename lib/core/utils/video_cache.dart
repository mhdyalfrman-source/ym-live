import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoCache {
  static const key = "reelVideoCache";

  static final CacheManager instance = CacheManager(
    Config(key, stalePeriod: const Duration(days: 7), maxNrOfCacheObjects: 100),
  );

  static Future<File?> getFile(String url) async {
    try {
      final file = await instance.getSingleFile(url);
      return file;
    } catch (_) {
      return null;
    }
  }

  static Stream<double> downloadWithProgress(String url) async* {
    final stream = DefaultCacheManager().getFileStream(url, withProgress: true);

    await for (var event in stream) {
      if (event is DownloadProgress) {
        if (event.totalSize != null) {
          yield event.downloaded / event.totalSize!;
        }
      }

      if (event is FileInfo) {
        yield 1.0;
      }
    }
  }

  static Future<File?> getFileOnly(String url) async {
    final fileInfo = await instance.getFileFromCache(url);
    if (fileInfo != null) {
      return fileInfo.file;
    }
    return null;
  }
}
