import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_upload/db/media_db.dart';
import 'package:media_upload/models/media_model.dart';

final uploadMediaProvider = StreamProvider<List<MediaModel>>((ref) {
  final manager = MediaDB();
  return manager.watchRecords();
});
