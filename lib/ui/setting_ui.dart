import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/common_constant.dart';
import '../constant/key_constant.dart';
import '../constant/style_constant.dart';
import '../enum/player_fit_enum.dart';
import '../enum/player_ui_key_enum.dart';
import '../state/player_state.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';
import '../widget/build_text_widget.dart';
import 'play_speed_ui.dart';

class SettingUI extends StatefulWidget {
  const SettingUI({
    super.key,
    required this.uiViewModel,
    this.bottomSheet = false,
    this.backgroundColor,
    this.textColor,
    this.activatedTextColor,
  });
  final UIViewModel uiViewModel;
  final bool bottomSheet;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? activatedTextColor;

  @override
  State<SettingUI> createState() => _SettingUIState();
}

class _SettingUIState extends State<SettingUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;
  PlayerState get playerState => playerViewModel.playerState;

  Color get backgroundColor => uiViewModel.backgroundColor;
  Color get textColor => uiViewModel.textColor;
  Color get activatedTextColor =>
      widget.activatedTextColor ?? uiViewModel.activatedTextColor;
  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize;
    List<Widget> list = [
      // 创建画面比例
      _createAspectRatioSetting(),
      // 创建播放速度
      _settingPlayerSpeedSetting(fontSize: fontSize),
      _createSubtitleSetting(),
      _createDanmakuSetting(),
    ];

    return Watch((context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              uiViewModel.uiState.commonUISizeModel.value.maxHeight ??
              double.infinity,
          maxWidth:
              uiViewModel.uiState.commonUISizeModel.value.maxWidth ??
              double.infinity,
        ),
        child: Container(
          key: Key(KeyConstant.settingUI),
          color: backgroundColor,
          width: uiViewModel.uiState.commonUISizeModel.value.width,
          height:
              uiViewModel.uiState.commonUISizeModel.value.height ??
              double.infinity,
          padding: EdgeInsets.all(StyleConstant.safeSpace),
          child: ListView(children: list),
        ),
      );
    });
  }

  /// 创建画面比例设置
  Widget _createAspectRatioSetting() {
    return Watch((context) {
      late Object? activated;
      if (playerState.aspectRatio.value == null) {
        activated = playerState.fit.value?.name;
      } else {
        activated = playerState.aspectRatio.value;
      }
      activated ??= "contain";
      return _createSettingItem(
        "画面尺寸",
        Row(
          spacing: StyleConstant.safeSpace,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: CommonConstant.screenAspectRatioList.map((item) {
            return InkWell(
              onTap: () {
                bool isNumber = item.value is double;
                if (isNumber) {
                  playerState.fit.value = null;
                  playerState.aspectRatio.value = item.value;
                } else {
                  playerState.aspectRatio.value = null;
                  playerState.fit.value = PlayerFitEnum.values.firstWhere(
                    (e) => e.name == item.value,
                    orElse: () => PlayerFitEnum.contain,
                  );
                }
              },
              child: Text(
                item.name,
                style: TextStyle(
                  color: item.value == activated
                      ? activatedTextColor
                      : textColor,
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  /// 创建播放速度设置
  Widget _settingPlayerSpeedSetting({double? fontSize}) {
    return Padding(
      padding: EdgeInsets.only(bottom: StyleConstant.safeSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: StyleConstant.safeSpace / 2),
            child: _createTitle("倍数"),
          ),
          SizedBox(
            width: double.infinity,
            height: (fontSize ?? 14) + StyleConstant.safeSpace,
            child: PlaySpeedUI(
              uiViewModel: uiViewModel,
              bottomSheet: true,
              singleHorizontalScroll: true,
              showActivatedBackgroundColor: false,
              backgroundColor: backgroundColor,
              textColor: textColor,
              activatedTextColor: activatedTextColor,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  /// 创建字幕设置
  Widget _createSubtitleSetting() {
    return _createSettingItem(
      "字幕",
      Row(
        spacing: StyleConstant.safeSpace,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              // LoggerUtils.logger.d("字幕轨");
            },
            child: Text("字幕轨", style: TextStyle(color: textColor)),
          ),
          InkWell(
            onTap: () {
              // LoggerUtils.logger.d("字幕样式");
            },
            child: Text("字幕样式", style: TextStyle(color: textColor)),
          ),
          InkWell(
            onTap: () {
              // LoggerUtils.logger.d("字幕时间");
            },
            child: Text("字幕时间", style: TextStyle(color: textColor)),
          ),
        ],
      ),
    );
  }

  /// 创建弹幕设置
  Widget _createDanmakuSetting() {
    return _createSettingItem(
      "弹幕",
      Row(
        spacing: StyleConstant.safeSpace,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              // LoggerUtils.logger.d("弹幕设置");
              uiViewModel.onlyShowUIByKeyList([
                UIKeyEnum.danmakuSettingUI.name,
              ], ignoreLimit: true);
            },
            child: Text("弹幕设置", style: TextStyle(color: textColor)),
          ),
          InkWell(
            onTap: () {
              // LoggerUtils.logger.d("弹幕轨");
            },
            child: Text("弹幕轨", style: TextStyle(color: textColor)),
          ),
          /*InkWell(
            onTap: () {
              // LoggerUtils.logger.d("弹幕时间");
            },
            child: Text("弹幕时间", style: TextStyle(color: textColor)),
          ),*/
        ],
      ),
    );
  }

  Widget _createSettingItem(String text, Widget child) {
    return Padding(
      padding: EdgeInsets.only(bottom: StyleConstant.safeSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: StyleConstant.safeSpace),
            child: _createTitle(text),
          ),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
              scrollbars: false,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: BuildTextWidget(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: StyleConstant.titleTextSize,
        ),
        edgeInsets: const EdgeInsets.all(0),
      ),
    );
  }
}
