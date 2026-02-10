import 'dart:async';
import 'dart:convert';

import 'package:canvas_danmaku/danmaku_controller.dart';
import 'package:canvas_danmaku/danmaku_screen.dart';
import 'package:canvas_danmaku/models/danmaku_content_item.dart';
import 'package:canvas_danmaku/models/danmaku_option.dart';
import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../constant/key_constant.dart';
import '../danmaku_parser/base_danmaku_parser.dart';
import '../danmaku_parser/bili_danmaku_parser.dart';
import '../interface/player_data_storage.dart';
import '../state/danmaku_state.dart';
import 'base_view_model.dart';
import 'player_view_model.dart';
import 'ui_view_model.dart';

class MyDanmakuViewModel extends BaseViewModel {
  final UIViewModel uiViewModel;
  MyDanmakuViewModel({required this.uiViewModel}) {
    _init();
  }

  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;
  PlayerDataStorage? get dataStorage => playerViewModel.dataStorage;

  late DanmakuState danmakuState;

  bool get videoIsPlaying =>
      !playerViewModel.disposed &&
      !playerViewModel.playerState.disposed &&
      !playerViewModel.playerState.isPlaying.disposed &&
      playerViewModel.playerState.isPlaying.value;

  Color get textColor => uiViewModel.textColor;
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  // 弹幕设置
  Map<String, dynamic> _settings = {};

  DanmakuController? danmakuController;

  Map<int, List<DanmakuContentItem>> groupDanmakuMap = {};
  int prevAddDanmakuTime = -1;
  // 间隔显示弹幕时间（毫秒）
  int intervalTime = 500;
  // 防止重复启动处理循环
  bool _processingDanmakuList = false;
  bool _timeAddDanmakuIsRunning = false;

  Completer<void>? _initializingCompleter;

  final List<EffectCleanup> _effectCleanupList = [];

  void _init() {
    danmakuState = DanmakuState();
    _effectCleanupList.addAll([
      effect(() {
        var value = danmakuState.isVisible.value;
        untracked(() {
          if (value) {
            startDanmaku();
          } else {
            pauseDanmaku();
            clearDanmaku();
          }
          saveSettings();
        });
      }),
      effect(() {
        var danmakuAlphaRatio = danmakuState.danmakuAlphaRatio.value;
        var danmakuArea = danmakuState.danmakuArea.value;
        var danmakuFontSize = danmakuState.danmakuFontSize.value;
        var danmakuSpeed = danmakuState.danmakuSpeed.value;
        var playSpeed = playerViewModel.playerState.playSpeed.value;
        double? adjustTime = danmakuState.adjustTime.value;
        untracked(() {
          updateOptions();
          saveSettings();
        });
      }),
      ...danmakuState.danmakuFilterTypeList.map((e) {
        return effect(() {
          untracked(() {
            var filter = e.filter.value;
            untracked(() {
              updateOptions();
              saveSettings();
            });
          });
        });
      }),

      effect(() {
        var value = playerViewModel.resourceState.danmakuFilePath.value;
        untracked(() {
          if (value.isNotEmpty) {
            parseDanmakuFile();
          }
        });
      }),
    ]);

    _initSettings();
  }

  @override
  void dispose() {
    for (var e in _effectCleanupList) {
      e.call();
    }
    danmakuController?.pause();
    danmakuController?.clear();
    danmakuState.danmakuView.value = SizedBox.shrink();
    disposed = true;
  }

