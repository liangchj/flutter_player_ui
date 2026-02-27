import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../enum/player_fit_enum.dart';
import 'base_state.dart';

class PlayerState extends BaseState {
  PlayerState({bool fullscreen = false}) {
    isFullscreen = Signal(fullscreen);
  }
  // 播放器
  final Signal<Widget> playerView = Signal(Container());
  // 全屏
  // final Signal<bool> isFullscreen = Signal(true);
  late Signal<bool> isFullscreen;
  // 自动播放
  bool autoPlay = false;

  // 视频播放比例
  final Signal<double?> aspectRatio = Signal(null);
  // 视频本身的比例
  double? videoAspectRatio;

  final Signal<PlayerFitEnum?> fit = Signal(null);
  // 错误信息
  final Signal<String> errorMsg = Signal("");

  // 视频已初始化
  final Signal<bool> isInitialized = Signal(false);

  // 播放中
  final Signal<bool> isPlaying = Signal(false);
  // 缓冲中
  final Signal<bool> isBuffering = Signal(false);
  // 进度跳转中
  final Signal<bool> isSeeking = Signal(false);

  // 已结束
  final Signal<bool> isFinished = Signal(false);

  // 总时长
  final Signal<Duration> duration = Signal(Duration.zero);
  // 当前播放时长
  final Signal<Duration> positionDuration = Signal(Duration.zero);

  // 缓存时长
  final Signal<Duration> bufferedDuration = Signal(Duration.zero);

  // 进度拖动
  // 拖动进度时播放状态
  bool beforeSeekToIsPlaying = false;
  // 拖动中（横向）
  final Signal<bool> isDragging = Signal(false);
  // 拖动进度时的播放位置
  Duration dragProgressPositionDuration = Duration.zero;
  // 播放进度拖动秒数
  final Signal<int> draggingSecond = Signal(0);
  // 前一次拖动剩余值（每次更新只获取整数部分更新，剩下的留给后面更新）
  double draggingSurplusSecond = 0.0;

  // 当前音量值（使用百分比）
  final Signal<int> volume = Signal(0);
  // 当前音量值（使用百分比）
  final Signal<int> brightness = Signal(0);
  // 纵向滑动剩余值（每次更新只获取整数部分更新，剩下的留给后面更新）
  double verticalDragSurplus = 0.0;
  // 音量拖动中
  final Signal<bool> isVolumeDragging = Signal(false);
  // 亮度拖动中
  final Signal<bool> isBrightnessDragging = Signal(false);

  // 播放速度： ['0.25x', '0.5x', '0.75x', '1.0x', '1.25x', '1.5x', '1.75x', '2.0x']
  final Signal<double> playSpeed = Signal(1.0);

  @override
  void dispose() {
    playerView.dispose();
    isFullscreen.dispose();
    aspectRatio.dispose();
    fit.dispose();
    errorMsg.dispose();
    isInitialized.dispose();
    isPlaying.dispose();
    isBuffering.dispose();
    isSeeking.dispose();
    isFinished.dispose();
    duration.dispose();
    positionDuration.dispose();
    bufferedDuration.dispose();
    isDragging.dispose();
    draggingSecond.dispose();
    volume.dispose();
    brightness.dispose();
    isVolumeDragging.dispose();
    isBrightnessDragging.dispose();
    playSpeed.dispose();

    disposed = true;
  }
}
