// import 'package:chewie/chewie.dart';
// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
//
// class VideoPlayerScreen extends StatefulWidget {
//   final String videoUrl;
//
//   const VideoPlayerScreen({super.key, required this.videoUrl});
//
//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
//   VideoPlayerController? _controller;
//   ChewieController? _chewieController;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
//       ..initialize().then((_) {
//         setState(() {});
//       });
//
//     _chewieController = ChewieController(
//       videoPlayerController: _controller!,
//       autoPlay: true,
//       looping: false,
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     _chewieController?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(backgroundColor: Colors.black),
//       body: Center(
//         child: _chewieController != null &&
//                 _chewieController!.videoPlayerController.value.isInitialized
//             ? Chewie(controller: _chewieController!)
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }
