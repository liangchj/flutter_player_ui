import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../constant/common_constant.dart';
import '../constant/key_constant.dart';
import '../constant/position_constant.dart';
import '../constant/tween_constant.dart';
import '../enum/player_ui_key_enum.dart';
import '../model/overlay_ui_model.dart';
import '../model/ui_size_model.dart';
import '../ui/api_source_ui.dart';
import '../ui/background_event_ui.dart';
import '../ui/bottom_ui.dart';
import '../ui/brightness_ui.dart';
import '../ui/center_play_progress_ui.dart';
import '../ui/chapter_list_ui.dart';
import '../ui/danmaku_setting_ui.dart';
import '../ui/lock_ctr_ui.dart';
import '../ui/play_speed_ui.dart';
import '../ui/screenshot_ui.dart';
import '../ui/setting_ui.dart';
import '../ui/top_ui.dart';
import '../ui/volume_ui.dart';
import '../view_model/ui_view_model.dart';
import 'base_state.dart';

class UIState extends BaseState {
  final UIViewModel uiViewModel;
  UIState(this.uiViewModel) {
    fixedOverlayUIList.add(
      Positioned.fill(
        key: ValueKey(KeyConstant.backgroundEventUIKey),
        child: BackgroundEventUI(uiViewModel: uiViewModel),
      ),
    );
    _init();
    _tickerProviderEffectCleanup = effect(() {
      if (tickerProvider.value != null) {
        untracked(() {
          for (var element in dynamicOverlayUIList.value) {
            if (element.useAnimationController) {
              element.animateController.value = AnimationController(
                vsync: tickerProvider.value!,
                duration: const Duration(milliseconds: 500),
              );
            }
          }
        });
      }
    });
  }
  // 锁住ui
  final Signal<bool> uiLocked = Signal(false);
  final Signal<TickerProvider?> tickerProvider = Signal(null);
  final Signal<List<OverlayUIModel>> dynamicOverlayUIList = Signal([]);
  EffectCleanup? _tickerProviderEffectCleanup;
  /*OverlayUiState() {
    _tickerProviderEffectCleanup = effect(() {

    });
  }*/

  // ui大小
  final Signal<Size> uiSize = Signal(Size.zero);

  // 通用ui大小
  final Signal<UISizeModel> commonUISizeModel = Signal(
    UISizeModel(width: 0, height: 0, maxWidth: 0, maxHeight: 0),
  );

  final Signal<double?> speedUIWidth = Signal(null);

  final List<Widget> fixedOverlayUIList = [
    // Positioned.fill(key: ValueKey("danmakuUIKey"), child: DanmakuUI()),
    /*Positioned.fill(
      key: ValueKey("backgroundEventUIKey"),
      child: BackgroundEventUI(uiController: uiController,),
    ),*/
  ];

  List<Widget> get overlayUIList => [
    ...fixedOverlayUIList,
    ...dynamicOverlayUIList.map((e) => e.ui),
  ];

  /// 点击背景时需要显示的UI列表（一般是顶部、底部、左边锁键和右边截图按钮，在报错情况下只显示顶部）
  List<String> touchBackgroundShowUIKeyList = [
    UIKeyEnum.topUI.name,
    UIKeyEnum.bottomUI.name,
    UIKeyEnum.lockCtrUI.name,
    UIKeyEnum.screenshotCtrUI.name,
  ];

  /// 自己控制的ui，不受其他ui影响
  final List<String> notTouchCtrlKeyList = [
    UIKeyEnum.centerLoadingUI.name,
    UIKeyEnum.centerProgressUI.name,
    UIKeyEnum.centerVolumeUI.name,
    UIKeyEnum.centerBrightnessUI.name,
    UIKeyEnum.centerErrorUI.name,
    UIKeyEnum.leftBottomHitUI.name,
    UIKeyEnum.restartUI.name,
  ];

  /// 拦截路由UI列表
  List<String> interceptRouteUIKeyList = [
    UIKeyEnum.settingUI.name,
    UIKeyEnum.speedSettingUI.name,
    UIKeyEnum.chapterListUI.name,
    UIKeyEnum.apiSourceUI.name,
  ];

  final Signal<bool> portraitShow = Signal(true);

  // 顶部ui
  late final OverlayUIModel topUI;
  // 底部ui
  late final OverlayUIModel bottomUI;
  // 设置ui
  late final OverlayUIModel settingUI;
  // 播放速度ui
  late final OverlayUIModel speedSettingUI;
  // 锁键ui
  late final OverlayUIModel lockCtrUI;
  // 截图ui
  late final OverlayUIModel screenshotUI;
  // 亮度ui
  late final OverlayUIModel brightnessUI;
  // 音量ui
  late final OverlayUIModel volumeUI;
  // 居中进度ui
  late final OverlayUIModel centerProgressUI;
  // 弹幕设置ui
  late final OverlayUIModel danmakuSettingUI;
  // 章节列表ui
  late final OverlayUIModel chapterListUI;
  // api源ui
  late final OverlayUIModel apiSourceUI;

