import 'package:flutter/material.dart';

import '../controller/ui_controller.dart';

class ScreenshotUI extends StatelessWidget {
  const ScreenshotUI({super.key, required this.uiController});
  final UIController uiController;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: uiController.textColor,
      onPressed: () {},
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          Colors.black.withValues(alpha: 0.1),
        ),
      ),
      icon: Icon(Icons.photo_camera_outlined),
    );
  }
}
