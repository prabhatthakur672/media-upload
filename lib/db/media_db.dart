import 'package:media_upload/models/media_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';

class MediaDB {
  static final MediaDB _instance = MediaDB._internal();

  factory MediaDB() {
    return _instance;
  }

  MediaDB._internal();

  Database? _db;
  final store = intMapStoreFactory.store('media');

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/media.db';
    _db = await databaseFactoryIo.openDatabase(dbPath);
    return _db!;
  }

  Future<int> addRecord(MediaModel task) async {
    final db = await database;
    return await store.add(db, task.toJson());
  }

  Future<void> addBulkRecords(List<MediaModel> items) async {
    final db = await database;
    final dataList = items.map((item) => item.toJson()).toList();
    await store.addAll(db, dataList);
  }

  Future<List<RecordSnapshot<int, Map<String, Object?>>>>
      getAllRecords() async {
    final db = await database;
    return await store.find(db,
        finder: Finder(sortOrders: [SortOrder('mediaId')]));
  }

  Stream<List<MediaModel>> watchRecords() async* {
    final db = await database; // open the DB

    yield* store.query().onSnapshots(db).map((snapshots) {
      return snapshots.map((snapshot) {
        return MediaModel.fromJson(
          snapshot.value.cast<String, dynamic>(),
        );
      }).toList();
    });
  }

  Future<void> updateRecord(String mediaId, Map<String, dynamic> value) async {
    final db = await database;
    await store.update(
      db,
      value,
      finder: Finder(
        filter: Filter.equals('mediaId', mediaId),
      ),
    );
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await store.delete(
      db,
      finder: Finder(
        filter: Filter.equals('mediaId', id),
      ),
    );
  }

  Future<List<RecordSnapshot<int, Map<String, Object?>>>>
      fetchPendingAndFailedMedia() async {
    final db = await database;
    return await store.find(
      db,
      finder: Finder(
        filter: Filter.or(
          [
            Filter.equals('status', 'pending'),
            Filter.equals('status', 'failed')
          ],
        ),
      ),
    );
  }

  Future<List<RecordSnapshot<int, Map<String, Object?>>>>
      fetchUploadingMedia() async {
    final db = await database;
    return await store.find(
      db,
      finder: Finder(
        filter: Filter.equals('status', 'uploading'),
      ),
    );
  }

  Future<List<MediaModel>> fetchMediaPage(int offset, int limit) async {
    final db = await database;

    final finder = Finder(
      offset: offset,
      limit: limit,
      sortOrders: [SortOrder('createdAt', false)], // newest first
    );

    final records = await store.find(db, finder: finder);

    return records.map((snapshot) {
      return MediaModel.fromJson(
        snapshot.value.cast<String, dynamic>(),
      );
    }).toList();
  }
}
