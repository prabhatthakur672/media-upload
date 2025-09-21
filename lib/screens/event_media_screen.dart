import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_upload/screens/widgets/empty_media_screen.dart';
import 'package:media_upload/screens/widgets/media_appbar.dart';
import 'package:media_upload/screens/widgets/media_screen.dart';

import '../core/helper/download_queue_manager.dart';
import '../core/helper/media_utils.dart';
import '../core/services/media_manager.dart';
import '../db/media_db.dart';
import '../models/media_model.dart';
import '../provider/provider.dart';

class EventMediaScreen extends ConsumerStatefulWidget {
  const EventMediaScreen({super.key});

  @override
  ConsumerState<EventMediaScreen> createState() => _EventMediaScreenState();
}

class _EventMediaScreenState extends ConsumerState<EventMediaScreen> {
  final MediaManager mediaManager = MediaManager();
  final MediaDB db = MediaDB();
  late DownloadQueueManager downloadManager;

  @override
  void initState() {
    super.initState();
    _initDownloadManager();
    _syncUI();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //
    // });

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

      print('wwwwwwwwwwwwwwwwwwwwwwww');
    });
  }

  @override
  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    super.dispose();
  }

  Future<void> _initDownloadManager() async {
    downloadManager = await DownloadQueueManager.create(maxConcurrent: 3);
  }

  // void _onReceiveTaskData(Object data) async {
  //   try {
  //     Map payload;
  //     if (data is String) {
  //       payload = jsonDecode(data) as Map;
  //     } else if (data is Map) {
  //       payload = Map.from(data);
  //     } else {
  //       return;
  //     }
  //
  //     final mediaId = payload['mediaId']?.toString();
  //     final status = payload['status']?.toString();
  //     final progress = (payload['progress'] is num)
  //         ? (payload['progress'] as num).toDouble()
  //         : null;
  //
  //     final s3Url = payload['s3Url']?.toString();
  //     final isUploadToS3 = payload['isUploadToS3'] as bool;
  //
  //     if (mediaId != null && status != null) {
  //       final Map<String, dynamic> update = {'status': status};
  //       if (progress != null) update['progress'] = progress;
  //
  //       if (status == 'success' && s3Url != null && isUploadToS3) {
  //         update['isUploadToS3'] = true;
  //
  //         final fileName = s3Url.split('/').last;
  //         final cachedPath =
  //             await downloadManager.downloadFile(s3Url, fileName);
  //         print('Cached video path  $cachedPath');
  //         final mediaType = MediaUtils.resolveMediaType(fileName);
  //         if (cachedPath != null) {
  //           update['cachedMedia'] = cachedPath;
  //           update['isMediaCached'] = true;
  //           print("✅ Cached $fileName at $cachedPath");
  //         }
  //
  //         if (mediaType == 'video') {
  //           final thumbnail = await MediaUtils.generateVideoThumb(cachedPath!);
  //           final videoDuration = await MediaUtils.getVideoDuration(cachedPath);
  //
  //           update['thumbnail'] = thumbnail;
  //           update['videoDuration'] = videoDuration;
  //         }
  //       }
  //       await db.updateRecord(mediaId, update);
  //     }
  //   } catch (e) {
  //     // ignore
  //   }
  // }

  // keep a map of last update times per mediaId

  final Map<String, DateTime> _lastUpdateTimes = {};

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
      final isUploadToS3 = payload['isUploadToS3'] as bool?;

      if (mediaId == null || status == null) return;

      final now = DateTime.now();
      final lastUpdate = _lastUpdateTimes[mediaId];

      // ✅ throttle uploading updates (every 300ms max)
      if (status == "uploading" && progress != null && progress < 1.0) {
        if (lastUpdate != null &&
            now.difference(lastUpdate).inMilliseconds < 400) {
          return; // skip this frequent update
        }
      }

      final Map<String, dynamic> update = {'status': status};
      if (progress != null) update['progress'] = progress;

      if (status == 'success' && s3Url != null && isUploadToS3 == true) {
        update['isUploadToS3'] = true;

        final fileName = s3Url.split('/').last;
        final cachedPath = await downloadManager.downloadFile(s3Url, fileName);
        print('Cached media path: $cachedPath');
        final mediaType = MediaUtils.resolveMediaType(fileName);

        if (cachedPath != null) {
          update['cachedMedia'] = cachedPath;
          update['isMediaCached'] = true;
          print("✅ Cached $fileName at $cachedPath");
        }

        if (mediaType == 'video' && cachedPath != null) {
          final thumbnail = await MediaUtils.generateVideoThumb(cachedPath);
          final videoDuration = await MediaUtils.getVideoDuration(cachedPath);

          update['thumbnail'] = thumbnail;
          update['videoDuration'] = videoDuration;
        }

        _lastUpdateTimes.remove(mediaId);
        print("🧹 Cleaned up throttling map for $mediaId");
      }

      await db.updateRecord(mediaId, update);

      // ✅ update timestamp
      _lastUpdateTimes[mediaId] = now;
    } catch (e) {
      print("Error in _onReceiveTaskData: $e");
    }
  }

  void _syncUI() async {
    print('UI SYNCING STARTED ============================================');
    final allUploadingMedia = await db.fetchUploadingMedia();
    allUploadingMedia.map((rec) async {
      final data = rec.value;
      final media = MediaModel.fromJson(data.cast<String, dynamic>());

      final isValidURL = await downloadManager.isValidS3Url(media.s3Url!);

      if (!isValidURL) {
        print('URL is not contain data');
        return;
      }

      final Map<String, dynamic> update = {'status': 'success'};
      if ((media.progress) != 0.0) update['progress'] = 1.0;
      update['isUploadToS3'] = media.isUploadToS3;

      final fileName = (media.s3Url)!.split('/').last;
      final cachedPath =
          await downloadManager.downloadFile(media.s3Url!, fileName);
      print('Cached media path: $cachedPath');
      final mediaType = MediaUtils.resolveMediaType(fileName);

      if (cachedPath != null) {
        update['cachedMedia'] = cachedPath;
        update['isMediaCached'] = true;
        print("✅ Cached $fileName at $cachedPath");
      }

      if (mediaType == 'video' && cachedPath != null) {
        final thumbnail = await MediaUtils.generateVideoThumb(cachedPath);
        final videoDuration = await MediaUtils.getVideoDuration(cachedPath);

        update['thumbnail'] = thumbnail;
        update['videoDuration'] = videoDuration;
      }

      await db.updateRecord(media.mediaId, update);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final mediaProvider = ref.watch(uploadMediaProvider);
    return Scaffold(
      appBar: EventMediaToolBar(),
      body: mediaProvider.when(
        data: (mediaList) => mediaList.isEmpty
            ? EventMediaEmptyUI(
                manager: mediaManager,
              )
            : MediaGalleryScreen(
                mediaList: mediaList,
                manager: mediaManager,
              ),
        error: (stackTrace, error) => Center(
          child: Text(
            "Something went wrong: $error",
            style: const TextStyle(color: Colors.red),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
