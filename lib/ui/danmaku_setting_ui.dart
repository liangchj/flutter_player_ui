import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../controller/my_danmaku_controller.dart';
import '../controller/ui_controller.dart';
import '../state/danmaku_state.dart';
import '../state/ui_state.dart';
import '../widget/build_text_widget.dart';

class DanmakuSettingUI extends StatefulWidget {
  const DanmakuSettingUI({
    super.key,
    required this.uiController,
    this.bottomSheet = false,
  });
  final UIController uiController;
  final bool bottomSheet;

  @override
  State<DanmakuSettingUI> createState() => _DanmakuSettingUIState();
}

class _DanmakuSettingUIState extends State<DanmakuSettingUI> {
  UIController get uiController => widget.uiController;

  MyDanmakuController get myDanmakuController =>
      uiController.myDanmakuController;
  UIState get uiState => uiController.uiState;

  Color get backgroundColor => uiController.backgroundColor;
  Color get textColor => uiController.textColor;

  Color get activatedTextColor => uiController.activatedTextColor;

  Color get buttonColor => uiController.buttonColor;
  Color get buttonFontColor => uiController.buttonFontColor;

  List<Widget> listWidget = [];

  DanmakuState get danmakuState => myDanmakuController.danmakuState;

  static const int _leftTextCount = 4;
  static const int _rightTextCount = 4;

  double get _leftTextWidth => _leftTextCount * StyleConstant.titleTextSize;
  double get _rightTextWidth => _rightTextCount * StyleConstant.titleTextSize;