  // 初始化配置
  Future<void> _initSettings() async {
    if (dataStorage == null) {
      return;
    }
    String? settingStr = await dataStorage!.getSetting<String?>(
      KeyConstant.danmakuSettingKey,
    );
    if (settingStr == null || settingStr.isEmpty) {
      return;
    }
    try {
      _settings = Map.from(jsonDecode(settingStr));
    } catch (e) {
      return;
    }
    if (_settings.isEmpty) {
      return;
    }
    // 弹幕是否可见
    bool? isVisible = _settings[KeyConstant.danmakuIsVisibleKey];
    if (isVisible != null) {
      danmakuState.isVisible.value = isVisible;
    }
    // 设置字体透明度
    double? danmakuAlphaRatio = _settings[KeyConstant.danmakuAlphaRatioKey];
    if (danmakuAlphaRatio != null) {
      danmakuState.danmakuAlphaRatio.value = danmakuState
          .danmakuAlphaRatio
          .value
          .copyWith(ratio: danmakuAlphaRatio);
    }
    // 设置字体大小
    double? danmakuFontSize = _settings[KeyConstant.danmakuFontSizeKey];
    if (danmakuFontSize != null) {
      danmakuState.danmakuFontSize.value = danmakuState.danmakuFontSize.value
          .copyWith(fontSize: danmakuFontSize);
    }

    // 设置弹幕显示区域
    int? danmakuArea = _settings[KeyConstant.danmakuAreaKey];
    if (danmakuArea != null) {
      danmakuState.danmakuArea.value = danmakuState.danmakuArea.value.copyWith(
        areaIndex: danmakuArea,
      );
    }

    // 设置弹幕速度
    double? danmakuSpeed = _settings[KeyConstant.danmakuSpeedKey];
    if (danmakuSpeed != null) {
      danmakuState.danmakuSpeed.value = danmakuState.danmakuSpeed.value
          .copyWith(speed: danmakuSpeed);
    }

    // 设置弹幕过滤类型
    List<String>? danmakuFilterTypeList =
        _settings[KeyConstant.danmakuFilterTypeListKey];
    if (danmakuFilterTypeList != null) {
      for (var item in danmakuState.danmakuFilterTypeList) {
        item.filter.value = danmakuFilterTypeList.contains(item.enName);
      }
    }

    // 弹幕过滤关键词

    // 弹幕调整时间
    double? adjustTime = _settings[KeyConstant.adjustTimeKey];
    if (adjustTime != null) {
      danmakuState.adjustTime.value = adjustTime;
    }
  }

  // 保存弹幕设置
  void saveSettings() async {
    untracked(() {
      _settings[KeyConstant.danmakuIsVisibleKey] = danmakuState.isVisible.value;
      _settings[KeyConstant.danmakuAlphaRatioKey] =
          danmakuState.danmakuAlphaRatio.value.ratio;
      _settings[KeyConstant.danmakuAreaKey] =
          danmakuState.danmakuArea.value.areaIndex;
      _settings[KeyConstant.danmakuFontSizeKey] =
          danmakuState.danmakuFontSize.value.fontSize;
      var danmakuSpeed = danmakuState.danmakuSpeed.value;
      var playSpeed = playerViewModel.playerState.playSpeed.value;
      double speed = danmakuSpeed.speed / playSpeed;
      _settings[KeyConstant.danmakuSpeedKey] = speed;
      _settings[KeyConstant.adjustTimeKey] = danmakuState.adjustTime.value;
      List<String> danmakuFilterTypeEnNameList = [];
      for (var item in danmakuState.danmakuFilterTypeList) {
        if (item.filter.value) {
          danmakuFilterTypeEnNameList.add(item.enName);
        }
      }
      _settings[KeyConstant.danmakuFilterTypeListKey] =
          danmakuFilterTypeEnNameList;
    });
    await dataStorage?.saveSetting<Map<String, dynamic>>(
      KeyConstant.danmakuSettingKey,
      _settings,
    );
  }

  void updateOptions() {
    danmakuController?.updateOption(getDanmakuOption());
  }

