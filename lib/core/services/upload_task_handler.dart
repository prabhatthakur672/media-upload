import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:media_upload/db/media_db.dart';
import 'package:mime/mime.dart';

// class UploadTaskHandler extends TaskHandler {
//   final MediaDB db = MediaDB();
//   final Dio _dio = Dio();
//   final Map<String, CancelToken> _cancelTokens = {};
//
//   @override
//   Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
//     print('TASKSKSKS $starter');
//     print('OnStart started --------------------------- OnStart started');
//   }
//
//   @override
//   void onReceiveData(Object data) {
//     try {
//       Map payload;
//       if (data is String) {
//         payload = jsonDecode(data) as Map;
//       } else if (data is Map) {
//         payload = Map.from(data);
//       } else {
//         return;
//       }
//       _handelUpload(payload['mediaId'], payload['filePath']);
//     } catch (e) {
//       print('Some Uploading Error in onReceiveData --------- $e');
//     }
//   }
//
//   Future<void> _handelUpload(String mediaId, String filePath) async {
//     final fileName = filePath.split('/').last;
//     final fileType = lookupMimeType(filePath) ?? 'application/octet-stream';
//     final cancelToken = CancelToken();
//     _cancelTokens[mediaId] = cancelToken;
//
//     await FlutterForegroundTask.saveData(
//       key: 'media_$mediaId',
//       value: {
//         'mediaId': mediaId,
//         'filePath': filePath,
//         'status': 'uploading',
//         'progress': 0.0,
//       },
//     );
//
//     FlutterForegroundTask.updateService(
//       notificationTitle: 'File Uploading',
//       notificationText: 'Uploading...$fileName',
//       notificationButtons: [
//         NotificationButton(id: 'kya', text: 'kya chal rha'),
//       ],
//       callback: () {
//         print('Notification Par click Hua h++++++++++++++++++++++++++++++++++');
//       },
//     );
//
//     try {
//       // 1) Request presigned fields from your backend
//       // Replace endpoint with your backend
//       final presign = await _dio.get(
//         'http://192.168.29.44:8000/presigned-url/',
//         queryParameters: {'fileName': fileName, 'fileType': fileType},
//         // options: Options(
//         //     receiveTimeout: Duration(milliseconds: 10000),
//         //     sendTimeout: Duration(milliseconds: 10000)),
//       );
//
//       if (presign.statusCode == 200 && presign.data != null) {
//         final urlData = presign.data['presignedPost'];
//         final targetUrl = urlData['url'] as String;
//         final fields = Map<String, dynamic>.from(urlData['fields'] as Map);
//
//         final formDataMap = <String, dynamic>{...fields};
//         formDataMap['file'] =
//             await MultipartFile.fromFile(filePath, filename: fileName);
//
//         final formData = FormData.fromMap(formDataMap);
//         // 2) Perform the actual multipart upload to S3 (or provider)
//
//         final resp = await _dio.post(
//           targetUrl,
//           data: formData,
//           cancelToken: cancelToken,
//           onSendProgress: (sent, total) async {
//             final progress = (total > 0) ? (sent / total) : 0.0;
//
//             //print('PROGRESS ---------------------------  $progress');
//             await db.updateRecord(mediaId, {
//               'status': 'uploading',
//               'progress': progress,
//             });
//             // persist small state so UI can sync after restart
//             await FlutterForegroundTask.saveData(
//               key: 'media_$mediaId',
//               value: {
//                 'mediaId': mediaId,
//                 'filePath': filePath,
//                 'status': 'uploading',
//                 'progress': progress,
//               },
//             );
//
//             // send real-time update to main isolate (if alive)
//             FlutterForegroundTask.sendDataToMain({
//               'mediaId': mediaId,
//               'status': 'uploading',
//               'progress': progress,
//             });
//
//             // update notification
//             FlutterForegroundTask.updateService(
//               notificationTitle: 'Uploading $fileName',
//               notificationText: '${(progress * 100).toStringAsFixed(0)}%',
//             );
//           },
//           options: Options(
//             contentType: 'multipart/form-data',
//             followRedirects: false,
//             validateStatus: (s) => s != null && s < 500,
//           ),
//         );
//
//         // S3 returns 204 on success for POST upload
//         if (resp.statusCode == 204 ||
//             resp.statusCode == 201 ||
//             resp.statusCode == 200) {
//           String s3Url = "${targetUrl}uploads/$fileName";
//
//           await db.updateRecord(mediaId, {
//             'status': 'success',
//             'progress': 1.0,
//             'isUploadToS3': true,
//             's3Url': s3Url,
//           });
//
//           await FlutterForegroundTask.saveData(
//             key: 'media_$mediaId',
//             value: {
//               'mediaId': mediaId,
//               'filePath': filePath,
//               'status': 'success',
//               'progress': 1.0,
//               's3Url': s3Url,
//               'isUploadToS3': true,
//             },
//           );
//
//           // final v = await FlutterForegroundTask.getData(key: 'media_$mediaId');
//           // print('AFTER saveData: media_$mediaId -> $v');
//           FlutterForegroundTask.sendDataToMain({
//             'mediaId': mediaId,
//             'status': 'success',
//             'progress': 1.0,
//             's3Url': s3Url,
//             'isUploadToS3': true,
//           });
//
//           FlutterForegroundTask.updateService(
//             notificationTitle: 'Upload complete',
//             notificationText: fileName,
//           );
//         } else {
//           await FlutterForegroundTask.saveData(
//             key: 'media_$mediaId',
//             value: {
//               'mediaId': mediaId,
//               'filePath': filePath,
//               'status': 'failed',
//               'progress': 0.0,
//               'code': resp.statusCode,
//             },
//           );
//
//           FlutterForegroundTask.updateService(
//             notificationTitle: 'Upload failed',
//             notificationText: fileName,
//           );
//
//           FlutterForegroundTask.sendDataToMain({
//             'mediaId': mediaId,
//             'status': 'failed',
//             'code': resp.statusCode,
//           });
//         }
//       } else {
//         await FlutterForegroundTask.saveData(
//           key: 'media_$mediaId',
//           value: {
//             'mediaId': mediaId,
//             'filePath': filePath,
//             'status': 'failed',
//             'progress': 0.0,
//             'message': 'presign_failed',
//           },
//         );
//         FlutterForegroundTask.sendDataToMain({
//           'mediaId': mediaId,
//           'status': 'failed',
//           'message': 'presign_failed',
//         });
//       }
//     } catch (e) {
//       final isCancel = (e is DioException && CancelToken.isCancel(e));
//       await FlutterForegroundTask.saveData(
//         key: 'media_$mediaId',
//         value: {
//           'mediaId': mediaId,
//           'filePath': filePath,
//           'status': isCancel ? 'paused' : 'failed',
//           'progress': 0.0,
//           'message': e.toString(),
//         },
//       );
//
//       FlutterForegroundTask.sendDataToMain({
//         'mediaId': mediaId,
//         'status': isCancel ? 'paused' : 'failed',
//         'message': e.toString(),
//       });
//
//       FlutterForegroundTask.updateService(
//         notificationTitle: isCancel ? 'Upload paused' : 'Upload error',
//         notificationText: fileName,
//       );
//     } finally {
//       _cancelTokens.remove(mediaId);
//     }
//   }
//
//   @override
//   Future<void> onDestroy(DateTime timestamp, bool isTimeout) {
//     // TODO: implement onDestroy
//     print('OnDestroy @@@@@@@@@@@@@@@@@@@@@@@@@@@  OnDestroy');
//     throw UnimplementedError();
//   }
//
//   @override
//   void onRepeatEvent(DateTime timestamp) {
//     //print('OnRepeat &&&&&&&&&&&&&  OnRepeat');
//     // TODO: implement onRepeatEvent
//   }
// }

