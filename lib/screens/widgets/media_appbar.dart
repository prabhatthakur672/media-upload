import 'package:flutter/material.dart';
import 'package:media_upload/db/media_db.dart';

class EventMediaToolBar extends StatefulWidget implements PreferredSizeWidget {
  const EventMediaToolBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<EventMediaToolBar> createState() => _EventMediaToolBarState();
}

class _EventMediaToolBarState extends State<EventMediaToolBar> {
  bool isToggled = false;
  final MediaDB db = MediaDB();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () async {
              final all = await db.getAllRecords();
              print('MEDIA LENGTH================== ${all.length}');
              print('All Data ================== $all');
              for (final media in all) {
                if (media['mediaType'] == 'video') {
                  print('VIDEO MEDIA ============ $media');
                }
              }
            },
            child: Text(
              'Event Gallery',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                'Added by me',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 8),
              CustomToggleSwitch(
                value: isToggled,
                onChanged: (value) {
                  setState(() {
                    isToggled = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CustomToggleSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final Duration duration;

  const CustomToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 46,
    this.height = 26,
    this.activeColor = Colors.black,
    this.inactiveColor = Colors.black,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<CustomToggleSwitch> createState() => _CustomToggleSwitchState();
}

class _CustomToggleSwitchState extends State<CustomToggleSwitch> {
  @override
  Widget build(BuildContext context) {
    final isToggled = widget.value;
    final thumbSize = widget.height - 4;

    return GestureDetector(
      onTap: () => widget.onChanged(!isToggled),
      child: AnimatedContainer(
        duration: widget.duration,
        width: widget.width,
        height: widget.height,
        padding: EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            width: 1,
            color: isToggled ? Colors.black : Colors.grey,
          ),
        ),
        child: AnimatedAlign(
          duration: widget.duration,
          alignment: isToggled ? Alignment.centerRight : Alignment.centerLeft,
          curve: Curves.easeInOut,
          child: Container(
            width: thumbSize,
            height: thumbSize,
            decoration: BoxDecoration(
              color: isToggled ? Colors.black : Colors.grey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
