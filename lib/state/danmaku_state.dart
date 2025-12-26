import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../constant/icon_constant.dart';
import '../model/danmaku/danmaku_alpha_ratio_model.dart';
import '../model/danmaku/danmaku_area_model.dart';
import '../model/danmaku/danmaku_filter_type_model.dart';
import '../model/danmaku/danmaku_font_size_model.dart';
import '../model/danmaku/danmaku_speed_model.dart';

class DanmakuState {
  // 弹幕组件
  final Signal<Widget> danmakuView = Signal(Container());
  // 是否启动弹幕
  final Signal<bool> isVisible = signal(true);

  // 弹幕文件路径
  final Signal<String> danmakuFilePath = signal("");

  // 错误信息
  final Signal<String> errorMsg = signal("");

  // 是否已经初始化
  final Signal<bool> isInitialized = signal(false);

  // 时间调整（执行的调整时间）
  final Signal<double> adjustTime = signal(0.0);

  // ui显示更新
  final Signal<double> uiShowAdjustTime = signal(0.0);

  // 设置
  // 不透明度
  final Signal<DanmakuAlphaRatioModel> danmakuAlphaRatio = Signal(
    DanmakuAlphaRatioModel(min: 0, max: 100, ratio: 100),
  );

  // 显示区域["1/4屏", "半屏", "3/4屏", "满屏", "无限"]，选择下标，默认半屏（下标1）
  final Signal<DanmakuAreaModel> danmakuArea = Signal(
    DanmakuAreaModel(
      danmakuAreaItemList: [
        DanmakuAreaItemModel(area: 0.25, name: "1/4屏"),
        DanmakuAreaItemModel(area: 0.5, name: "半屏"),
        DanmakuAreaItemModel(area: 0.75, name: "3/4屏"),
        DanmakuAreaItemModel(area: 1.0, name: "满屏"),
        DanmakuAreaItemModel(area: 1.0, name: "无限", filter: false),
      ],
      areaIndex: 3,
    ),
  );

  // 弹幕字体大小，显示百分比， 区间[20, 200]
  final Signal<DanmakuFontSizeModel> danmakuFontSize = Signal(
    DanmakuFontSizeModel(size: 16.0, min: 8, max: 30, fontSize: 16),
  );

  // 弹幕播放速度（最终速度仍需要与视频速度计算而得）
  final Signal<DanmakuSpeedModel> danmakuSpeed = signal(
    DanmakuSpeedModel(min: 3.0, max: 12.0, speed: 6),
  );

  // 弹幕过滤类型
  final danmakuFilterTypeList = [
    DanmakuFilterTypeModel(
      enName: "repeat",
      chName: "重复",
      modeList: [],
      openImageIcon: IconConstant.danmakuRepeatOpen,
      closeImageIcon: IconConstant.danmakuRepeatClose,
      filter: signal(false),
    ),
    DanmakuFilterTypeModel(
      enName: "fixedTop",
      chName: "顶部",
      modeList: [5],
      openImageIcon: IconConstant.danmakuTopOpen,
      closeImageIcon: IconConstant.danmakuTopClose,
      filter: signal(false),
    ),
    DanmakuFilterTypeModel(
      enName: "fixedBottom",
      chName: "底部",
      modeList: [4],
      openImageIcon: IconConstant.danmakuBottomOpen,
      closeImageIcon: IconConstant.danmakuBottomClose,
      filter: signal(false),
    ),
    DanmakuFilterTypeModel(
      enName: "scroll",
      chName: "滚动",
      modeList: [1, 2, 3, 6],
      openImageIcon: IconConstant.danmakuScrollOpen,
      closeImageIcon: IconConstant.danmakuScrollClose,
      filter: signal(false),
    ),
    DanmakuFilterTypeModel(
      enName: "color",
      chName: "彩色",
      modeList: [],
      openImageIcon: IconConstant.danmakuColorOpen,
      closeImageIcon: IconConstant.danmakuColorClose,
      filter: signal(false),
    ),
  ];
}
