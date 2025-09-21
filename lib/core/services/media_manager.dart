import 'package:file_picker/file_picker.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:media_upload/core/helper/media_utils.dart';
import 'package:uuid/uuid.dart';

import '../../db/media_db.dart';
import '../../main.dart';
import '../../models/media_model.dart';

// class MediaManager {
//   static final MediaManager _mediaManager = MediaManager._internal();
//   factory MediaManager() => _mediaManager;
//   MediaManager._internal();
//
//   final MediaDB database = MediaDB();
//
//   final Map<String, CancelToken> _cancelTokens = {};
//
//   Future<void> addMedia(String filePath) async {
//     if (filePath.isEmpty) return;
//     final String mediaId = const Uuid().v4();
//     final MediaModel media = MediaModel(mediaId: mediaId, filePath: filePath);
//     await database.addRecord(media);
//   }
//
//   Future<List<MediaModel>> getAllMedia() async {
//     final records = await database.getAllRecords();
//
//     return records.map((rec) {
//       final data = rec.value;
//       return MediaModel.fromJson(data.cast<String, dynamic>());
//     }).toList();
//   }
//
//   Future<void> deleteMedia(String mediaId) async {
//     await database.deleteRecord(mediaId);
//     _cancelTokens.remove(mediaId);
//   }
//
//   Future<void> processQueue() async {
//     if (!await FlutterForegroundTask.isRunningService) {
//       FlutterForegroundTask.startService(
//         notificationTitle: 'Prabhat',
//         notificationText: 'Prabhat Uploading...',
//         callback: startCallback,
//         notificationButtons: [
//           NotificationButton(id: 'hey', text: 'Hey...'),
//         ],
//       );
//     }
//     final queue = await database.fetchPendingAndFailedMedia();
//     print('Pending tasks------------$queue');
//     queue.map((rec) async {
//       final data = rec.value;
//       final media = MediaModel.fromJson(data.cast<String, dynamic>());
//       FlutterForegroundTask.sendDataToTask({
//         'action': 'upload',
//         'mediaId': media.mediaId,
//         'filePath': media.filePath,
//       });
//       //await uploadToS3(media.mediaId, media.filePath);
//     }).toList();
//     print('1111111111111111');
//   }
//
//   Future<void> uploadToS3(String mediaId, String filePath) async {
//     final fileName = filePath.split('/').last;
//     final fileType = lookupMimeType(filePath) ?? 'application/octet-stream';
//
//     final dio = Dio();
//     final cancelToken = CancelToken();
//     _cancelTokens[mediaId] = cancelToken;
//     try {
//       // Step 1: Get presigned URL + fields from Django backend
//       final presignResponse = await dio.get(
//         "http://192.168.29.44:8000/presigned-url/",
//         queryParameters: {
//           "fileName": fileName,
//           "fileType": fileType,
//         },
//       );
//       print('Response @@@@@@@@@@@@    $presignResponse');
//       if (presignResponse.statusCode == 200) {
//         final urlData = presignResponse.data['presignedPost'];
//         print('URl Data----------- $urlData');
//         final url = urlData['url'];
//         final fields = Map<String, dynamic>.from(urlData['fields']);
//
//         // Step 2: Build multipart form
//         final formData = FormData.fromMap({
//           ...fields,
//           'file': await MultipartFile.fromFile(filePath, filename: fileName),
//         });
//
//         // Step 3: Upload file + fields
//         final uploadResponse = await dio.post(
//           url,
//           data: formData,
//           cancelToken: cancelToken,
//           onSendProgress: (int sent, int total) async {
//             if (total > 0) {
//               final progress = sent / total;
//               await database.updateRecord(mediaId, {
//                 "progress": progress,
//                 "status": "uploading",
//               });
//             }
//           },
//           options: Options(
//             contentType: 'multipart/form-data',
//             followRedirects: false,
//             validateStatus: (status) => status != null && status < 500,
//           ),
//         );
//
//         if (uploadResponse.statusCode == 204) {
//           Map<String, dynamic> value = {
//             "status": "success",
//             "s3Url": url,
//             "isUploadToS3": true,
//             "progress": 1.0,
//           };
//
//           await database.updateRecord(mediaId, value);
//         } else {
//           await database.updateRecord(mediaId, {
//             "status": "failed",
//           });
//         }
//       } else {
//         await database.updateRecord(mediaId, {
//           "status": "failed",
//         });
//       }
//     } catch (e) {
//       if (e is DioException && CancelToken.isCancel(e)) {
//         await database.updateRecord(mediaId, {
//           "status": "paused",
//         });
//       } else {
//         await database.updateRecord(mediaId, {
//           "status": "failed",
//         });
//       }
//     } finally {
//       _cancelTokens.remove(mediaId); // cleanup after completion
//     }
//   }
//
//   void cancelUpload(String mediaId) {
//     if (_cancelTokens.containsKey(mediaId)) {
//       _cancelTokens[mediaId]!.cancel("Cancelled by user");
//       _cancelTokens.remove(mediaId);
//     }
//   }
//
//   Future<void> pickFiles() async {
//     if (!await FlutterForegroundTask.isRunningService) {
//       await FlutterForegroundTask.startService(
//         notificationTitle: 'Prabhat',
//         notificationText: 'Prabhat Uploading...',
//         callback: startCallback,
//         notificationButtons: [
//           NotificationButton(id: 'hey', text: 'Hey'),
//         ],
//       );
//     }
//     final localFiles = await FilePicker.platform.pickFiles(
//       allowMultiple: true,
//       type: FileType.any,
//     );
//     if (localFiles == null) return;
//     final selection = localFiles.files.take(10);
//
//     for (final file in selection) {
//       if (file.path == null) continue;
//
//       final String mediaId = const Uuid().v4();
//       final MediaModel media =
//           MediaModel(mediaId: mediaId, filePath: file.path!);
//       await database.addRecord(media);
//
//       FlutterForegroundTask.sendDataToTask(
//         {
//           'action': 'upload',
//           'mediaId': mediaId,
//           'filePath': file.path,
//         },
//       );
//     }
//   }
// }

