import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaUtils {
  static final _dio = Dio();
  static const String _baseUrl =
      'https://evento-media.s3.amazonaws.com/uploads/';

  static String toS3Url(String filePath) {
    final String fileName = filePath.split('/').last;
    return '$_baseUrl$fileName';
  }

  static String resolveMediaType(String mimeOrPath) {
    final ext = mimeOrPath.split('.').last.toLowerCase();

    // Images
    const imageExt = ['jpg', 'jpeg', 'png', 'svg', 'webp'];
    if (imageExt.contains(ext)) return 'image';

    // Videos
    const videoExt = ['mp4', 'mov', 'avi', 'mkv'];
    if (videoExt.contains(ext)) return 'video';

    // Audio
    const audioExt = ['mp3', 'wav', 'aac', 'ogg', 'flac'];
    if (audioExt.contains(ext)) return 'audio';

    // Documents
    const docExt = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'];
    if (docExt.contains(ext)) return 'document';

    // Fallback
    return 'unknown';
  }

  // static Future<String?> cacheMedia(String s3Url, String fileName) async {
  //   try {
  //     final dir = await getApplicationDocumentsDirectory();
  //     final file = File("${dir.path}/$fileName");
  //
  //     if (await file.exists()) {
  //       return file.path; // already cached
  //     }
  //
  //     await _dio.download(s3Url, file.path);
  //
  //     return file.path;
  //   } catch (e) {
  //     print("Error caching media: $e");
  //     return null;
  //   }
  // }

  // static Future<Uint8List?> generateVideoThumb(String url) {
  //   return VideoThumbnail.thumbnailData(
  //     video: url,
  //     imageFormat: ImageFormat.PNG,
  //     maxWidth: 200,
  //     quality: 25,
  //   );
  // }

  // static Future<String?> generateVideoThumb(String url) async {
  //   final tempDir = await getTemporaryDirectory();
  //   final thumbPath = await VideoThumbnail.thumbnailFile(
  //     video: url,
  //     thumbnailPath: tempDir.path, // store in app's cache dir
  //     imageFormat: ImageFormat.PNG,
  //     maxWidth: 200,
  //     quality: 25,
  //   );
  //   return thumbPath; // path to cached thumbnail
  // }

  static Future<String?> generateVideoThumb(String url) async {
    final file = File(url);

    // ✅ 1. Check file exists and is not empty
    if (!(await file.exists())) {
      print("⚠️ Video file not found: $url");
      return null;
    }
    if (await file.length() == 0) {
      print("⚠️ Video file is empty: $url");
      return null;
    }

    final tempDir = await getTemporaryDirectory();

    // Helper method to attempt thumbnail at a given timestamp
    Future<String?> _tryGenerate(int timeMs) async {
      try {
        return await VideoThumbnail.thumbnailFile(
          video: url,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.PNG,
          maxWidth: 200,
          quality: 25,
          timeMs: timeMs, // pick frame at given ms
        );
      } catch (e) {
        print("❌ Thumbnail generation failed at ${timeMs}ms: $e");
        return null;
      }
    }

    // ✅ 2. Try first at 1 second, then fallback
    String? thumbPath = await _tryGenerate(1000);

    if (thumbPath == null) {
      // retry at 3s
      thumbPath = await _tryGenerate(3000);
    }
    if (thumbPath == null) {
      // last resort at 5s
      thumbPath = await _tryGenerate(5000);
    }

    // ✅ 3. Log result
    if (thumbPath == null) {
      print("⚠️ Could not generate thumbnail for: $url");
    } else {
      print("✅ Thumbnail generated at $thumbPath");
    }

    return thumbPath;
  }

  // static Future<String> getVideoDuration(String url) async {
  //   try {
  //     final controller = VideoPlayerController.networkUrl(Uri.parse(url));
  //     await controller.initialize();
  //     final duration = controller.value.duration;
  //     await controller.dispose();
  //
  //     final minutes = duration.inMinutes;
  //     final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  //
  //     return "$minutes:$seconds";
  //   } catch (e) {
  //     print("Error fetching video duration: $e");
  //     return "--:--";
  //   }
  // }

  static final _videoInfo = FlutterVideoInfo();

  static Future<String> getVideoDuration(String pathOrUrl) async {
    try {
      final info = await _videoInfo.getVideoInfo(pathOrUrl);
      if (info == null || info.duration == null) return "--:--";

      final duration = Duration(milliseconds: info.duration!.toInt());
      final minutes = duration.inMinutes;
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

      return "$minutes:$seconds";
    } catch (e) {
      print("Error fetching video duration: $e");
      return "--:--";
    }
  }
}
