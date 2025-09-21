import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_upload/core/services/upload_task_handler.dart';
import 'package:media_upload/db/media_db.dart';
import 'package:media_upload/screens/event_media_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  final db = MediaDB();
  await db.database;
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(UploadTaskHandler());
  print(
      'SetTaskHandler-----------------------------------------------------------------');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Upload Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const EventMediaScreen(),
    );
  }
}
