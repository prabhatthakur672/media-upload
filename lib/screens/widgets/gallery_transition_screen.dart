import 'dart:async';

import 'package:flutter/material.dart';
import 'package:media_upload/screens/event_media_screen.dart';

class GalleryTransitionScreen extends StatefulWidget {
  const GalleryTransitionScreen({super.key});

  @override
  State<GalleryTransitionScreen> createState() =>
      _GalleryTransitionScreenState();
}

class _GalleryTransitionScreenState extends State<GalleryTransitionScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => EventMediaScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF6D6568), // same background color as your image
      body: Center(
        child: Text(
          "Phone gallery screen",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
