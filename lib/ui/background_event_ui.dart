import 'package:flutter/material.dart';

import '../view_model/ui_view_model.dart';

class BackgroundEventUI extends StatefulWidget {
  const BackgroundEventUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<BackgroundEventUI> createState() => _BackgroundEventUIState();
}

class _BackgroundEventUIState extends State<BackgroundEventUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => uiViewModel.toggleBackground(),
      onHorizontalDragStart: (DragStartDetails details) {
        if (!uiViewModel.uiState.uiLocked.value) {
          uiViewModel.playProgressOnHorizontalDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!uiViewModel.uiState.uiLocked.value) {
          uiViewModel.playProgressOnHorizontalDragUpdate(
            context,
            details.delta,
          );
        }
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (!uiViewModel.uiState.uiLocked.value) {
          uiViewModel.playProgressOnHorizontalDragEnd();
        }
      },
      onVerticalDragStart: (DragStartDetails details) {
        if (!uiViewModel.uiState.uiLocked.value) {
          uiViewModel.volumeOrBrightnessOnVerticalDragStart(context, details);
        }
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        if (!uiViewModel.uiState.uiLocked.value) {
          uiViewModel.volumeOrBrightnessOnVerticalDragUpdate(context, details);
        }
      },
      onVerticalDragEnd: (DragEndDetails details) {
        if (!uiViewModel.uiState.uiLocked.value) {
          uiViewModel.volumeOrBrightnessOnVerticalDragEnd();
        }
      },
    );
  }
}
