import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_player_ui/controller/my_danmaku_controller.dart';
import 'package:flutter_player_ui/controller/player_controller.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/common_constant.dart';
import '../constant/icon_constant.dart';
import '../constant/style_constant.dart';
import '../enum/player_ui_key_enum.dart';
import '../model/bottom_ui_item_model.dart';
import '../model/overlay_ui_model.dart';
import '../state/danmaku_state.dart';
import '../state/player_state.dart';
import '../state/ui_state.dart';
import '../utils/calculate_color_utils.dart';

class UIController {
  final PlayerController playerController;
  late MyDanmakuController myDanmakuController;
  late UIState uiState;
  DanmakuState get danmakuState => myDanmakuController.danmakuState;
  List<BottomUIItemModel> fullscreenBottomUIItemList = [];

  Color get backgroundColor => StyleConstant.uIBackgroundColor;
  // 获取UI文字颜色（播放器ui控件背景默认是黑色）

  Color get textColor => CalculateColorUtils.calculateTextColor(Colors.black);
  Color get activatedTextColor => StyleConstant.primaryColor;

  Color get buttonColor => StyleConstant.primaryColor;
  Color get buttonFontColor =>
      CalculateColorUtils.calculateTextColor(buttonColor);

  Size? _lastWindowSize; // 缓存上一次的窗口尺寸，避免重复计算
  Timer? hideTimer;
  bool isWeb = kIsWeb;
  PlayerState get playerState => playerController.playerState;
  UIController(this.playerController) {
    uiState = UIState(this);
    myDanmakuController = MyDanmakuController(uiController: this);
    _initBottomControlItemList(textColor);
    _initEffect();
  }

  final List<EffectCleanup> _effectCleanupList = [];

  late final slideUIVisible = Computed(
    () => uiState.speedSettingUI.visible.value,
  );

  void _initEffect() {
    _effectCleanupList.addAll([
      effect(() {
        if (uiState.bottomUI.visible.value) {
          untracked(() {
            _calculateScreenSize(uiState.uiSize.value);
          });
        }
      }),
      effect(() {
        bool show =
            uiState.settingUI.visible.value ||
            uiState.danmakuSettingUI.visible.value ||
            uiState.speedSettingUI.visible.value ||
            uiState.chapterListUI.visible.value ||
            uiState.apiSourceUI.visible.value;
        if (show) {
          untracked(() {
            checkOrientationAndPosition(uiState.uiSize.value);
          });
        }
      }),
      effect(() {
        var value = uiState.danmakuSettingUI.visible.value;
        untracked(() {
          danmakuState.uiShowAdjustTime.value = danmakuState.adjustTime.value;
        });
      }),
    ]);
  }

  void dispose() {
    hideTimer?.cancel();
    uiState.dispose();
    for (var e in _effectCleanupList) {
      e.call();
    }
  }