class MediaManager {
  static final MediaManager _mediaManager = MediaManager._internal();
  factory MediaManager() => _mediaManager;
  MediaManager._internal();

  final MediaDB database = MediaDB();

  Future<void> addMedia(String filePath) async {
    if (filePath.isEmpty) return;
    final String mediaId = const Uuid().v4();
    final mediaType = MediaUtils.resolveMediaType(filePath);
    final MediaModel media = MediaModel(
      mediaId: mediaId,
      filePath: filePath,
      mediaType: mediaType,
    );
    await database.addRecord(media);
  }

  Future<void> deleteMedia(String mediaId) async {
    await database.deleteRecord(mediaId);
    // inform BG task to cancel if running
    FlutterForegroundTask.sendDataToTask(
        {'action': 'cancel', 'mediaId': mediaId});
  }

  Future<void> pickFiles() async {
    if (!await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.startService(
        serviceId: 9696,
        notificationTitle: 'Media Upload Service',
        notificationText: 'Waiting for tasks...',
        callback: startCallback,
        notificationButtons: [
          const NotificationButton(id: 'stop', text: 'Stop'),
        ],
      );
      print(
          'FOREGROUND SERVICE STARTED +++++++++++++++++++++++++++++++++++++++++++++');
    }

    final localFiles = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    if (localFiles == null) return;

    final selection = localFiles.files.take(20);

    // Ensure service is running

    // for (final file in selection) {
    //   if (file.path == null) continue;
    //   // Add to DB
    //   final String mediaId = const Uuid().v4();
    //   final mediaType = MediaUtils.resolveMediaType(file.path!);
    //   final media = MediaModel(
    //     mediaId: mediaId,
    //     filePath: file.path!,
    //     mediaType: mediaType,
    //   );
    //   await database.addRecord(media);
    //
    //   // send upload command to background task (TaskHandler)
    //   final payload = {
    //     'action': 'upload',
    //     'mediaId': mediaId,
    //     'filePath': file.path!,
    //   };
    //   // Can send Map directly
    //   FlutterForegroundTask.sendDataToTask(payload);
    // }

    // 1) Collect all media into a list

    final List<MediaModel> mediaBatch = [];
    final List<Map<String, dynamic>> uploadPayloads = [];

    for (final file in selection) {
      if (file.path == null) continue;

      final String mediaId = const Uuid().v4();
      final mediaType = MediaUtils.resolveMediaType(file.path!);
      final String s3Url = MediaUtils.toS3Url(file.path!);

      final media = MediaModel(
        mediaId: mediaId,
        filePath: file.path!,
        mediaType: mediaType,
        s3Url: s3Url,
      );

      mediaBatch.add(media);

      // Store payload for later
      uploadPayloads.add({
        'action': 'upload',
        'mediaId': mediaId,
        'filePath': file.path!,
      });
    }

    await database.addBulkRecords(mediaBatch);

    // final all = await database.getAllRecords();
    // print(
    //     '++++++++++++++++++++++++++++ALL MEDIA++++++++++++++++++++++++++++++++++');
    // print('TOTAL MEDIA ------------ ${all.length}');
    // print(all);

    for (final payload in uploadPayloads) {
      FlutterForegroundTask.sendDataToTask(payload);
    }

    // print('SEND DATA TO TASK +++++++++++++++++++++++++ UPLOADED');
  }

  Future<List<MediaModel>> getAllMedia() async {
    final records = await database.getAllRecords();
    return records.map((rec) {
      final data = rec.value;
      return MediaModel.fromJson(data.cast<String, dynamic>());
    }).toList();
  }

  Future<void> cancelUpload(String mediaId) async {
    await database.updateRecord(mediaId, {'status': 'paused'});
    FlutterForegroundTask.sendDataToTask(
        {'action': 'cancel', 'mediaId': mediaId});
  }

  Future<void> uploadToS3(String mediaId, String filePath) async {
    // keep this for manual foreground uploads if needed; prefer letting background handler do uploads
    // For now we'll just forward the job to the background task:
    FlutterForegroundTask.sendDataToTask(
        {'action': 'upload', 'mediaId': mediaId, 'filePath': filePath});
  }
}
