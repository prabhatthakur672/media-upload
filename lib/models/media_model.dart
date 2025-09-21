class MediaModel {
  final String mediaId;
  final String filePath;
  final String mediaType; // image | video | audio | document
  String status;
  String? s3Url;
  bool isUploadToS3;
  double progress;
  int retries;
  String? cachedMedia; // local path of cached image/video
  bool isMediaCached;
  String? thumbnail; // only for video
  String? videoDuration; // only for video

  MediaModel({
    required this.mediaId,
    required this.filePath,
    required this.mediaType,
    this.status = 'pending',
    this.s3Url,
    this.isUploadToS3 = false,
    this.progress = 0.0,
    this.retries = 0,
    this.cachedMedia,
    this.isMediaCached = false,
    this.thumbnail,
    this.videoDuration,
  });

  Map<String, dynamic> toJson() {
    return {
      'mediaId': mediaId,
      'filePath': filePath,
      'mediaType': mediaType,
      'status': status,
      's3Url': s3Url,
      'isUploadToS3': isUploadToS3,
      'progress': progress,
      'retries': retries,
      'cachedMedia': cachedMedia,
      'isMediaCached': isMediaCached,
      'thumbnail': thumbnail,
      'videoDuration': videoDuration,
    };
  }

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      mediaId: json['mediaId'] as String,
      filePath: json['filePath'] as String,
      mediaType: json['mediaType'] as String,
      status: json['status'] as String? ?? 'pending',
      s3Url: json['s3Url'] as String?,
      isUploadToS3: json['isUploadToS3'] as bool? ?? false,
      progress: (json['progress'] is num)
          ? (json['progress'] as num).toDouble()
          : 0.0,
      retries: json['retries'] as int? ?? 0,
      cachedMedia: json['cachedMedia'] as String?,
      isMediaCached: json['isMediaCached'] as bool? ?? false,
      thumbnail: json['thumbnail'] as String?,
      videoDuration: json['videoDuration'] as String?,
    );
  }
}

// class MediaModel {
//   final String mediaId;
//   final String filePath;
//   final String mediaType;
//   String status;
//   String? s3Url;
//   bool isUploadToS3;
//   double progress;
//   int retries;
//   String? cachedMedia;
//   bool isMediaCached;
//   Uint8List? thumbnail;
//   String? videoDuration;
//   DateTime createdAt;
//
//   MediaModel({
//     required this.mediaId,
//     required this.filePath,
//     required this.mediaType,
//     this.status = 'pending',
//     this.s3Url,
//     this.isUploadToS3 = false,
//     this.progress = 0.0,
//     this.retries = 0,
//     this.cachedMedia,
//     this.isMediaCached = false,
//     this.thumbnail,
//     this.videoDuration,
//     DateTime? createdAt,
//   }) : createdAt = createdAt ?? DateTime.now();
//
//   Map<String, dynamic> toJson() {
//     return {
//       'mediaId': mediaId,
//       'filePath': filePath,
//       'mediaType': mediaType,
//       'status': status,
//       's3Url': s3Url,
//       'isUploadToS3': isUploadToS3,
//       'progress': progress,
//       'retries': retries,
//       'cachedMedia': cachedMedia,
//       'isMediaCached': isMediaCached,
//       'thumbnail': thumbnail != null ? base64Encode(thumbnail!) : null,
//       'videoDuration': videoDuration,
//       'createdAt': createdAt.toIso8601String(), // ✅ store timestamp
//     };
//   }
//
//   factory MediaModel.fromJson(Map<String, dynamic> json) {
//     return MediaModel(
//       mediaId: json['mediaId'] as String,
//       filePath: json['filePath'] as String,
//       mediaType: json['mediaType'] as String,
//       status: json['status'] as String? ?? 'pending',
//       s3Url: json['s3Url'] as String?,
//       isUploadToS3: json['isUploadToS3'] as bool? ?? false,
//       progress: (json['progress'] is num)
//           ? (json['progress'] as num).toDouble()
//           : 0.0,
//       retries: json['retries'] as int? ?? 0,
//       cachedMedia: json['cachedMedia'] as String?,
//       isMediaCached: json['isMediaCached'] as bool? ?? false,
//       thumbnail: json['thumbnail'] != null
//           ? base64Decode(json['thumbnail'] as String)
//           : null,
//       videoDuration: json['videoDuration'] as String?,
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : DateTime.now(),
//     );
//   }
// }