  void _init() {
    topUI = SlideOverlayUIModel(
      name: UIKeyEnum.topUI.name,
      widget: TopUI(uiViewModel: uiViewModel),
      useAnimationController: true,
      tween: TweenConstant.topSlideTween,
      hideRemove: true,
      animationDuration: CommonConstant.uIAnimationDuration,
      position: PositionConstant.topPosition,
    );
    bottomUI = SlideOverlayUIModel(
      name: UIKeyEnum.bottomUI.name,
      widget: BottomUI(uiViewModel: uiViewModel),
      useAnimationController: true,
      tween: TweenConstant.bottomSlideTween,
      hideRemove: false,
      animationDuration: CommonConstant.uIAnimationDuration,
      position: PositionConstant.bottomPosition,
    );
    settingUI = AutoAdjustSlideOverlayUIModel(
      name: UIKeyEnum.settingUI.name,
      widget: SettingUI(uiViewModel: uiViewModel),
      useAnimationController: true,
      hideRemove: true,
      animationDuration: CommonConstant.uIAnimationDuration,
      portraitShow: portraitShow,
      tweenAndPosition: AutoAdjustSlideOverlayUITweenAndPosition.fromRBFixed(),
    );

    speedSettingUI = AutoAdjustSlideOverlayUIModel(
      name: UIKeyEnum.speedSettingUI.name,
      widget: PlaySpeedUI(uiViewModel: uiViewModel),
      useAnimationController: true,
      hideRemove: true,
      animationDuration: CommonConstant.uIAnimationDuration,
      portraitShow: portraitShow,
      tweenAndPosition: AutoAdjustSlideOverlayUITweenAndPosition.fromRBFixed(),
    );
    lockCtrUI = SlideOverlayUIModel(
      name: UIKeyEnum.lockCtrUI.name,
      widget: Align(
        alignment: Alignment.centerLeft,
        child: LockCtrUI(uiViewModel: uiViewModel),
      ),
      useAnimationController: true,
      tween: TweenConstant.leftSlideTween,
      hideRemove: false,
      animationDuration: CommonConstant.uIAnimationDuration,
      position: PositionConstant.leftPosition,
    );
    screenshotUI = SlideOverlayUIModel(
      name: UIKeyEnum.screenshotCtrUI.name,
      widget: Align(
        alignment: Alignment.centerRight,
        child: ScreenshotUI(uiViewModel: uiViewModel),
      ),
      useAnimationController: true,
      tween: TweenConstant.rightSlideTween,
      hideRemove: false,
      animationDuration: CommonConstant.uIAnimationDuration,
      position: PositionConstant.rightPosition,
    );
    brightnessUI = OpacityOverlayUIModel(
      name: UIKeyEnum.centerBrightnessUI.name,
      widget: BrightnessUI(uiViewModel: uiViewModel),
      useAnimationController: false,
      hideRemove: false,
      tween: TweenConstant.opacityTween,
    );

    volumeUI = OpacityOverlayUIModel(
      name: UIKeyEnum.centerVolumeUI.name,
      widget: VolumeUI(uiViewModel: uiViewModel),
      useAnimationController: false,
      hideRemove: false,
      tween: TweenConstant.opacityTween,
    );

    centerProgressUI = OpacityOverlayUIModel(
      name: UIKeyEnum.centerProgressUI.name,
      widget: CenterPlayProgressUI(uiViewModel: uiViewModel),
      useAnimationController: false,
      hideRemove: false,
      tween: TweenConstant.opacityTween,
    );
    danmakuSettingUI = AutoAdjustSlideOverlayUIModel(
      name: UIKeyEnum.danmakuSettingUI.name,
      widget: DanmakuSettingUI(uiViewModel: uiViewModel),
      useAnimationController: true,
      hideRemove: true,
      animationDuration: CommonConstant.uIAnimationDuration,
      portraitShow: portraitShow,
      tweenAndPosition: AutoAdjustSlideOverlayUITweenAndPosition.fromRBFixed(),
    );
    chapterListUI = AutoAdjustSlideOverlayUIModel(
      name: UIKeyEnum.chapterListUI.name,
      widget: ChapterListUI(uiViewModel: uiViewModel),
      useAnimationController: true,
      hideRemove: true,
      animationDuration: CommonConstant.uIAnimationDuration,
      portraitShow: portraitShow,
      tweenAndPosition: AutoAdjustSlideOverlayUITweenAndPosition.fromRBFixed(),
    );
    apiSourceUI = AutoAdjustSlideOverlayUIModel(
      name: UIKeyEnum.apiSourceUI.name,
      widget: ApiSourceUI(uiViewModel: uiViewModel),
      useAnimationController: true,
      hideRemove: true,
      animationDuration: CommonConstant.uIAnimationDuration,
      portraitShow: portraitShow,
      tweenAndPosition: AutoAdjustSlideOverlayUITweenAndPosition.fromRBFixed(),
    );

    dynamicOverlayUIList.value = [
      ...dynamicOverlayUIList.value,
      topUI,
      bottomUI,
      lockCtrUI,
      screenshotUI,
      settingUI,
      speedSettingUI,
      danmakuSettingUI,
      brightnessUI,
      volumeUI,
      centerProgressUI,
      chapterListUI,
      apiSourceUI,
    ];
  }

  // 销毁
  @override
  void dispose() {
    _tickerProviderEffectCleanup?.call();
    tickerProvider.dispose();
    try {
      if (dynamicOverlayUIList.value.isNotEmpty) {
        // 先获取值的副本，再逐个销毁
        var elements = List<OverlayUIModel>.from(dynamicOverlayUIList.value);
        for (var element in elements) {
          try {
            element.dispose();
          } catch (e) {
            // ignore: avoid_catches_without_on_clauses
          }
        }
      }
    } catch (e) {
      // ignore: avoid_catches_without_on_clauses
    }
    dynamicOverlayUIList.dispose();
    commonUISizeModel.dispose();
    uiSize.dispose();
    disposed = true;
  }
}
