import 'package:flutter/material.dart';

import '../view_model/ui_view_model.dart';

class ScreenshotUI extends StatelessWidget {
  const ScreenshotUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: uiViewModel.textColor,
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