  DanmakuOption getDanmakuOption() {
    bool hideScroll = false;
    bool hideTop = false;
    bool hideBottom = false;
    bool hideSpecial = false;

    for (var item in danmakuState.danmakuFilterTypeList) {
      if (item.filter.value) {
        switch (item.enName) {
          case "hideScroll":
            hideScroll = true;
            break;
          case "hideTop":
            hideTop = true;
            break;
          case "hideBottom":
            hideBottom = true;
            break;
          case "hideSpecial":
            hideSpecial = true;
            break;
        }
      }
    }

    return (danmakuController?.option ?? DanmakuOption()).copyWith(
      opacity: danmakuState.danmakuAlphaRatio.value.ratio / 100.0,
      area: danmakuState
          .danmakuArea
          .value
          .danmakuAreaItemList[danmakuState.danmakuArea.value.areaIndex]
          .area,
      massiveMode: !danmakuState
          .danmakuArea
          .value
          .danmakuAreaItemList[danmakuState.danmakuArea.value.areaIndex]
          .filter,
      fontSize: danmakuState.danmakuFontSize.value.fontSize,
      duration:
          danmakuState.danmakuSpeed.value.speed /
          playerViewModel.playerState.playSpeed.value,
      hideSpecial: hideSpecial,
      hideScroll: hideScroll,
      hideTop: hideTop,
      hideBottom: hideBottom,
    );
  }

  // 初始化弹幕
  Future<void> initDanmaku() async {
    // 如果正在初始化，则等待初始化完成
    if (_initializingCompleter != null) {
      return _initializingCompleter!.future;
    }

    // 标记为正在初始化
    _initializingCompleter = Completer<void>();

    try {
      final completer = Completer<void>();
      danmakuState.danmakuView.value = DanmakuScreen(
        createdController: (DanmakuController e) {
          danmakuController = e;
          completer.complete();
        },
        option: getDanmakuOption(),
      );
      await completer.future;
      startDanmakuProcessing();
    } finally {
      // 初始化完成，重置状态
      _initializingCompleter?.complete();
      _initializingCompleter = null;
    }
    /*final completer = Completer<void>(); // 创建 Completer
    danmakuState.danmakuView.value = DanmakuScreen(
      createdController: (DanmakuController e) {
        danmakuController = e;
        completer.complete();
      },
      option: getDanmakuOption(),
    );
    await completer.future;
    startDanmakuProcessing();
    return Future.value();*/
  }

  // 解析弹幕文件
  Future<void> parseDanmakuFile({
    BaseDanmakuParser? parser,
    bool parseStart = true,
  }) async {
    if (disposed) return;
    if (playerViewModel.resourceState.danmakuFilePath.value.isEmpty) {
      return;
    }
    if (danmakuController == null &&
        danmakuState.danmakuView.value is! DanmakuScreen) {
      await initDanmaku();
    }
    parser ??= BiliDanmakuParser(
      options: BiliDanmakuParseOptions(
        parentTag: "i",
        contentTag: "d",
        attrName: "p",
        splitChar: ",",
        intervalTime: intervalTime,
      ),
    );
    parser.stateController.stream.listen((event) {
      if (event.status == ParserStatus.completed) {
        // 解析完成后，根据条件决定是否启动弹幕播放
        if (parseStart && videoIsPlaying && danmakuState.isVisible.value) {
          startDanmakuProcessing(); // 启动弹幕处理循环
        }
      }
    });
    parser.parser(
      path: playerViewModel.resourceState.danmakuFilePath.value,
      groupDanmakuMap: groupDanmakuMap,
    );
  }

  // 启动弹幕
  Future<void> startDanmaku() async {
    if (!videoIsPlaying || !danmakuState.isVisible.value) {
      return Future.value();
    }
    if (danmakuController == null &&
        danmakuState.danmakuView.value is! DanmakuScreen) {
      await initDanmaku();
    }

    if (!danmakuController!.running) {
      danmakuController?.resume();
    }
    startDanmakuProcessing(); // 启动弹幕处理循环
  }

  // 恢复弹幕
  Future<void> resumeDanmaku() async {
    if (!videoIsPlaying ||
        !danmakuState.isVisible.value ||
        danmakuController == null ||
        danmakuController!.running) {
      return;
    }
    danmakuController?.resume();
    startDanmakuProcessing();
  }

  // 暂停弹幕
  void pauseDanmaku() {
    if (danmakuController == null || !danmakuController!.running) {
      return;
    }
    try {
      danmakuController?.pause();
      _processingDanmakuList = false;
    } catch (_) {}
  }

