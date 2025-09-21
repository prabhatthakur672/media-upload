import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_upload/core/services/media_manager.dart';
import 'package:media_upload/db/media_db.dart';
import 'package:media_upload/provider/provider.dart';

// class MediaScreen extends ConsumerWidget {
//   const MediaScreen({super.key});
//
//   Color _statusColor(String status) {
//     switch (status) {
//       case "pending":
//         return Colors.grey;
//       case "uploading":
//         return Colors.blue;
//       case "success":
//         return Colors.green;
//       case "failed":
//         return Colors.red;
//       case "paused":
//         return Colors.orange;
//       default:
//         return Colors.black87;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final mediaProvider = ref.watch(uploadMediaProvider);
//     final MediaManager mediaManager = MediaManager();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Media Upload Demo',
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         elevation: 2,
//         backgroundColor: Colors.teal,
//       ),
//       body: mediaProvider.when(
//         data: (mediaList) {
//           if (mediaList.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No media uploaded yet.\nTap + to add files.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             );
//           }
//           return ListView.separated(
//             padding: const EdgeInsets.all(12),
//             itemBuilder: (context, index) {
//               final item = mediaList[index];
//
//               return Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(12),
//                   title: Text(
//                     item.filePath.split('/').last,
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       TweenAnimationBuilder<double>(
//                         tween: Tween<double>(
//                           begin: 0,
//                           end: item.progress,
//                         ),
//                         duration: const Duration(milliseconds: 400),
//                         builder: (context, value, _) => LinearProgressIndicator(
//                           value: value,
//                           backgroundColor: Colors.grey.shade200,
//                           color: _statusColor(item.status),
//                           minHeight: 6,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           Icon(Icons.circle,
//                               size: 10, color: _statusColor(item.status)),
//                           const SizedBox(width: 6),
//                           Text(
//                             '${item.status.toUpperCase()} • ${(item.progress * 100).toStringAsFixed(0)}%',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: _statusColor(item.status),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (item.status == 'uploading')
//                         IconButton(
//                           onPressed: () =>
//                               mediaManager.cancelUpload(item.mediaId),
//                           icon: const Icon(Icons.pause_circle_filled,
//                               color: Colors.orange),
//                         ),
//                       if (item.status == 'paused' || item.status == 'failed')
//                         IconButton(
//                           onPressed: () => mediaManager.uploadToS3(
//                               item.mediaId, item.filePath),
//                           icon: const Icon(Icons.play_circle_fill,
//                               color: Colors.blue),
//                         ),
//                       IconButton(
//                         onPressed: () async {
//                           await mediaManager.deleteMedia(item.mediaId);
//                         },
//                         icon: const Icon(Icons.delete_forever,
//                             color: Colors.redAccent),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//             separatorBuilder: (context, index) => const SizedBox(height: 12),
//             itemCount: mediaList.length,
//           );
//         },
//         error: (stackTrace, error) => Center(
//           child: Text(
//             "Something went wrong: $error",
//             style: const TextStyle(color: Colors.red),
//           ),
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => mediaManager.pickFiles(),
//         backgroundColor: Colors.teal,
//         tooltip: "Add Media",
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// class MediaScreen extends ConsumerStatefulWidget {
//   const MediaScreen({super.key});
//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() => _MediaScreenState();
// }
//
// class _MediaScreenState extends ConsumerState<MediaScreen> {
//   final MediaManager mediaManager = MediaManager();
//   final MediaDB db = MediaDB();
//   @override
//   void initState() {
//     super.initState();
//
//     FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       final NotificationPermission permission =
//           await FlutterForegroundTask.checkNotificationPermission();
//       if (permission != NotificationPermission.granted) {
//         await FlutterForegroundTask.requestNotificationPermission();
//       }
//
//       if (await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
//         try {
//           await FlutterForegroundTask.requestIgnoreBatteryOptimization();
//         } catch (e) {
//           print('ERRORRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR $e');
//         }
//       }
//
//       FlutterForegroundTask.init(
//         androidNotificationOptions: AndroidNotificationOptions(
//           channelId: 'Channel',
//           channelName: 'Channel Upload',
//           channelDescription: 'Channel Description....',
//         ),
//         iosNotificationOptions: IOSNotificationOptions(showNotification: false),
//         foregroundTaskOptions: ForegroundTaskOptions(
//           eventAction: ForegroundTaskEventAction.repeat(5000),
//           autoRunOnBoot: true,
//           autoRunOnMyPackageReplaced: true,
//           allowWakeLock: true,
//           allowWifiLock: true,
//         ),
//       );
//
//       // // ✅ Sync plugin storage → Sembast DB after restart
//       // try {
//       //   final all = await FlutterForegroundTask.getAllData();
//       //   print('All Plugin DB $all');
//       //   for (final entry in all.entries) {
//       //     if (!entry.key.startsWith('media_')) continue;
//       //
//       //     final val = entry.value;
//       //     Map<String, dynamic>? m;
//       //
//       //     if (val is Map) {
//       //       m = Map<String, dynamic>.from(val);
//       //     } else if (val is String) {
//       //       try {
//       //         m = Map<String, dynamic>.from(jsonDecode(val));
//       //       } catch (_) {}
//       //     }
//       //
//       //     print('MMM --- $m');
//       //     if (m != null && m['mediaId'] != null) {
//       //       await db.updateRecord(m['mediaId'], {
//       //         'status': m['status'],
//       //         'progress': (m['progress'] is num)
//       //             ? (m['progress'] as num).toDouble()
//       //             : 0.0,
//       //         if (m['s3Url'] != null) 's3Url': m['s3Url'],
//       //         if (m['isUploadToS3']) 'isUploadToS3': m['isUploadToS3'],
//       //       });
//       //       print('000000000000');
//       //     }
//       //   }
//       // } catch (e) {
//       //   debugPrint("⚠️ Sync error: $e");
//       // }
//
//       print('wwwwwwwwwwwwwwwwwwwwwwwwwwwww');
//     });
//   }
//
//   void _onReceiveTaskData(Object data) async {
//     //print('UI DATA-----------------$data');
//     try {
//       Map payload;
//       if (data is String) {
//         payload = jsonDecode(data) as Map;
//       } else if (data is Map) {
//         payload = Map.from(data);
//       } else {
//         return;
//       }
//
//       final mediaId = payload['mediaId']?.toString();
//       final status = payload['status']?.toString();
//       final progress = (payload['progress'] is num)
//           ? (payload['progress'] as num).toDouble()
//           : null;
//       final s3Url = payload['s3Url']?.toString();
//       final isUploadToS3 = payload['isUploadToS3'];
//
//       if (mediaId != null && status != null) {
//         final Map<String, dynamic> update = {'status': status};
//         if (progress != null) update['progress'] = progress;
//         if (s3Url != null) update['s3Url'] = s3Url;
//         if (isUploadToS3) update['isUploadToS3'] = isUploadToS3;
//         await db.updateRecord(mediaId, update);
//       }
//     } catch (e) {
//       // ignore
//     }
//   }
//
//   Color _statusColor(String status) {
//     switch (status) {
//       case "pending":
//         return Colors.grey;
//       case "uploading":
//         return Colors.blue;
//       case "success":
//         return Colors.green;
//       case "failed":
//         return Colors.red;
//       case "paused":
//         return Colors.orange;
//       default:
//         return Colors.black87;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaProvider = ref.watch(uploadMediaProvider);
//     print(
//         'Provider Updating UI.....................................................');
//     return Scaffold(
//       appBar: AppBar(
//           title: const Text(
//             'Media Upload Demo',
//             style: TextStyle(fontWeight: FontWeight.w600),
//           ),
//           centerTitle: true,
//           elevation: 2,
//           backgroundColor: Colors.teal,
//           actions: [
//             IconButton(
//                 onPressed: () async {
//                   final database = await db.getAllRecords();
//                   print('FINAL DN ============$database');
//                   print('DB Length --- ${database.length}');
//                 },
//                 icon: Icon(Icons.refresh))
//           ]),
//       body: mediaProvider.when(
//         data: (mediaList) {
//           if (mediaList.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No media uploaded yet.\nTap + to add files.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//             );
//           }
//           return ListView.separated(
//             padding: const EdgeInsets.all(12),
//             itemBuilder: (context, index) {
//               final item = mediaList[index];
//
//               return Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: ListTile(
//                   contentPadding: const EdgeInsets.all(12),
//                   title: Text(
//                     item.filePath.split('/').last,
//                     style: const TextStyle(fontWeight: FontWeight.w500),
//                   ),
//                   subtitle: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       TweenAnimationBuilder<double>(
//                         tween: Tween<double>(
//                           begin: 0,
//                           end: item.progress,
//                         ),
//                         duration: const Duration(milliseconds: 1000),
//                         builder: (context, value, _) => LinearProgressIndicator(
//                           value: value,
//                           backgroundColor: Colors.grey.shade200,
//                           color: _statusColor(item.status),
//                           minHeight: 6,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           Icon(Icons.circle,
//                               size: 10, color: _statusColor(item.status)),
//                           const SizedBox(width: 6),
//                           Text(
//                             '${item.status.toUpperCase()} • ${(item.progress * 100).toStringAsFixed(0)}%',
//                             style: TextStyle(
//                               fontSize: 13,
//                               color: _statusColor(item.status),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   trailing: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       if (item.status == 'uploading')
//                         IconButton(
//                           onPressed: () =>
//                               mediaManager.cancelUpload(item.mediaId),
//                           icon: const Icon(Icons.pause_circle_filled,
//                               color: Colors.orange),
//                         ),
//                       if (item.status == 'paused' || item.status == 'failed')
//                         IconButton(
//                           onPressed: () => mediaManager.uploadToS3(
//                               item.mediaId, item.filePath),
//                           icon: const Icon(Icons.play_circle_fill,
//                               color: Colors.blue),
//                         ),
//                       IconButton(
//                         onPressed: () async {
//                           await mediaManager.deleteMedia(item.mediaId);
//                         },
//                         icon: const Icon(Icons.delete_forever,
//                             color: Colors.redAccent),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//             separatorBuilder: (context, index) => const SizedBox(height: 12),
//             itemCount: mediaList.length,
//           );
//         },
//         error: (stackTrace, error) => Center(
//           child: Text(
//             "Something went wrong: $error",
//             style: const TextStyle(color: Colors.red),
//           ),
//         ),
//         loading: () => const Center(child: CircularProgressIndicator()),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => mediaManager.pickFiles(),
//         backgroundColor: Colors.teal,
//         tooltip: "Add Media",
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

class MediaScreen extends ConsumerStatefulWidget {
  const MediaScreen({super.key});

  @override
  ConsumerState<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends ConsumerState<MediaScreen> {
  final MediaManager mediaManager = MediaManager();
  final MediaDB db = MediaDB();

  @override
  void initState() {
    super.initState();

    // Listen for real-time updates from background task
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Request notification permissions
      final NotificationPermission p =
          await FlutterForegroundTask.checkNotificationPermission();
      if (p != NotificationPermission.granted) {
        await FlutterForegroundTask.requestNotificationPermission();
      }

      // Request ignore battery optimizations
      if (await FlutterForegroundTask.isIgnoringBatteryOptimizations == false) {
        try {
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        } catch (_) {}
      }

      // Init plugin options
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'upload_channel',
          channelName: 'Media Upload',
          channelDescription: 'Shows media upload progress',
        ),
        iosNotificationOptions:
            const IOSNotificationOptions(showNotification: false),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(5000),
          autoRunOnBoot: true,
          autoRunOnMyPackageReplaced: true,
          allowWakeLock: true,
          allowWifiLock: true,
        ),
      );

      // 🔥 Force sync plugin storage to Sembast DB on every app launch
      try {
        final Map<String, Object> all =
            await FlutterForegroundTask.getAllData();
        print('INITSTATE=====ALL PLUGIN STORAGE AT END: $all');
        for (final entry in all.entries) {
          final key = entry.key;
          if (!key.startsWith('media_')) continue;

          Map<String, dynamic>? m;
          final val = entry.value;

          if (val is Map) {
            m = Map<String, dynamic>.from(val);
          } else if (val is String) {
            try {
              m = Map<String, dynamic>.from(jsonDecode(val));
            } catch (_) {
              m = null;
            }
          }

          if (m != null && m['mediaId'] != null) {
            final mediaId = m['mediaId'].toString();
            final status = m['status']?.toString() ?? 'pending';
            final progress = (m['progress'] is num)
                ? (m['progress'] as num).toDouble()
                : 0.0;
            final s3Url = m['s3Url']?.toString();

            // ✅ Always update Sembast with the latest plugin storage state
            await db.updateRecord(mediaId, {
              'status': status,
              'progress': progress,
              if (s3Url != null) 's3Url': s3Url,
            });
          }
        }
      } catch (e) {
        debugPrint("Sync error: $e");
      }
    });
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  void _onReceiveTaskData(Object data) async {
    try {
      Map payload;
      if (data is String) {
        payload = jsonDecode(data) as Map;
      } else if (data is Map) {
        payload = Map.from(data);
      } else {
        return;
      }

      final mediaId = payload['mediaId']?.toString();
      final status = payload['status']?.toString();
      final progress = (payload['progress'] is num)
          ? (payload['progress'] as num).toDouble()
          : null;
      final s3Url = payload['s3Url']?.toString();

      if (mediaId != null && status != null) {
        final Map<String, dynamic> update = {'status': status};
        if (progress != null) update['progress'] = progress;
        if (s3Url != null) update['s3Url'] = s3Url;
        await db.updateRecord(mediaId, update);
      }
    } catch (e) {
      // ignore
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.grey;
      case "uploading":
        return Colors.blue;
      case "success":
        return Colors.green;
      case "failed":
        return Colors.red;
      case "paused":
        return Colors.orange;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = ref.watch(uploadMediaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Upload Demo'),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: mediaProvider.when(
        data: (mediaList) {
          if (mediaList.isEmpty) {
            return const Center(
              child: Text(
                "No media uploaded yet.\nTap + to add files.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = mediaList[index];

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  title: Text(
                    item.filePath.split('/').last,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: Colors.grey.shade200,
                        color: _statusColor(item.status),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.circle,
                              size: 10, color: _statusColor(item.status)),
                          const SizedBox(width: 6),
                          Text(
                            '${item.status.toUpperCase()} • ${(item.progress * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 13,
                              color: _statusColor(item.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (item.status == 'uploading')
                        IconButton(
                          onPressed: () =>
                              mediaManager.cancelUpload(item.mediaId),
                          icon: const Icon(Icons.pause_circle_filled,
                              color: Colors.orange),
                        ),
                      if (item.status == 'paused' || item.status == 'failed')
                        IconButton(
                          onPressed: () => mediaManager.uploadToS3(
                              item.mediaId, item.filePath),
                          icon: const Icon(Icons.play_circle_fill,
                              color: Colors.blue),
                        ),
                      IconButton(
                        onPressed: () async {
                          await mediaManager.deleteMedia(item.mediaId);
                        },
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemCount: mediaList.length,
          );
        },
        error: (stackTrace, error) => Center(
          child: Text(
            "Something went wrong: $error",
            style: const TextStyle(color: Colors.red),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await mediaManager.pickFiles();
        },
        backgroundColor: Colors.teal,
        tooltip: "Add Media",
        child: const Icon(Icons.add),
      ),
    );
  }
}
