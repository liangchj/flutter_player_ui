import 'package:flutter/material.dart';

import '../controller/ui_controller.dart';

class BackgroundEventUI extends StatefulWidget {
  const BackgroundEventUI({super.key, required this.uiController});
  final UIController uiController;

  @override
  State<BackgroundEventUI> createState() => _BackgroundEventUIState();
}

class _BackgroundEventUIState extends State<BackgroundEventUI> {
  UIController get uiController => widget.uiController;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => uiController.toggleBackground(),
      onHorizontalDragStart: (DragStartDetails details) {
        if (!uiController.uiState.uiLocked.value) {
          uiController.playProgressOnHorizontalDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!uiController.uiState.uiLocked.value) {
          uiController.playProgressOnHorizontalDragUpdate(
            context,
            details.delta,
          );
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (!uiController.uiState.uiLocked.value) {
          uiController.playProgressOnHorizontalDragEnd();
        }
      },
      onVerticalDragStart: (DragStartDetails details) {
        if (!uiController.uiState.uiLocked.value) {
          uiController.volumeOrBrightnessOnVerticalDragStart(context, details);
        }
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        if (!uiController.uiState.uiLocked.value) {
          uiController.volumeOrBrightnessOnVerticalDragUpdate(context, details);
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        if (!uiController.uiState.uiLocked.value) {
          uiController.volumeOrBrightnessOnVerticalDragEnd();
        }
      },
    );
  }
}