  // 停止弹幕
  void stopDanmaku() {
    try {
      danmakuController?.pause();
      danmakuController?.clear();
      _processingDanmakuList = false;
    } catch (_) {}
  }

  // 清空弹幕
  void clearDanmaku() {
    prevAddDanmakuTime = -1;
    try {
      danmakuController?.clear();
    } catch (_) {}
  }

  // 跳转到指定时间
  void seekToDanmaku(int position) {
    prevAddDanmakuTime = -1;
    if (danmakuController == null) {
      return;
    }
    try {
      danmakuController?.clear();
    } catch (_) {}
  }

  // 调整时间
  /*void adjustTime(int value) {
    return;
  }*/

  void addDanmaku(List<DanmakuContentItem> danmakuList) {
    if (danmakuController == null || disposed) return;
    try {
      for (var danmaku in danmakuList) {
        danmakuController?.addDanmaku(danmaku);
      }
    } catch (_) {}
  }

  // 启动弹幕播放逻辑
  Future<void> startDanmakuProcessing() async {
    if (_processingDanmakuList ||
        danmakuController == null ||
        !danmakuController!.running) {
      return;
    }

    // 只有在视频播放且弹幕可见时才启动处理循环
    if (!danmakuState.isVisible.value) {
      return;
    }

    if (!videoIsPlaying) {
      return;
    }

    if (_timeAddDanmakuIsRunning) {
      _processingDanmakuList = false;
      return;
    }
    _processingDanmakuList = true;
    await _processDanmakuList();
  }

  Future<void> _processDanmakuList() async {
    int prevStartTime = 0; // 上一次循环开始的时间戳
    while (!disposed &&
        videoIsPlaying &&
        danmakuController != null &&
        danmakuController!.running) {
      _timeAddDanmakuIsRunning = true;

      var now = DateTime.now().millisecondsSinceEpoch;
      int timeConsumed = now - prevStartTime; // 计算上一次循环的真实耗时
      int delayTime = intervalTime - timeConsumed; // 动态计算延迟时间
      if (delayTime > 0) {
        await Future.delayed(Duration(milliseconds: delayTime));
      }
      if (disposed ||
          !videoIsPlaying ||
          danmakuController == null ||
          !danmakuController!.running) {
        _timeAddDanmakuIsRunning = false;
        break;
      }

      // 计算当前应该处理的时间段
      int currentGroupTime = getCurrentGroupTime();
      if (currentGroupTime != prevAddDanmakuTime) {
        if (groupDanmakuMap.containsKey(currentGroupTime)) {
          addDanmaku(groupDanmakuMap[currentGroupTime] ?? []);
        }
        prevAddDanmakuTime = currentGroupTime;
      }
      prevStartTime = DateTime.now().millisecondsSinceEpoch; // 更新本次循环开始时间
    }
    _processingDanmakuList = false;
  }

  int getCurrentGroupTime() {
    // 获取当前播放时间（毫秒）
    int currentTime =
        playerViewModel.playerState.positionDuration.value.inMilliseconds;

    // 将弹幕添加到 groupDanmakuMap 中
    int groupTime = (currentTime ~/ intervalTime) * intervalTime;
    groupTime += (danmakuState.adjustTime.value * 1000).toInt();
    return groupTime;
  }

  // 手动发送弹幕
  void sendCustomDanmaku(List<DanmakuContentItem> danmakuList) {
    if (danmakuController == null || disposed) {
      return;
    }
    int groupTime = getCurrentGroupTime();
    if (!groupDanmakuMap.containsKey(groupTime)) {
      groupDanmakuMap[groupTime] = [];
    }
    groupDanmakuMap[groupTime]!.addAll(danmakuList);
    addDanmaku(danmakuList);
  }

  void beforeChangeVideoUrl() {
    if (disposed) return;
    groupDanmakuMap.clear();
    stopDanmaku();
    prevAddDanmakuTime = -1;
  }

  void afterChangeVideoUrl(bool staring) {
    if (disposed) return;
    if (staring) {
      startDanmaku();
    }
  }
}
