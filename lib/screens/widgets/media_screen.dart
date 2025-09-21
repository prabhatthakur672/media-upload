import 'package:flutter/material.dart';
import 'package:media_upload/models/media_model.dart';
import 'package:media_upload/screens/widgets/media_grid.dart';

import '../../core/services/media_manager.dart';
import 'filters_widget.dart';
import 'media_button.dart';

class MediaGalleryScreen extends StatelessWidget {
  final List<MediaModel> mediaList;
  final MediaManager manager;

  const MediaGalleryScreen({
    super.key,
    required this.mediaList,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              // Filter buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...['All (2074)', 'Photos (2000)', 'Videos (74)']
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: FilterWidgets(
                            label: entry.value,
                            isSelected: entry.key == 0,
                            onSelected: () {},
                          ),
                        ),
                      ),
                ],
              ),

              SizedBox(height: 16),

              MediaGrid(
                mediaList: mediaList,
              ),
            ],
          ),

          // Floating Buttons Positioned at bottom center
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EventMediaButton(
                  labelText: 'Camera',
                  iconPath: 'assets/icons/icon_upload_camera.svg',
                  onTap: () {
                    // Execute tap functionality
                  },
                ),
                SizedBox(width: 12),
                EventMediaButton(
                  labelText: 'Upload',
                  iconPath: 'assets/icons/icon_upload_arrow.svg',
                  onTap: () async {
                    await manager.pickFiles();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => GalleryTransitionScreen(),
                    //   ),
                    // );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
