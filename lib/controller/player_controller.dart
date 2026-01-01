import 'package:flutter_player_ui/controller/ui_controller.dart';
import 'package:signals/signals.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../iplayer.dart';
import '../state/player_state.dart';
import '../state/resource_state.dart';
import '../utils/fullscreen_utils.dart';

class PlayerController {
  late final PlayerState playerState;
  late ResourceState resourceState;
  late final UIController uiController;
  final Signal<IPlayer?> player = signal(null);
  final Signal<bool> playerInitialized = signal(false);
  late FullscreenUtils fullscreenUtils;
  bool _initialized = false;
  bool get initialized => _initialized;
  // 标记是否只有全屏页面
  bool onlyFullscreen = false;
  final List<EffectCleanup> _effectCleanupList = [];
  PlayerController() {
    playerState = PlayerState();
    resourceState = ResourceState();
    uiController = UIController(this);
    fullscreenUtils = FullscreenUtils(this);
    _init();
    _initialized = true;

  }

  void _init() {
    _effectCleanupList.addAll([
      effect(() {
        if (player.value != null) {
          untracked(() {
            player.value!.playerController = this;
          });
        }
      }),
      // 监听播放器
      effect(() {
        if (player.value != null) {
          player.value?.onInitPlayer();
        }
      }),
      // 监听播放器初始化
      effect(() {
        if (!playerState.isInitialized.value) {
          untracked(() {
            playerState.isPlaying.value = false;
            playerState.isBuffering.value = false;
          });
        }
      }),
      // 监听播放完成
      effect(() {
        if (playerState.isFinished.value) {
          untracked(() {
            playerState.isPlaying.value = false;
            playerState.isBuffering.value = false;
            if (resourceState.haveNext) {
              nextPlay();
            }
          });
        }
      }),
      // 监听切换视频
      effect(() {
        var resourceStateModel = resourceState.resourcePlayingState.value;
        if (resourceStateModel.chapterIndex < 0) {
          return;
        }
        untracked(() async {
          if (resourceState.resourceModel.value == null &&
              resourceState.chapterList.value == null) {
            return;
          }
          await changeVideoUrl(
            autoPlay: _initialized ? playerState.autoPlay : true,
          );
          playerState.isPlaying.value = false;
        });
      }),
      // 监听播放状态
      effect(() {
        var isPlaying = playerState.isPlaying.value;
        untracked(() {
          if (isPlaying) {
            // 开始播放时启动定时器
            // _startHistoryRecordTimer();

            // 播放时保持屏幕唤醒
            WakelockPlus.enable();
            // myDanmakuController.resumeDanmaku();
          } else {
            // 暂停时停止定时器并立即记录一次
            // _stopHistoryRecordTimer();
            // _recordPlayHistory();

            // 暂停时关闭保持屏幕唤醒
            WakelockPlus.disable();
            // myDanmakuController.pauseDanmaku();
          }
        });
      }),
      // 监听播放速度
      effect(() {
        var value = playerState.playSpeed.value;
        player.value?.setPlaySpeed(value);
        /*GStorage.setting.put(
          "${SettingBoxKey.cachePrev}-${SettingBoxKey.playSpeed}",
          value,
        );*/
      })
    ]);
  }

  Future<void> dispose() async {
    for (var cleanup in _effectCleanupList) {
      cleanup();
    }
    await stop();
    player.dispose();
    uiController.dispose();
  }

  /// 重置播放状态
  void resetPlayerState() {
    playerState.aspectRatio.value = null;
    playerState.videoAspectRatio = null;
    playerState.errorMsg.value = "";
    playerState.isInitialized.value = false;
    playerState.isPlaying.value = false;
    playerState.isBuffering.value = false;
    playerState.isSeeking.value = false;
    playerState.isFinished.value = false;

    playerState.duration.value = Duration.zero;
    playerState.positionDuration.value = Duration.zero;
    playerState.bufferedDuration.value = Duration.zero;
    playerState.beforeSeekToIsPlaying = false;
    playerState.isDragging.value = false;
    playerState.dragProgressPositionDuration = Duration.zero;
    playerState.draggingSecond.value = 0;
    playerState.draggingSurplusSecond = 0.0;

    playerState.verticalDragSurplus = 0.0;
    playerState.isVolumeDragging.value = false;
    playerState.isBrightnessDragging.value = false;
  }

  Future<void> changeVideoUrl({bool autoPlay = true}) async {
    await stop();
    resetPlayerState();
    player.value?.changeVideoUrl(autoPlay: autoPlay);
  }

  // 视频播放
  Future<void> play() async {
    return player.value?.play();
  }

  // 视频暂停
  Future<void> pause() async {
    return player.value?.pause();
  }

  Future<void> stop() async {
    await player.value?.stop();
    playerState.isPlaying.value = false;
  }

  // 暂停或播放
  Future<void> playOrPause() async {
    if (player.value == null) {
      return;
    }
    if (player.value!.finished) {
      await seekTo(Duration.zero);
    }
    if (player.value!.playing) {
      return pause();
    } else {
      return play();
    }
  }

  Future<void> seekTo(Duration position) async {
    playerState.positionDuration.value = position;
    playerState.isSeeking.value = true;
    playerState.positionDuration.value = position; // 立即更新UI位置
    // myDanmakuController.seekToDanmaku(position.inMilliseconds);
    await player.value?.seekTo(position);
    playerState.beforeSeekToIsPlaying = false;
    playerState.isSeeking.value = false;
  }

  void nextPlay() {
    resourceState.chapterActivatedIndex.value =
        resourceState.chapterActivatedIndex.value + 1;
  }

  Future<void> beforeSeekTo() async {}

  Future<void> afterSeekTo() async {}
}
