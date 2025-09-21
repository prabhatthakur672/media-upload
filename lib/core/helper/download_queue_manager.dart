import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pool/pool.dart';

class DownloadQueueManager {
  final Dio _dio = Dio();
  final Pool _pool;
  final String _baseDir;

  DownloadQueueManager._(this._baseDir, this._pool);

  /// Factory constructor to initialize with concurrency limit
  static Future<DownloadQueueManager> create({int maxConcurrent = 3}) async {
    final dir =
        await getTemporaryDirectory(); // or getApplicationDocumentsDirectory()
    return DownloadQueueManager._(
      dir.path,
      Pool(maxConcurrent),
    );
  }

  /// Adds a download task to queue
  Future<String?> downloadFile(String s3Url, String fileName) async {
    final file = File("$_baseDir/$fileName");

    if (await file.exists()) {
      return file.path; // already cached
    }

    return _pool.withResource(() async {
      try {
        await _dio.download(
          s3Url,
          file.path,
          options: Options(responseType: ResponseType.bytes),
        );
        return file.path;
      } catch (e) {
        print("Download failed for $fileName: $e");
        return null;
      }
    });
  }

  Future<bool> isValidS3Url(String s3Url) async {
    try {
      final response = await _dio.head(s3Url);

      if (response.statusCode == 200) {
        final contentLength = response.headers.value('content-length');
        final contentType = response.headers.value('content-type');

        final length = int.tryParse(contentLength ?? '0') ?? 0;

        // must not be empty and should be media type
        if (length > 0 &&
            contentType != null &&
            (contentType.startsWith("image/") ||
                contentType.startsWith("video/"))) {
          return true;
        }
      }
    } catch (e) {
      print("HEAD check failed, fallback to Range request: $e");

      // fallback to small GET request with Range
      try {
        final response = await _dio.get(
          s3Url,
          options: Options(
            headers: {"Range": "bytes=0-1"}, // fetch first 2 bytes
            responseType: ResponseType.bytes,
          ),
        );
        return response.statusCode == 206 && response.data != null;
      } catch (e) {
        print("Fallback check failed: $e");
      }
    }
    return false;
  }
}

// class DownloadQueueManager {
//   final Dio _dio = Dio();
//   final Pool _pool;
//   final String _baseDir;
//
//   DownloadQueueManager._(this._baseDir, this._pool);
//
//   static Future<DownloadQueueManager> create({int maxConcurrent = 3}) async {
//     final dir =
//         await getApplicationDocumentsDirectory(); // ✅ persistent storage
//     return DownloadQueueManager._(
//       '${dir.path}/media_cache',
//       Pool(maxConcurrent),
//     );
//   }
//
//   Future<String?> downloadFile(String s3Url, String fileName) async {
//     final file = File("$_baseDir/$fileName");
//
//     if (await file.exists()) return file.path;
//
//     return _pool.withResource(() async {
//       try {
//         await _dio.download(s3Url, file.path,
//             options: Options(responseType: ResponseType.bytes));
//         return file.path;
//       } catch (e) {
//         print("Download failed for $fileName: $e");
//         return null;
//       }
//     });
//   }
//
//   /// ✅ Delete old or oversized cache
//   Future<void> cleanupCache(
//       {int maxSizeMB = 500, Duration maxAge = const Duration(hours: 5)}) async {
//     final dir = Directory(_baseDir);
//     if (!await dir.exists()) return;
//
//     final files = dir.listSync().whereType<File>().toList();
//
//     // Delete old files
//     for (final file in files) {
//       final stat = await file.stat();
//       final age = DateTime.now().difference(stat.modified);
//       if (age > maxAge) {
//         await file.delete();
//       }
//     }
//
//     // Delete if total size > maxSizeMB
//     int totalSize = files.fold(0, (sum, file) => sum + file.lengthSync());
//     if (totalSize > maxSizeMB * 1024 * 1024) {
//       files.sort((a, b) => a
//           .statSync()
//           .modified
//           .compareTo(b.statSync().modified)); // oldest first
//       for (final file in files) {
//         await file.delete();
//         totalSize -= file.lengthSync();
//         if (totalSize <= maxSizeMB * 1024 * 1024) break;
//       }
//     }
//   }
// }
