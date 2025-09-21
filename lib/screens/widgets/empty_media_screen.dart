import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:media_upload/core/services/media_manager.dart';

import 'filters_widget.dart';

class EventMediaEmptyUI extends ConsumerWidget {
  final MediaManager manager;
  const EventMediaEmptyUI({super.key, required this.manager});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...['All', 'Photos', 'Videos'].asMap().entries.map(
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
          SizedBox(
            height: 96,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/icon_album.svg',
                  height: 90,
                  width: 84,
                ),
                SizedBox(
                  height: 12,
                ),
                Text(
                  'Oops! No one has added photos till now. Be the first one to upload your awesome event photos',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 24,
                ),
                GestureDetector(
                  onTap: () async {
                    await manager.pickFiles();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => GalleryTransitionScreen(),
                    //   ),
                    // );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Upload from phone',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  'or',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/icon_camera.svg',
                      height: 32,
                      width: 32,
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Open Camera',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Spacer(),
          // EventMediaInfoCardStack(),
          // SizedBox(
          //   height: AppDimensV2.height16,
          // ),
        ],
      ),
    );
  }
}
