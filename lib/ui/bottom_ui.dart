import 'package:flutter/material.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:signals/signals_flutter.dart';
import '../constant/icon_constant.dart';
import '../constant/style_constant.dart';
import '../state/player_state.dart';
import '../state/ui_state.dart';
import '../utils/calculate_color_utils.dart';
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

  Color get backgroundColor => uiViewModel.backgroundColor;
  // 获取UI文字颜色（播放器ui控件背景默认是黑色）

  Color get textColor => uiViewModel.textColor;
  Color get activatedTextColor => uiViewModel.activatedTextColor;

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
    return Watch(
      (context) => playerState.isFullscreen.value
          ? Column(
              children: [
                _buildProgressBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: uiViewModel.bottomControlUIItemList
                      .where((item) => item.visible.value)
                      .map((e) => e.child)
                      .toList(),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  color: StyleConstant.iconColor,
                  onPressed: () => playerViewModel.playOrPause(),
                  icon: Watch((context) {
                    var isFinished = playerState.isFinished.value;
                    var isPlaying = playerState.isPlaying.value;
                    return isFinished
                        ? IconConstant.bottomReplayPlayIcon
                        : (isPlaying
                              ? IconConstant.bottomPauseIcon
                              : IconConstant.bottomPlayIcon);
                  }),
                ),
                Watch(
                  (context) =>
                      playerViewModel.resourceState.playingChapterCount > 1
                      ? Tooltip(
                          message: playerViewModel.resourceState.haveNext
                              ? "下一个视频"
                              : "已经是最后一个视频", // 提示文本
                          child: IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            color: playerViewModel.resourceState.haveNext
                                ? StyleConstant.iconColor
                                : Colors.grey.shade400, // 置灰效果
                            onPressed: playerViewModel.resourceState.haveNext
                                ? () => playerViewModel.nextPlay()
                                : null, // 禁用时设为 null
                            icon: IconConstant.nextPlayIcon,
                            enableFeedback:
                                !playerViewModel.resourceState.haveNext, // 禁用反馈
                          ),
                        )
                      : Container(),
                ),
                Expanded(child: _buildProgressBar()),
                if (!playerViewModel.onlyFullscreen.value)
                  IconButton(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    color: textColor,
                    onPressed: () {
                      playerViewModel.fullscreenUtils.toggleFullscreen();
                    },
                    icon: Icon(Icons.fullscreen_exit_rounded),
                  ),
              ],
            ),
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
