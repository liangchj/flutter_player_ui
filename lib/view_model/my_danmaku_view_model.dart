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

  bool get videoIsPlaying => playerViewModel.playerState.isPlaying.value;

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
          parseDanmakuFile();
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
    danmakuState.danmakuView.value = DanmakuScreen(
      createdController: (DanmakuController e) {
        danmakuController = e;
        if (playerViewModel.resourceState.danmakuFilePath.value.isNotEmpty) {
          parseDanmakuFile();
        }
      },
      option: getDanmakuOption(),
    );
    _processDanmakuList();
    return Future.value();
  }

  // 解析弹幕文件
  void parseDanmakuFile({BaseDanmakuParser? parser, bool parseStart = true}) {
    if (playerViewModel.resourceState.danmakuFilePath.value.isEmpty) {
      return;
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
        if (parseStart) {
          startDanmaku();
        }
      }
    });
    parser.parser(
      path: playerViewModel.resourceState.danmakuFilePath.value,
      groupDanmakuMap: groupDanmakuMap,
    );
  }

  void updateOptions() {
    danmakuController?.updateOption(getDanmakuOption());
  }

  // 启动弹幕
  Future<void> startDanmaku() async {
    if (!videoIsPlaying || !danmakuState.isVisible.value) {
      return Future.value();
    }
    if (danmakuController == null) {
      await initDanmaku();
    }
    if (!danmakuController!.running) {
      danmakuController?.resume();
    }
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
  }

  // 暂停弹幕
  void pauseDanmaku() {
    if (danmakuController == null || !danmakuController!.running) {
      return;
    }
    try {
      danmakuController!.pause();
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
    try {
      for (var danmaku in danmakuList) {
        danmakuController!.addDanmaku(danmaku);
      }
    } catch (_) {}
  }

  Future<void> _processDanmakuList() async {
    if (_processingDanmakuList || danmakuController == null) {
      return;
    }
    if (_timeAddDanmakuIsRunning) {
      _processingDanmakuList = false;
      return;
    }
    _processingDanmakuList = true;
    while (playerViewModel.playerState.isPlaying.value &&
        danmakuController!.running) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!playerViewModel.playerState.isPlaying.value ||
          !danmakuController!.running) {
        _timeAddDanmakuIsRunning = false;
        break;
      }
      _timeAddDanmakuIsRunning = true;
      // 计算当前应该处理的时间段
      int currentGroupTime =
          (playerViewModel.playerState.positionDuration.value.inMilliseconds ~/
              intervalTime) *
          intervalTime;
      currentGroupTime += (danmakuState.adjustTime.value * 1000).toInt();
      if (currentGroupTime != prevAddDanmakuTime) {
        if (groupDanmakuMap.containsKey(currentGroupTime)) {
          addDanmaku(groupDanmakuMap[currentGroupTime] ?? []);
        }
        prevAddDanmakuTime = currentGroupTime;
      }
    }
    _processingDanmakuList = false;
  }

  void beforeChangeVideoUrl() {
    groupDanmakuMap.clear();
    stopDanmaku();
    prevAddDanmakuTime = -1;
  }

  void afterChangeVideoUrl(bool staring) {
    if (staring) {
      startDanmaku();
    }
  }
}
