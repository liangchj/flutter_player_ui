import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:signals/signals_flutter.dart';
import '../constant/style_constant.dart';
import '../controller/player_controller.dart';
import '../controller/ui_controller.dart';
import '../state/player_state.dart';
import '../state/ui_state.dart';

class BottomUI extends StatefulWidget {
  const BottomUI({super.key, required this.uiController});
  final UIController uiController;

  @override
  State<BottomUI> createState() => _BottomUIState();
}

class _BottomUIState extends State<BottomUI> {
  UIController get uiController => widget.uiController;
  UIState get uiState => uiController.uiState;

  PlayerController get playerController => uiController.playerController;

  PlayerState get playerState => playerController.playerState;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // 背景渐变效果
      decoration: BoxDecoration(gradient: StyleConstant.bottomUILinearGradient),
      child: _buildBottomUI(),
    );
  }

  Widget _buildBottomUI() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: StyleConstant.safeSpace,
          ),
          child: _buildProgressBar(),
        ),
        Watch((context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: uiController.fullscreenBottomUIItemList
              .where((item) => item.visible.value)
              .map((e) => e.child)
              .toList(),
        )),
      ],
    );
  }

  /// 进度条
  Widget _buildProgressBar() {
    return Watch((context) {
      if (!uiState.bottomUI.visible.value) {
        return Container();
      }
      return AbsorbPointer(
        absorbing: !playerState.isInitialized.value,
        child: ProgressBar(
          timeLabelLocation: TimeLabelLocation.sides,
          timeLabelTextStyle: TextStyle(color: Colors.white),
          timeLabelType: TimeLabelType.totalTime,
          barHeight: StyleConstant.progressBarHeight,
          thumbRadius: StyleConstant.progressBarThumbInnerRadius,
          thumbGlowRadius: StyleConstant.progressBarThumbRadius,
          progress: playerState.positionDuration.value,
          total: playerState.duration.value,
          buffered: playerState.bufferedDuration.value,
          onDragStart: (details) {
            // controller.hideTimer?.cancel();
            playerState.isDragging.value = true;
          },
          onDragEnd: () {
            playerState.isDragging.value = false;
          },
          onDragUpdate: (details) {
            // LoggerUtils.logger.d("进度条改变事件");
          },
          onSeek: (details) {
            // playerGetxController.seekTo(Duration(seconds: details.inSeconds));
          },
        ),
      );
    });
  }
}
