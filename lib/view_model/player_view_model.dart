import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_player_ui/interface/player_data_storage.dart';
import 'package:signals/signals.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../constant/common_constant.dart';
import '../interface/iplayer.dart';
import '../model/storage/play_history_model.dart';
import '../state/player_state.dart';
import '../state/resource_state.dart';
import '../utils/fullscreen_utils.dart';
import 'base_view_model.dart';
import 'my_danmaku_view_model.dart';
import 'ui_view_model.dart';

class PlayerViewModel extends BaseViewModel {
  late final PlayerState playerState;
  late ResourceState resourceState;
  late final UIViewModel uiViewModel;
  final Signal<IPlayer?> player = signal(null);
  final Signal<bool> playerInitialized = signal(false);
  late FullscreenUtils fullscreenUtils;
  late MyDanmakuViewModel myDanmakuViewModel;
  bool _initialized = false;
  bool get initialized => _initialized;
  // 标记是否只有全屏页面
  bool onlyFullscreen = false;
  final List<EffectCleanup> _effectCleanupList = [];

  PlayerDataStorage? dataStorage;

  // 历史记录定时器
  Timer? _historyRecordTimer;
  Duration startPlayDuration = Duration.zero;

  PlayerViewModel() {
    playerState = PlayerState();
    resourceState = ResourceState();
    uiViewModel = UIViewModel(this);
    fullscreenUtils = FullscreenUtils(this);
    // myDanmakuViewModel = MyDanmakuViewModel(playerViewModel: this);
    myDanmakuViewModel = uiViewModel.myDanmakuViewModel;
    _init();
    _initialized = true;
  }

  void _init() async {
    double? playSpeed = await dataStorage?.getSetting("playSpeed");
    if (playSpeed != null) {
      playerState.playSpeed.value = playSpeed;
    }
    _effectCleanupList.addAll([
      effect(() {
        if (player.value != null) {
          untracked(() {
            player.value!.playerViewModel = this;
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
        var value = playerState.isInitialized.value;
        untracked(() {
          if (value) {
            resourceState.danmakuSource.value =
                resourceState.playingChapter?.danmakuSource;
          } else {
            playerState.isPlaying.value = false;
            playerState.isBuffering.value = false;
          }
        });
      }),
      // 监听播放完成
      effect(() {
        var flag = playerState.isFinished.value;
        untracked(() async {
          if (flag) {
            playerState.isPlaying.value = false;
            playerState.isBuffering.value = false;
            if (resourceState.haveNext) {
              nextPlay();
            }
          }
        });
      }),
      // 监听切换视频
      effect(() {
        var resourceStateModel = resourceState.resourcePlayingState.value;
        if (resourceState.prevResourceState.valueEquals(resourceStateModel)) {
          return;
        }
        resourceState.prevResourceState = resourceStateModel;
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
            _startHistoryRecordTimer();

            // 播放时保持屏幕唤醒
            WakelockPlus.enable();
            myDanmakuViewModel.resumeDanmaku();
          } else {
            // 暂停时停止定时器并立即记录一次
            _stopHistoryRecordTimer();
            _recordPlayHistory();

            // 暂停时关闭保持屏幕唤醒
            WakelockPlus.disable();
            myDanmakuViewModel.pauseDanmaku();
          }
        });
      }),
      // 监听播放速度
      effect(() {
        var value = playerState.playSpeed.value;
        player.value?.setPlaySpeed(value);
        dataStorage?.saveSetting("playSpeed", value);
      }),
    ]);
  }

  @override
  Future<void> dispose() async {
    // 应用退出前记录一次播放历史
    _recordPlayHistory();
    // 停止定时器
    _stopHistoryRecordTimer();
    for (var cleanup in _effectCleanupList) {
      cleanup();
    }
    await stop();
    if (player.value != null && !player.value!.disposed) {
      player.value?.dispose();
    }
    player.dispose();
    myDanmakuViewModel.dispose();
    uiViewModel.dispose();
    resourceState.dispose();
    playerState.dispose();
    disposed = true;
  }

  void _startHistoryRecordTimer() {
    _stopHistoryRecordTimer(); // 先停止已有的定时器
    _historyRecordTimer = Timer.periodic(
      Duration(seconds: CommonConstant.historyRecordInterval),
      (timer) {
        _recordPlayHistory();
      },
    );
  }

  void _stopHistoryRecordTimer() {
    _historyRecordTimer?.cancel();
    _historyRecordTimer = null;
  }

