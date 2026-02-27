import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:signals/signals_flutter.dart';
import '../constant/style_constant.dart';
import '../state/player_state.dart';
import '../state/ui_state.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';

class BottomUI extends StatefulWidget {
  const BottomUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<BottomUI> createState() => _BottomUIState();
}

class _BottomUIState extends State<BottomUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  UIState get uiState => uiViewModel.uiState;

  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;

  PlayerState get playerState => playerViewModel.playerState;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // 背景渐变效果
      decoration: BoxDecoration(gradient: StyleConstant.bottomUILinearGradient),
      child: _buildBottomUI(context),
    );
  }

  Widget _buildBottomUI(BuildContext context) {
    return uiViewModel.bottomControlBar;
    /*return Watch((context) => playerState.isFullscreen.value ? Column(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: StyleConstant.safeSpace,
          ),
          child: _buildProgressBar(),
        ),
        Watch(
              (context) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: uiViewModel.bottomControlUIItemList
                .where((item) => item.visible.value)
                .map((e) => e.child)
                .toList(),
          ),
        ),
      ],
    ) : Row(
      children: [
      ],
    ));*/
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
            uiViewModel.cancelHideTimer();
            playerState.isDragging.value = true;
          },
          onDragEnd: () {
            uiViewModel.cancelAndRestartTimer();
            playerState.isDragging.value = false;
          },
          onDragUpdate: (details) {
            // LoggerUtils.logger.d("进度条改变事件");
          },
          onSeek: (details) {
            playerViewModel.seekTo(Duration(seconds: details.inSeconds));
          },
        ),
      );
    });
  }
}