class UploadTaskHandler extends TaskHandler {
  final MediaDB database = MediaDB();
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};
  final Set<String> _inProgress = {};

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // No `starter.sendPort` in v9
    // Resume persisted tasks
    try {
      final all = await FlutterForegroundTask.getAllData();
      print('TASKHANDLER ====== ALL PLUGIN STORAGE AT END: $all');
      for (final entry in all.entries) {
        print(
            'ON START @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
        final key = entry.key;
        if (!key.startsWith('media_')) continue;
        final value = entry.value;

        if (value is Map) {
          final mediaId = value['mediaId']?.toString();
          final path = value['filePath']?.toString();
          final status = value['status']?.toString() ?? 'pending';
          if (mediaId != null &&
              path != null &&
              status != 'success' &&
              !_inProgress.contains(mediaId)) {
            _handleUpload(mediaId, path);
          }
        } else if (value is String) {
          try {
            final Map parsed = jsonDecode(value);
            final mediaId = parsed['mediaId']?.toString();
            final path = parsed['filePath']?.toString();
            final status = parsed['status']?.toString() ?? 'pending';
            if (mediaId != null &&
                path != null &&
                status != 'success' &&
                !_inProgress.contains(mediaId)) {
              _handleUpload(mediaId, path);
            }
          } catch (_) {}
        }
      }
    } catch (e) {
      // ignore errors
    }

    // Update notification to show service is running
    FlutterForegroundTask.updateService(
      notificationTitle: 'Upload service running',
      notificationText: 'Waiting for upload tasks...',
    );
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    // Update local sendPort reference if changed
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    print(
        'Service Destroyed =========================================================');
    // cancel ongoing uploads gracefully
    for (final token in _cancelTokens.values) {
      try {
        token.cancel('Service destroyed');
      } catch (_) {}
    }
    _cancelTokens.clear();
    _inProgress.clear();
  }

  @override
  void onReceiveData(Object data) {
    // Data can be Map or JSON string
    try {
      Map payload;
      if (data is String) {
        payload = jsonDecode(data) as Map;
      } else if (data is Map) {
        payload = Map.from(data);
      } else {
        return;
      }

      final action = payload['action']?.toString();
      if (action == 'upload') {
        final mediaId = payload['mediaId']?.toString();
        final filePath = payload['filePath']?.toString();
        if (mediaId != null &&
            filePath != null &&
            !_inProgress.contains(mediaId)) {
          _handleUpload(mediaId, filePath);
        }
      } else if (action == 'cancel') {
        final mediaId = payload['mediaId']?.toString();
        if (mediaId != null && _cancelTokens.containsKey(mediaId)) {
          _cancelTokens[mediaId]!.cancel('Cancelled by main');
          _cancelTokens.remove(mediaId);
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _handleUpload(String mediaId, String filePath) async {
    if (_inProgress.contains(mediaId)) return;
    _inProgress.add(mediaId);

    // Persist initial state in plugin storage so we can resume after restarts
    await FlutterForegroundTask.saveData(
      key: 'media_$mediaId',
      value: {
        'mediaId': mediaId,
        'filePath': filePath,
        'status': 'uploading',
        'progress': 0.0,
      },
    );

    // Update notification
    FlutterForegroundTask.updateService(
      notificationTitle: 'Uploading',
      notificationText: filePath.split('/').last,
    );

    final file = File(filePath);
    if (!file.existsSync()) {
      await FlutterForegroundTask.saveData(
        key: 'media_$mediaId',
        value: {
          'mediaId': mediaId,
          'filePath': filePath,
          'status': 'failed',
          'progress': 0.0,
          'message': 'file_not_found',
        },
      );
      FlutterForegroundTask.sendDataToMain({
        'mediaId': mediaId,
        'status': 'failed',
        'filePath': filePath,
        'message': 'file_not_found',
      });
      _inProgress.remove(mediaId);
      return;
    }

    final fileName = filePath.split('/').last;
    final fileType = lookupMimeType(filePath) ?? 'application/octet-stream';
    final cancelToken = CancelToken();
    _cancelTokens[mediaId] = cancelToken;

    try {
      // 1) Request presigned fields from your backend
      // Replace endpoint with your backend
      final presign = await _dio.get(
        'http://192.168.29.44:8000/presigned-url/',
        queryParameters: {'fileName': fileName, 'fileType': fileType},
        options: Options(
          receiveTimeout: Duration(milliseconds: 10000),
          sendTimeout: Duration(milliseconds: 10000),
        ),
      );

      if (presign.statusCode == 200 && presign.data != null) {
        final urlData = presign.data['presignedPost'];
        final targetUrl = urlData['url'] as String;
        final fields = Map<String, dynamic>.from(urlData['fields'] as Map);
        String s3Url = "${targetUrl}uploads/$fileName";
        final formDataMap = <String, dynamic>{...fields};
        formDataMap['file'] =
            await MultipartFile.fromFile(filePath, filename: fileName);

        final formData = FormData.fromMap(formDataMap);

        // 2) Perform the actual multipart upload to S3 (or provider)
        final resp = await _dio.post(
          targetUrl,
          data: formData,
          cancelToken: cancelToken,
          onSendProgress: (sent, total) async {
            final progress = (total > 0) ? (sent / total) : 0.0;

            // update notification
            FlutterForegroundTask.updateService(
              notificationTitle: 'Uploading $fileName',
              notificationText: '${(progress * 100).toStringAsFixed(0)}%',
            );

            // persist small state so UI can sync after restart
            await FlutterForegroundTask.saveData(
              key: 'media_$mediaId',
              value: {
                'mediaId': mediaId,
                'filePath': filePath,
                'status': 'uploading',
                'progress': progress,
              },
            );

            // send real-time update to main isolate (if alive)
            FlutterForegroundTask.sendDataToMain({
              'mediaId': mediaId,
              'filePath': filePath,
              'status': 'uploading',
              'progress': progress,
              's3Url': s3Url,
            });
          },
          options: Options(
            contentType: 'multipart/form-data',
            followRedirects: false,
            validateStatus: (s) => s != null && s < 500,
          ),
        );

        // S3 returns 204 on success for POST upload
        if (resp.statusCode == 204 ||
            resp.statusCode == 201 ||
            resp.statusCode == 200) {
          await FlutterForegroundTask.saveData(
            key: 'media_$mediaId',
            value: {
              'mediaId': mediaId,
              'filePath': filePath,
              'status': 'success',
              'progress': 1.0,
              's3Url': s3Url,
            },
          );

          FlutterForegroundTask.updateService(
            notificationTitle: 'Upload complete',
            notificationText: fileName,
          );

          FlutterForegroundTask.sendDataToMain({
            'mediaId': mediaId,
            'filePath': filePath,
            'status': 'success',
            'progress': 1.0,
            's3Url': s3Url,
            'isUploadToS3': true,
          });
        } else {
          await FlutterForegroundTask.saveData(
            key: 'media_$mediaId',
            value: {
              'mediaId': mediaId,
              'filePath': filePath,
              'status': 'failed',
              'progress': 0.0,
            },
          );

          FlutterForegroundTask.updateService(
            notificationTitle: 'Upload failed',
            notificationText: fileName,
          );

          FlutterForegroundTask.sendDataToMain({
            'mediaId': mediaId,
            'filePath': filePath,
            'status': 'failed',
            's3Url': s3Url,
          });
        }
      } else {
        await FlutterForegroundTask.saveData(
          key: 'media_$mediaId',
          value: {
            'mediaId': mediaId,
            'filePath': filePath,
            'status': 'failed',
            'progress': 0.0,
            'message': 'presign_failed',
          },
        );
        FlutterForegroundTask.sendDataToMain({
          'mediaId': mediaId,
          'filePath': filePath,
          'status': 'failed',
          'message': 'presign_failed',
        });

        // await database.updateRecord(mediaId, {
        //   "progress": 0.0,
        //   "status": "failed",
        // });
      }
    } catch (e) {
      final isCancel = (e is DioException && CancelToken.isCancel(e));
      await FlutterForegroundTask.saveData(
        key: 'media_$mediaId',
        value: {
          'mediaId': mediaId,
          'filePath': filePath,
          'status': isCancel ? 'paused' : 'failed',
          'progress': 0.0,
          'message': e.toString(),
        },
      );

      FlutterForegroundTask.sendDataToMain({
        'mediaId': mediaId,
        'filePath': filePath,
        'status': isCancel ? 'paused' : 'failed',
        'message': e.toString(),
      });

      FlutterForegroundTask.updateService(
        notificationTitle: isCancel ? 'Upload paused' : 'Upload error',
        notificationText: fileName,
      );
    } finally {
      _cancelTokens.remove(mediaId);
      _inProgress.remove(mediaId);
    }
  }

  @override
  void onNotificationButtonPressed(String id) {
    // If you set buttons, handle them here (stop, pause, etc.)
    if (id == 'stop') {
      FlutterForegroundTask.stopService();
    }
  }

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
  }
}
