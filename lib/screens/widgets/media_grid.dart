import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:media_upload/core/services/media_manager.dart';

import '../../core/helper/media_utils.dart';
import '../../models/media_model.dart';
import 'media_viewer_screen.dart';

class MediaGrid extends StatelessWidget {
  final List<MediaModel> mediaList;

  const MediaGrid({
    super.key,
    required this.mediaList,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        // reverse: true,
        cacheExtent: 2400, // prefetch items outside viewport for smooth scroll
        itemCount: mediaList.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final item = mediaList[mediaList.length - 1 - index];
          final mediaType = MediaUtils.resolveMediaType(item.s3Url ?? '');
          // print('MEDIA STATUS --------------- ${item.status}');
          // print('Progress ======================== ${item.progress}');
          return MediaGridItem(
            item: item,
            mediaType: mediaType,
            onTap: () {
              // also reverse for viewer
              final reversedList = mediaList.reversed.toList();

              final mediaPaths =
                  reversedList.map((m) => m.cachedMedia!).toList();
              final mediaTypes = reversedList.map((m) => m.mediaType).toList();
              final startIndex = reversedList.indexOf(item);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MediaGalleryViewer(
                    paths: mediaPaths,
                    types: mediaTypes,
                    initialIndex: startIndex,
                  ),
                ),
              );
            },
            onRetry: () {
              print('RETRY LOGIC EXECUTION STARTED=======================');
            },
          );
        },
      ),
    );
  }
}

// class MediaGrid extends StatefulWidget {
//   const MediaGrid({super.key});
//   @override
//   State<MediaGrid> createState() => _MediaGridState();
// }
//
// class _MediaGridState extends State<MediaGrid> {
//   final MediaDB _db = MediaDB();
//   late DownloadQueueManager _downloadManager;
//
//   final List<MediaModel> _mediaList = [];
//   final ScrollController _scrollController = ScrollController();
//
//   int _offset = 0;
//   final int _limit = 30;
//   bool _isLoading = false;
//   bool _hasMore = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }
//
//   Future<void> _init() async {
//     _downloadManager = await DownloadQueueManager.create();
//     await _loadPage(); // load first 30
//     _scrollController.addListener(_onScroll);
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//             _scrollController.position.maxScrollExtent - 300 &&
//         !_isLoading &&
//         _hasMore) {
//       _loadPage();
//     }
//   }
//
//   Future<void> _loadPage() async {
//     if (_isLoading) return;
//     setState(() => _isLoading = true);
//
//     final items = await MediaPagination.loadPageWithCache(
//       _offset,
//       _limit,
//       _downloadManager,
//       _db,
//     );
//
//     await _downloadManager.cleanupCache(
//       maxSizeMB: 500,
//       maxAge: const Duration(hours: 5),
//     );
//
//     if (items.isEmpty) {
//       setState(() {
//         _hasMore = false;
//         _isLoading = false;
//       });
//       return;
//     }
//
//     setState(() {
//       _mediaList.addAll(items);
//       _offset += _limit;
//       _isLoading = false;
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GridView.builder(
//         cacheExtent: 2400,
//         controller: _scrollController,
//         itemCount: _mediaList.length + (_hasMore ? 1 : 0),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 1,
//           crossAxisSpacing: 1,
//           childAspectRatio: 1,
//         ),
//         itemBuilder: (context, index) {
//           if (index >= _mediaList.length) {
//             return const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           }
//
//           final item = _mediaList[index];
//           final mediaType = MediaUtils.resolveMediaType(item.s3Url ?? '');
//
//           return MediaGridItem(
//             item: item,
//             mediaType: mediaType,
//             onTap: () {
//               if (mediaType == 'video') {
//                 // TODO: play video
//               } else {
//                 // TODO: show full image
//               }
//             },
//             onRetry: () {
//               // TODO: retry logic
//             },
//           );
//         },
//       ),
//     );
//   }
// }

class MediaGridItem extends StatelessWidget {
  final MediaModel item;
  final String mediaType;
  final VoidCallback? onRetry;
  final VoidCallback? onTap;

  MediaGridItem({
    super.key,
    required this.item,
    required this.mediaType,
    this.onRetry,
    this.onTap,
  });

  final MediaManager _manager = MediaManager();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: item.status == "success" ? onTap : null,
      onTap: onTap,
      onLongPress: () async {
        await _manager.deleteMedia(item.mediaId);
      },
      child: Stack(
        children: [
          if (item.isMediaCached && item.status == 'success')
            ClipRRect(
              child: mediaType == 'image'
                  ? Image(
                      image: FileImage(File(item.cachedMedia!)),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : item.thumbnail != null
                      ? Image(
                          image: FileImage(File(item.thumbnail!)),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200,
                                Colors.grey.shade400
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.videocam_outlined,
                              size: 42,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
            ),

          // ✅ Gradient overlay for text visibility
          if (item.isMediaCached && item.status == 'success')
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 40,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xFF0D0206),
                      Color(0x00000000),
                    ],
                  ),
                ),
              ),
            ),

          // ✅ Video duration + icon (use cached value)
          if (item.isMediaCached &&
              item.status == 'success' &&
              mediaType == 'video')
            Positioned(
              left: 4,
              right: 4,
              bottom: 4,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon_video.svg',
                    height: 16,
                    width: 16,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    item.videoDuration ?? "--:--",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          // ✅ Uploading state
          if (!item.isMediaCached || item.status == 'uploading')
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.orange,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),

          // ✅ Failed state
          if (item.status == 'failed')
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 42, color: Colors.redAccent),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: onRetry,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