  // 记录播放历史
  void _recordPlayHistory() {
    // 检查是否满足最小播放时间要求
    if (playerState.positionDuration.value.inSeconds -
            startPlayDuration.inSeconds <
        CommonConstant.minPlayTimeForHistory) {
      return;
    }

    // 检查播放器是否已初始化且没有错误
    if (!playerState.isInitialized.value || playerState.errorMsg.isNotEmpty) {
      return;
    }

    // 记录播放历史到数据库或本地存储
    _savePlayHistoryToStorage();
  }

  // 保存播放历史到存储
  void _savePlayHistoryToStorage() {
    // 根据当前播放的视频信息和播放位置保存历史记录
    resourceState.playingChapter?.historyDuration =
        playerState.positionDuration.value;

    String id = "";
    String? apiKey;
    String? sourceGroupKey;
    late PlayHistoryModel historyModel;
    if (resourceState.resourceModel.value == null) {
      id = resourceState.playingChapter?.playUrl ?? "";
    } else {
      if (resourceState.playingApi != null) {
        apiKey = resourceState.playingApi!.api?.enName;

        if (resourceState.playingSourceGroup != null) {
          sourceGroupKey = resourceState.playingSourceGroup!.enName;
        } else {
          sourceGroupKey = apiKey;
        }
      }
    }
    historyModel = PlayHistoryModel(
      resourceId: id,
      apiKey: apiKey,
      sourceGroupKey: sourceGroupKey,
      chapterUrl: resourceState.playingChapter?.playUrl ?? "",
      chapterIndex: resourceState.resourcePlayingState.value.chapterIndex,
      chapterName: resourceState.playingChapter?.name ?? "",
      durationInMilli: playerState.duration.value.inMilliseconds,
      positionInMilli: playerState.positionDuration.value.inMilliseconds,
      time: DateTime.now(),
    );
    dataStorage?.savePlayHistory(historyModel.key, historyModel);
  }

  /// 重置播放状态
  void resetPlayerState() {
    if (playerState.disposed) {
      return;
    }
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

    await Future(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {});
    });

    _beforeChangeVideoUrl();

    player.value?.changeVideoUrl(autoPlay: autoPlay);
    myDanmakuViewModel.afterChangeVideoUrl(autoPlay);
  }

  void _beforeChangeVideoUrl() async {
    // 停止弹幕
    myDanmakuViewModel.beforeChangeVideoUrl();

    // 视频切换前记录上一个视频的历史
    _recordPlayHistory();
    // 停止当前定时器
    _stopHistoryRecordTimer();
    // 重置状态
    resetPlayerState();
    // 清空上一个视频播放起始位置
    startPlayDuration = Duration.zero;
    // 从缓存中读取新视频开始播放位置
    int historyPosition = 0;
    String videoKey = "";
    if (resourceState.resourceModel.value == null) {
      videoKey = resourceState.playingChapter?.playUrl ?? "";
    } else {
      String videoId = resourceState.resourceModel.value!.id;
      String apiKey = resourceState.playingApi!.api?.enName ?? "";
      String? sourceGroupKey;
      if (resourceState.playingSourceGroup != null) {
        sourceGroupKey = resourceState.playingSourceGroup!.enName;
      } else {
        sourceGroupKey = apiKey;
      }
      videoKey =
          'resourceId:${videoId}_apiKey:${apiKey}_sourceGroupKey:$sourceGroupKey';
    }
    if (videoKey.isNotEmpty) {
      var playHistory = await dataStorage?.getPlayHistory(videoKey);
      if (playHistory != null) {
        historyPosition = playHistory.positionInMilli;
        resourceState.playingChapter?.historyDuration = Duration(
          milliseconds: historyPosition,
        );
        resourceState.playingChapter?.start = Duration(
          milliseconds: historyPosition,
        );
      }
    }
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
    if (!playerState.disposed) {
      playerState.isPlaying.value = false;
    }
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
    if (playerState.disposed) {
      return;
    }
    playerState.positionDuration.value = position;
    playerState.isSeeking.value = true;
    playerState.positionDuration.value = position; // 立即更新UI位置
    await player.value?.seekTo(position);
    playerState.beforeSeekToIsPlaying = false;
    playerState.isSeeking.value = false;
    // 清空幕布中的弹幕，避免因跳转时间导致弹幕重复
    myDanmakuViewModel.clearDanmaku();
  }

  void nextPlay() {
    if (resourceState.disposed) {
      return;
    }
    if (resourceState.haveNext) {
      resourceState.chapterActivatedIndex.value =
          resourceState.chapterActivatedIndex.value + 1;
      uiViewModel.cancelAndRestartTimer();
    }
  }

  Future<void> beforeSeekTo() async {}

  Future<void> afterSeekTo() async {}
}
