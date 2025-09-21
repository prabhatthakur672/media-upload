import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class EventMediaButton extends ConsumerWidget {
  final String labelText;
  final String iconPath;
  final VoidCallback onTap;

  const EventMediaButton({
    super.key,
    required this.labelText,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Row(
            children: [
              Text(
                labelText,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              SvgPicture.asset(
                iconPath,
                height: 24,
                width: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