  final double minSliderWidth = 120.0;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      initList();
    }
  }

  void initList() {
    listWidget = [
      _settingList(),
      Padding(padding: EdgeInsets.only(bottom: StyleConstant.safeSpace / 2)),
      // 屏蔽类型
      Column(
        children: [
          _createTitle("屏蔽类型", fontColor: textColor),
          Padding(
            padding: EdgeInsetsGeometry.only(top: StyleConstant.safeSpace),
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: Wrap(
                direction: Axis.horizontal,
                spacing: StyleConstant.safeSpace, // 主轴(水平)方向间距
                runSpacing: StyleConstant.safeSpace, // 纵轴（垂直）方向间距
                verticalDirection: VerticalDirection.down,
                alignment: WrapAlignment.spaceBetween, //
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...danmakuState.danmakuFilterTypeList.map(
                    (filterType) => Watch(
                      (context) => InkWell(
                        onTap: () =>
                            filterType.filter.value = !filterType.filter.value,
                        child: Column(
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                filterType.filter.value
                                    ? activatedTextColor
                                    : textColor,
                                BlendMode.srcIn,
                              ),
                              child: filterType.openImageIcon,
                            ),
                            Text(
                              filterType.chName,
                              style: TextStyle(
                                fontSize: StyleConstant.titleTextSize,
                                color: filterType.filter.value
                                    ? activatedTextColor
                                    : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: StyleConstant.safeSpace)),
      // 时间调整
      Column(
        children: [
          _createTitle("时间调整（秒）", fontColor: textColor),
          ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => danmakuState.uiShowAdjustTime.value =
                        danmakuState.uiShowAdjustTime.value - 0.5,
                    icon: Icon(Icons.remove_circle_rounded, color: buttonColor),
                  ),
                  Container(
                    width: 80,
                    padding: EdgeInsets.symmetric(
                      horizontal: StyleConstant.safeSpace,
                    ),
                    child: Center(
                      child: Watch(
                        (context) => Text(
                          danmakuState.uiShowAdjustTime.toStringAsFixed(1),
                          style: TextStyle(
                            color: textColor,
                            fontSize: StyleConstant.titleTextSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => danmakuState.uiShowAdjustTime.value =
                        danmakuState.uiShowAdjustTime.value + 0.5,
                    icon: Icon(Icons.add_circle_rounded, color: buttonColor),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                danmakuState.adjustTime.value =
                    danmakuState.uiShowAdjustTime.value;
              },
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      StyleConstant.borderRadius,
                    ),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(buttonColor),
              ),
              child: Text(
                "同步弹幕时间",
                style: TextStyle(
                  color: buttonFontColor,
                  fontSize: StyleConstant.titleTextSize,
                ),
              ),
            ),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: StyleConstant.safeSpace)),
      // 弹幕屏蔽词
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_createTitle("弹幕屏蔽词", fontColor: textColor)],
          ),
          Padding(padding: EdgeInsets.only(bottom: StyleConstant.safeSpace)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      StyleConstant.borderRadius,
                    ),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(buttonColor),
              ),
              child: Text(
                "弹幕屏蔽管理",
                style: TextStyle(
                  color: buttonFontColor,
                  fontSize: StyleConstant.titleTextSize,
                ),
              ),
            ),
          ),
        ],
      ),
      Padding(padding: EdgeInsets.only(bottom: StyleConstant.safeSpace)),
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_createTitle("弹幕列表", fontColor: textColor)],
          ),
          Padding(padding: EdgeInsets.only(bottom: StyleConstant.safeSpace)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      StyleConstant.borderRadius,
                    ),
                  ),
                ),
                backgroundColor: WidgetStateProperty.all(buttonColor),
              ),
              child: Text(
                "查看弹幕列表",
                style: TextStyle(
                  color: buttonFontColor,
                  fontSize: StyleConstant.titleTextSize,
                ),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              uiController.uiState.commonUISizeModel.value.maxHeight ??
              double.infinity,
          maxWidth:
              uiController.uiState.commonUISizeModel.value.maxWidth ??
              double.infinity,
        ),
        child: Container(
          key: ValueKey("danmakuSettingUI"),
          color: backgroundColor,
          width: uiController.uiState.commonUISizeModel.value.width,
          height: uiController.uiState.commonUISizeModel.value.height,
          padding: EdgeInsets.all(StyleConstant.safeSpace),
          child: ListView(children: listWidget),
        ),
      );
    });
  }

  // 弹幕设置
  Widget _settingList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double sliderWidth =
            constraints.maxWidth -
            _leftTextWidth -
            _rightTextWidth +
            StyleConstant.safeSpace;
        final double actualSliderWidth = sliderWidth > minSliderWidth
            ? sliderWidth
            : minSliderWidth;
        return Column(
          children: [
            _createTitle("弹幕设置", fontColor: textColor),
            Column(
              children: [
                // 弹幕不透明度设置
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: StyleConstant.safeSpace / 2,
                  ),
                  child: _danmakuOpacitySetting(actualSliderWidth),
                ),
                // 弹幕显示区域设置
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: StyleConstant.safeSpace / 2,
                  ),
                  child: _danmakuDisplayAreaSetting(actualSliderWidth),
                ),
                // 弹幕字号设置
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: StyleConstant.safeSpace / 2,
                  ),
                  child: _danmakuFontSizeSetting(actualSliderWidth),
                ),
                // 弹幕速度设置
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: StyleConstant.safeSpace / 2,
                  ),
                  child: _danmakuSpeedSetting(actualSliderWidth),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _createSliderWidget({required List<Widget> widgets}) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        scrollbars: false,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }

  /// 弹幕不透明度设置
  Widget _danmakuOpacitySetting(double actualSliderWidth) {
    return _createSliderWidget(
      widgets: [
        _leftDescText("不透明度", fontColor: textColor),
        Watch(
          (context) => SizedBox(
            width: actualSliderWidth,
            child: Slider(
              value: danmakuState.danmakuAlphaRatio.value.ratio,
              min: danmakuState.danmakuAlphaRatio.value.min,
              max: danmakuState.danmakuAlphaRatio.value.max,
              onChanged: (value) {
                danmakuState.danmakuAlphaRatio.value = danmakuState
                    .danmakuAlphaRatio
                    .value
                    .copyWith(ratio: value.truncateToDouble());
              },
            ),
          ),
        ),
        Watch(
          (context) => _rightTipText(
            "${danmakuState.danmakuAlphaRatio.value.ratio.floor()}%",
            fontColor: textColor,
          ),
        ),
      ],
    );
  }

  /// 弹幕显示区域设置
  Widget _danmakuDisplayAreaSetting(double actualSliderWidth) {
    return _createSliderWidget(
      widgets: [
        // 左边文字说明
        _leftDescText("显示区域", fontColor: textColor),
        Watch(
          (context) => SizedBox(
            width: actualSliderWidth,
            child: Slider(
              value: danmakuState.danmakuArea.value.areaIndex.toDouble(),
              min: 0,
              max:
                  danmakuState.danmakuArea.value.danmakuAreaItemList.length - 1,
              divisions:
                  danmakuState.danmakuArea.value.danmakuAreaItemList.length - 1,
              onChanged: (value) {
                danmakuState.danmakuArea.value = danmakuState.danmakuArea.value
                    .copyWith(areaIndex: value.toInt());
              },
            ),
          ),
        ),
        Watch(
          (context) => _rightTipText(
            danmakuState
                .danmakuArea
                .value
                .danmakuAreaItemList[danmakuState.danmakuArea.value.areaIndex]
                .name,
            fontColor: textColor,
          ),
        ),
      ],
    );
  }

  /// 弹幕字号设置
  Widget _danmakuFontSizeSetting(double actualSliderWidth) {
    return _createSliderWidget(
      widgets: [
        // 左边文字说明
        _leftDescText("弹幕字号", fontColor: textColor),

        // 中间进度指示器
        Watch(
          (context) => SizedBox(
            width: actualSliderWidth,
            child: Slider(
              value: danmakuState.danmakuFontSize.value.fontSize,
              min: danmakuState.danmakuFontSize.value.min,
              max: danmakuState.danmakuFontSize.value.max,
              onChanged: (value) {
                danmakuState.danmakuFontSize.value = danmakuState
                    .danmakuFontSize
                    .value
                    .copyWith(fontSize: value);
              },
            ),
          ),
        ),

        // 右边进度提示
        Watch(
          (context) => _rightTipText(
            "${danmakuState.danmakuFontSize.value.fontSize}",
            fontColor: textColor,
          ),
        ),
      ],
    );
  }

  /// 弹幕速度设置
  Widget _danmakuSpeedSetting(double actualSliderWidth) {
    return _createSliderWidget(
      widgets: [
        // 左边文字说明
        _leftDescText("弹幕速度", fontColor: textColor),
        Watch(
          (context) => SizedBox(
            width: actualSliderWidth,
            child: Slider(
              value: danmakuState.danmakuSpeed.value.speed,
              min: danmakuState.danmakuSpeed.value.min,
              max: danmakuState.danmakuSpeed.value.max,
              onChanged: (value) {
                danmakuState.danmakuSpeed.value = danmakuState
                    .danmakuSpeed
                    .value
                    .copyWith(speed: value);
              },
            ),
          ),
        ),
        // 右边进度提示
        Watch(
          (context) => _rightTipText(
            "${danmakuState.danmakuSpeed.value.speed}秒",
            fontColor: textColor,
          ),
        ),
      ],
    );
  }

  // 左边描述文字
  Widget _leftDescText(String text, {Color? fontColor}) {
    return Text(
      text,
      style: TextStyle(color: fontColor, fontSize: StyleConstant.titleTextSize),
      strutStyle: const StrutStyle(forceStrutHeight: true),
    );
  }

  // 右边提示文字
  Widget _rightTipText(String text, {Color? fontColor}) {
    return Stack(
      children: [
        const Text(
          "占位符",
          style: TextStyle(
            fontSize: StyleConstant.titleTextSize,
            color: Color.fromARGB(0, 0, 0, 0),
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: fontColor,
            fontSize: StyleConstant.titleTextSize,
          ),
          strutStyle: const StrutStyle(forceStrutHeight: true),
        ),
      ],
    );
  }

  Widget _createTitle(String text, {Color? fontColor}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: BuildTextWidget(
        text: text,
        style: TextStyle(
          color: fontColor,
          fontSize: StyleConstant.titleTextSize,
        ),
        edgeInsets: const EdgeInsets.all(0),
      ),
    );
  }
}
