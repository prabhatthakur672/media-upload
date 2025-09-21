// class MediaPagination {
//   static Future<List<MediaModel>> loadPageWithCache(
//       int offset, int limit, DownloadQueueManager manager, MediaDB db) async {
//     final items = await db.fetchMediaPage(offset, limit);
//
//     for (final item in items) {
//       if (item.s3Url != null && !item.isMediaCached) {
//         final fileName = item.s3Url!.split('/').last;
//         final cachedPath = await manager.downloadFile(item.s3Url!, fileName);
//         if (cachedPath != null) {
//           item.cachedMedia = cachedPath;
//           item.isMediaCached = true;
//           await db.updateRecord(item.mediaId, {
//             'cachedMedia': cachedPath,
//             'isMediaCached': true,
//           });
//         }
//       }
//     }
//
//     await manager.cleanupCache();
//
//     return items;
//   }
// }