  void _initBottomControlItemList(Color textColor) {
    fullscreenBottomUIItemList = [
      BottomUIItemModel(
        type: ControlType.play,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 1,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          color: StyleConstant.iconColor,
          onPressed: () => playerController.playOrPause(),
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
        visible: Signal(true),
      ),
      BottomUIItemModel(
        type: ControlType.next,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 2,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          color: StyleConstant.iconColor,
          // onPressed: () => nextPlay(),
          onPressed: () => {},
          icon: IconConstant.nextPlayIcon,
        ),
        /*child: Obx(
              () => resourcePlayState.haveNext
              ? IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            color: StyleConstant.iconColor,
            // onPressed: () => nextPlay(),
            onPressed: () => {},
            icon: IconCommons.nextPlayIcon,
          )
              : Container(),
        ),*/
        visible: Signal(true),
      ),
      /*BottomUIItemModel(
        type: ControlType.sendDanmaku,
        fixedWidth: 76,
        priority: 5,
        child: TextButton(onPressed: () {}, child: Text("发送弹幕", style: TextStyle(color: textColor))),
      ),*/
      BottomUIItemModel(
        type: ControlType.danmaku,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 6,
        child: Watch(
              (context) => Stack(
            children: [
              IconButton(
                onPressed: () => {
                  danmakuState.isVisible.value =
                  !danmakuState.isVisible.value,
                },
                icon: danmakuState.isVisible.value
                    ? IconConstant.danmakuOpen
                    : IconConstant.danmakuClose,
                color: danmakuState.isVisible.value
                    ? activatedTextColor
                    : textColor,
              ),
              if (danmakuState.isVisible.value)
                Positioned(
                  right: 9.5,
                  bottom: 9.5,
                  child: Material(
                    color: Colors.white,
                    shape: CircleBorder(),
                    child: SizedBox(height: 5.5, width: 5.5),
                  ),
                ),
            ],
          ),
        ),
        visible: signal(true),
      ),
      BottomUIItemModel(
        type: ControlType.danmakuSetting,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 6,
        child: IconButton(
          onPressed: () => {
            onlyShowUIByKeyList([
              UIKeyEnum.danmakuSettingUI.name,
            ], ignoreLimit: true),
          },
          icon: IconConstant.danmakuSetting,
          color: textColor,
        ),
        visible: signal(true),
      ),
      BottomUIItemModel(
        type: ControlType.none,
        fixedWidth: 0,
        priority: 4,
        visible: Signal(true),
        child: Expanded(child: Container()),
      ),
      /*BottomUIItemModel(
        type: ControlType.source,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 5,
        child: Obx(() {
          */
      /*if (resourcePlayState.playSourceCount <= 1 &&
              resourcePlayState.sourceGroupCount <= 1) {
            return Container();
          }*/
      /*
          return IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            color: StyleConstant.iconColor,
            onPressed: () => {
              // onlyShowUIByKeyList([PlayerUIKeyEnum.sourceUI.name]),
            },
            icon: Icon(Icons.source_rounded),
          );
        }),
      ),*/
      BottomUIItemModel(
        type: ControlType.chapter,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 4,
        child: IconButton(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          color: StyleConstant.iconColor,
          onPressed: () => {
            onlyShowUIByKeyList([UIKeyEnum.chapterListUI.name]),
          },
          icon: Icon(Icons.list),
        ),
        /*child: Obx(
              () => resourcePlayState.activatedChapterList.length > 1
              ? IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            color: WidgetStyleCommons.iconColor,
            onPressed: () => {
              onlyShowUIByKeyList([PlayerUIKeyEnum.chapterListUI.name]),
            },
            icon: Icon(Icons.list),
          )
              : Container(),
        ),*/
        visible: Signal(true),
      ),
      BottomUIItemModel(
        type: ControlType.speed,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 3,
        child: TextButton(
          onPressed: () => onlyShowUIByKeyList([UIKeyEnum.speedSettingUI.name]),
          child: Watch(
            (context) => Text(
              "${playerState.playSpeed.value}x",
              style: TextStyle(color: textColor),
            ),
          ),
        ),
        visible: Signal(true),
      ),
      BottomUIItemModel(
        type: ControlType.exitOrEntryFullscreen,
        fixedWidth: StyleConstant.bottomBtnSize,
        priority: 1,
        child: Watch(
          (context) =>
              playerState
                  .isFullscreen
                  .value //&& !onlyFullscreen
              ? IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  color: textColor,
                  onPressed: () {
                    // fullscreenUtils.toggleFullscreen();
                  },
                  icon: Icon(Icons.fullscreen_exit_rounded),
                )
              : Container(),
        ),
        visible: Signal(true),
      ),
    ];
  }

  Future<void> handleScreenChange(Size size) async {
    // 1. 尺寸未变化，直接返回
    if (_lastWindowSize == size) return;
    _lastWindowSize = size;
    await Future.delayed(Duration.zero);
    if (uiState.bottomUI.visible.value) {
      _calculateScreenSize(size);
    }
    // 2. 屏幕方向调整的
    if (uiState.settingUI.visible.value ||
        uiState.danmakuSettingUI.visible.value ||
        uiState.chapterListUI.visible.value ||
        uiState.speedSettingUI.visible.value ||
        uiState.apiSourceUI.visible.value) {
      checkOrientationAndPosition(size);
    }
    /*if (uiState.speedSettingUI.visible.value) {
      checkOrientationAndPosition(size);
    }*/
  }

  double? _lastWindowWidth;
  void _calculateScreenSize(Size size) {
    untracked(() {
      if (_lastWindowWidth != null && _lastWindowWidth == size.width) {
        return;
      }
      _lastWindowWidth = size.width;
      if (playerState.isFullscreen.value) {
        final availableWidth =
            size.width - StyleConstant.safeSpace * 2; // 减去左右边距
        final sortControls =
            fullscreenBottomUIItemList
                .where((item) => item.type != ControlType.none)
                .toList()
              ..sort((a, b) => a.priority.compareTo(b.priority));
        double currentWidth = 0.0;
        for (final control in sortControls) {
          final needWidth = currentWidth + control.fixedWidth + 8; // 预留 margin
          if (needWidth <= availableWidth) {
            control.visible.value = true;
            currentWidth = needWidth;
          } else {
            control.visible.value = false;
          }
        }

        // 确保至少有一个按钮显示（如播放/暂停）
        if (sortControls.isEmpty) return;
        final playButton = sortControls.firstWhere(
          (c) => c.type == ControlType.play,
        );
        if (!playButton.visible.value && availableWidth > 0) {
          playButton.visible.value = true;
        }
      }
    });
  }

  Size? _lastOrientationSize;
  // 检查弹窗位置逻辑
  void checkOrientationAndPosition(Size size) {
    untracked(() {
      if (_lastOrientationSize != null && _lastOrientationSize == size) {
        return;
      }
      _lastOrientationSize = size;
      if (!playerState.isFullscreen.value) {
        uiState.portraitShow.value = true;
        return;
      }
      uiState.portraitShow.value = size.width < size.height * 0.8; // 类竖屏判断
      if (!uiState.portraitShow.value) {
        const itemWidth = 80.0;
        const requiredWidth = itemWidth * 4; // 4个选项的宽度需求
        final maxRightPanelWidth = size.width * 0.7; // 右侧弹窗最大宽度

        // 决定弹窗方向
        uiState.portraitShow.value = requiredWidth > maxRightPanelWidth;
      }

      double? height;
      double? maxHeight;

      double? width;
      double? speedWidth;
      double? maxWidth;
      if (uiState.portraitShow.value) {
        height = StyleConstant.uiDefaultHeight.clamp(
          uiState.uiSize.value.height * 0.3,
          uiState.uiSize.value.height * 0.8,
        );
        maxHeight = uiState.uiSize.value.height * 0.8;
      } else {
        width = StyleConstant.uiDefaultWidth.clamp(
          uiState.uiSize.value.width * 0.3,
          uiState.uiSize.value.width * 0.8,
        );
        speedWidth = StyleConstant.speedSettingUIDefaultWidth.clamp(
          uiState.uiSize.value.width * 0.3,
          uiState.uiSize.value.width * 0.8,
        );
        maxWidth = uiState.uiSize.value.width * 0.8;
      }
      uiState.commonUISizeModel.value =
          uiState.commonUISizeModel.value.copyWith(
            height: height,
            maxHeight: maxHeight,
            width: width,
            maxWidth: maxWidth,
          );
      uiState.speedUIWidth.value = speedWidth;
    });
  }

  /// ui控制部分
  // 清除定时器
  void cancelHideTimer() {
    hideTimer?.cancel();
  }

  // 开始计时UI显示时间
  void startHideTimer() {
    hideTimer = Timer(CommonConstant.uiShowDuration, () {
      hideUIByKeyList(uiState.touchBackgroundShowUIKeyList);
      // 防止没有清除的定时器
      hideTimer?.cancel();
    });
  }

  // 重新计算显示/隐藏UI计时器
  void cancelAndRestartTimer() {
    cancelHideTimer();
    startHideTimer();
  }

  /// 点击背景
  void toggleBackground() {
    if (haveUIShow()) {
      hideTimer?.cancel();
      hideUIByKeyList(
        uiState.dynamicOverlayUIList
            .where((e) => !uiState.notTouchCtrlKeyList.contains(e.name))
            .toList()
            .map((e) => e.name)
            .toList(),
      );
    } else {
      cancelHideTimer();
      onlyShowUIByKeyList(
        uiState.uiLocked.value
            ? [UIKeyEnum.lockCtrUI.name]
            : uiState.touchBackgroundShowUIKeyList,
      );
      startHideTimer();
    }
  }

  /// 只显示指定key值显示UI
  void onlyShowUIByKeyList(List<String> keyList, {bool ignoreLimit = false}) {
    List<String> hideList = [];
    for (OverlayUIModel uiModel in uiState.dynamicOverlayUIList.value) {
      if (!ignoreLimit && uiState.notTouchCtrlKeyList.contains(uiModel.name)) {
        continue;
      }
      if (!keyList.contains(uiModel.name)) {
        hideList.add(uiModel.name);
        continue;
      }
      uiModel.visible.value = true;
      if (uiModel.useAnimationController) {
        uiModel.animateController.value?.forward();
      }
    }
    if (hideList.isNotEmpty) {
      hideUIByKeyList(hideList);
    }
  }

  /// 根据Key值显示UI
  void showUIByKeyList(List<String> keyList) {
    for (var key in keyList) {
      OverlayUIModel? element = uiState.dynamicOverlayUIList.value
          .firstWhereOrNull((element) => element.name == key);
      if (element == null) {
        continue;
      }
      element.visible.value = true;
      if (element.useAnimationController) {
        element.animateController.value?.forward();
      }
    }
  }

  /// 根据Key值隐藏ui
  void hideUIByKeyList(List<String> keyList) {
    if (keyList.isEmpty) {
      return;
    }
    for (OverlayUIModel uiModel in uiState.dynamicOverlayUIList.value) {
      if (!keyList.contains(uiModel.name)) {
        continue;
      }
      uiModel.visible.value = false;
      if (uiModel.useAnimationController) {
        uiModel.animateController.value?.reverse();
      }
    }

    bool haveToggleBackgroundUI = false;
    for (String key in keyList) {
      if (uiState.touchBackgroundShowUIKeyList.contains(key)) {
        haveToggleBackgroundUI = true;
        break;
      }
    }
    if (haveToggleBackgroundUI) {
      hideTimer?.cancel();
    }
  }

  /// 是否有UI显示（除了特殊的UI）
  bool haveUIShow({bool ignoreLimit = false}) {
    bool flag = false;
    for (OverlayUIModel uiModel in uiState.dynamicOverlayUIList.value) {
      if (!ignoreLimit && uiState.notTouchCtrlKeyList.contains(uiModel.name)) {
        continue;
      }

      if (uiModel.visible.value) {
        flag = true;
        break;
      }
    }
    return flag;
  }

  /// 滑动进度
  Timer? _progressTimer;
  // 开始拖动播放进度条
  void playProgressOnHorizontalDragStart() {
    if (!playerState.isInitialized.value ||
        playerState.errorMsg.value.isNotEmpty ||
        playerState.isFinished.value) {
      return;
    }
    _progressTimer?.cancel();
    // 标记拖动状态
    playerState.isDragging.value = true;
    // 初始化拖动值
    playerState.draggingSecond.value = 0;
    // 清除前一次拖动剩余
    playerState.draggingSurplusSecond = 0.0;
    // 记录开始拖动时的时间
    playerState.dragProgressPositionDuration =
        playerState.positionDuration.value;
    //显示拖动进度UI
    onlyShowUIByKeyList([UIKeyEnum.centerProgressUI.name], ignoreLimit: true);
  }

  // 拖动播放进度条中
  void playProgressOnHorizontalDragUpdate(BuildContext context, Offset delta) {
    if (!playerState.isInitialized.value ||
        playerState.errorMsg.isNotEmpty ||
        playerState.isFinished.value) {
      hideUIByKeyList([UIKeyEnum.centerProgressUI.name]);
      return;
    }
    _progressTimer?.cancel();
    double width = MediaQuery.of(context).size.width;
    // 获取拖动了多少秒
    double dragSecond =
        (delta.dx / width) * 100 + playerState.draggingSurplusSecond;
    // 拖动秒数向下取整
    int dragValue = dragSecond.floor();
    // 记录本次拖动取整后剩余
    playerState.draggingSurplusSecond = dragSecond - dragValue;
    // 更新拖动值
    playerState.draggingSecond.value =
        playerState.draggingSecond.value + dragValue;
    //显示拖动进度UI
    onlyShowUIByKeyList([UIKeyEnum.centerProgressUI.name], ignoreLimit: true);
  }

  // 拖动播放进度结束
  void playProgressOnHorizontalDragEnd() {
    if (!playerState.isInitialized.value ||
        playerState.errorMsg.isNotEmpty ||
        playerState.isFinished.value) {
      hideUIByKeyList([UIKeyEnum.centerProgressUI.name]);
      return;
    }
    // 清除拖动标记
    playerState.isDragging.value = false;
    // 清除前一次拖动剩余值
    playerState.draggingSurplusSecond = 0.0;
    // 更新本次拖动值
    var second =
        playerState.dragProgressPositionDuration.inSeconds +
        playerState.draggingSecond.value;
    playerController.seekTo(Duration(seconds: second.abs() > 0 ? second : 0));
    // 定时隐藏拖动进度ui
    _progressTimer = Timer.periodic(
      CommonConstant.volumeOrBrightnessUIShowDuration,
      (timer) {
        _progressTimer?.cancel();
        playerState.draggingSecond.value = 0;
        playerState.dragProgressPositionDuration =
            playerState.positionDuration.value;
        hideUIByKeyList([UIKeyEnum.centerProgressUI.name]);
      },
    );
  }

  /// 音量和亮度
  Timer? _volumeTimer;
  Timer? _brightnessTimer;
  // 垂直滑动开始
  void volumeOrBrightnessOnVerticalDragStart(
    BuildContext context,
    DragStartDetails details,
  ) {
    if (isWeb) {
      return;
    }
    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();
    playerState.isBrightnessDragging.value = false;
    playerState.isVolumeDragging.value = false;
    double width = MediaQuery.of(context).size.width;
    String showUIKey;
    if (details.globalPosition.dx > (width / 2)) {
      /*FlutterVolumeController.updateShowSystemUI(false);
      FlutterVolumeController.getVolume().then(
            (value) => playerState.volume.value = ((value ?? 0) * 100).floor(),
      );*/
      playerState.isVolumeDragging.value = true;
      showUIKey = UIKeyEnum.centerVolumeUI.name;
      hideUIByKeyList([UIKeyEnum.centerBrightnessUI.name]);
    } else {
      // 获取当前亮度
      /*ScreenBrightness.instance.application.then(
            (value) => playerState.brightness((value * 100).floor()),
      );*/
      playerState.isBrightnessDragging.value = true;
      showUIKey = UIKeyEnum.centerBrightnessUI.name;
      hideUIByKeyList([UIKeyEnum.centerVolumeUI.name]);
    }
    playerState.verticalDragSurplus = 0.0;
    onlyShowUIByKeyList([showUIKey], ignoreLimit: true);
  }

  // 垂直滑动中
  void volumeOrBrightnessOnVerticalDragUpdate(
    BuildContext context,
    DragUpdateDetails details,
  ) {
    if (isWeb) {
      return;
    }
    _volumeTimer?.cancel();
    _brightnessTimer?.cancel();
    double height = MediaQuery.of(context).size.height;
    // 使用百分率
    // 当前拖动值
    double currentDragVal = (details.delta.dy / height) * 100;
    double totalDragValue = currentDragVal + playerState.verticalDragSurplus;
    int dragValue = totalDragValue.floor();
    playerState.verticalDragSurplus = totalDragValue - dragValue;
    String showUIKey = "";
    if (playerState.isVolumeDragging.value) {
      // 设置音量
      playerState.volume.value = (playerState.volume.value - dragValue).clamp(
        0,
        100,
      );
      // FlutterVolumeController.updateShowSystemUI(false);
      // FlutterVolumeController.setVolume(playerState.volume / 100.0);
      showUIKey = UIKeyEnum.centerVolumeUI.name;
      hideUIByKeyList([UIKeyEnum.centerBrightnessUI.name]);
    } else if (playerState.isBrightnessDragging.value) {
      // 设置亮度
      playerState.brightness.value = (playerState.brightness.value - dragValue)
          .clamp(0, 100);
      // ScreenBrightness.instance.setApplicationScreenBrightness(
      //   playerState.brightness / 100.0,
      // );
      showUIKey = UIKeyEnum.centerBrightnessUI.name;
      hideUIByKeyList([UIKeyEnum.centerVolumeUI.name]);
    }
    onlyShowUIByKeyList([showUIKey], ignoreLimit: true);
  }

  // 垂直滑动结束
  void volumeOrBrightnessOnVerticalDragEnd() {
    if (isWeb) {
      return;
    }
    if (playerState.isBrightnessDragging.value) {
      _brightnessTimer = Timer(
        CommonConstant.volumeOrBrightnessUIShowDuration,
        () {
          _brightnessTimer?.cancel();
          hideUIByKeyList([UIKeyEnum.centerBrightnessUI.name]);
        },
      );
    }
    if (playerState.isVolumeDragging.value) {
      _volumeTimer = Timer(CommonConstant.volumeOrBrightnessUIShowDuration, () {
        _volumeTimer?.cancel();
        hideUIByKeyList([UIKeyEnum.centerVolumeUI.name]);
      });
    }
    playerState.isBrightnessDragging.value = false;
    playerState.isVolumeDragging.value = false;
    playerState.verticalDragSurplus = 0.0;
  }
}
