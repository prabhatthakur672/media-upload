import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// class MediaViewerScreen extends StatefulWidget {
//   final String path;
//   final String mediaType; // "image" or "video"
//
//   const MediaViewerScreen({
//     super.key,
//     required this.path,
//     required this.mediaType,
//   });
//
//   @override
//   State<MediaViewerScreen> createState() => _MediaViewerScreenState();
// }
//
// class _MediaViewerScreenState extends State<MediaViewerScreen> {
//   VideoPlayerController? _controller;
//   bool _showControls = true;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.mediaType == "video") {
//       _controller = VideoPlayerController.file(File(widget.path))
//         ..initialize().then((_) {
//           setState(() {}); // refresh after init
//           _controller!.play();
//         });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTap: () => setState(() => _showControls = !_showControls),
//         child: Stack(
//           children: [
//             // ✅ Media Viewer
//             Center(
//               child: widget.mediaType == "image"
//                   ? InteractiveViewer(
//                       child: Image.file(
//                         File(widget.path),
//                         fit: BoxFit.contain,
//                       ),
//                     )
//                   : _controller != null && _controller!.value.isInitialized
//                       ? AspectRatio(
//                           aspectRatio: _controller!.value.aspectRatio,
//                           child: VideoPlayer(_controller!),
//                         )
//                       : const CircularProgressIndicator(color: Colors.white),
//             ),
//
//             // ✅ Top Bar (Close button)
//             if (_showControls)
//               Positioned(
//                 top: 40,
//                 left: 10,
//                 child: IconButton(
//                   icon: const Icon(Icons.close, color: Colors.white, size: 28),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ),
//
//             // ✅ Video Controls (only if video)
//             if (widget.mediaType == "video" &&
//                 _controller != null &&
//                 _controller!.value.isInitialized &&
//                 _showControls)
//               Positioned(
//                 bottom: 30,
//                 left: 0,
//                 right: 0,
//                 child: Column(
//                   children: [
//                     VideoProgressIndicator(
//                       _controller!,
//                       allowScrubbing: true,
//                       colors: VideoProgressColors(
//                         playedColor: Colors.orange,
//                         backgroundColor: Colors.grey,
//                         bufferedColor: Colors.white54,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         IconButton(
//                           icon: Icon(
//                             _controller!.value.isPlaying
//                                 ? Icons.pause
//                                 : Icons.play_arrow,
//                             color: Colors.white,
//                             size: 40,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _controller!.value.isPlaying
//                                   ? _controller!.pause()
//                                   : _controller!.play();
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MediaGalleryViewer extends StatefulWidget {
  final List<String> paths; // media file paths
  final List<String> types; // "image" or "video"
  final int initialIndex;

  const MediaGalleryViewer({
    super.key,
    required this.paths,
    required this.types,
    this.initialIndex = 0,
  });

  @override
  State<MediaGalleryViewer> createState() => _MediaGalleryViewerState();
}

class _MediaGalleryViewerState extends State<MediaGalleryViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Map<int, VideoPlayerController> _videoControllers = {};
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    _initVideoIfNeeded(_currentIndex);
  }

  Future<void> _initVideoIfNeeded(int index) async {
    if (widget.types[index] == "video" &&
        !_videoControllers.containsKey(index)) {
      final controller = VideoPlayerController.file(File(widget.paths[index]));
      await controller.initialize();
      controller.play();
      setState(() => _videoControllers[index] = controller);
    }
  }

  @override
  void dispose() {
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            // ✅ PageView for swiping
            PageView.builder(
              controller: _pageController,
              itemCount: widget.paths.length,
              onPageChanged: (index) async {
                setState(() => _currentIndex = index);
                await _initVideoIfNeeded(index);
              },
              itemBuilder: (context, index) {
                final path = widget.paths[index];
                final type = widget.types[index];

                if (type == "image") {
                  return InteractiveViewer(
                    child: Center(
                      child: Image.file(File(path), fit: BoxFit.contain),
                    ),
                  );
                } else {
                  final controller = _videoControllers[index];
                  if (controller == null || !controller.value.isInitialized) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }
                  return Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  );
                }
              },
            ),

            // ✅ Top Bar (Close + index)
            if (_showControls)
              Positioned(
                top: 40,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "${_currentIndex + 1}/${widget.paths.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),

            // ✅ Video Controls
            if (_showControls &&
                widget.types[_currentIndex] == "video" &&
                _videoControllers[_currentIndex] != null)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    VideoProgressIndicator(
                      _videoControllers[_currentIndex]!,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.orange,
                        backgroundColor: Colors.grey,
                        bufferedColor: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      icon: Icon(
                        _videoControllers[_currentIndex]!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          final controller = _videoControllers[_currentIndex]!;
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
