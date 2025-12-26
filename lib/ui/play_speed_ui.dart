import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';
import '../constant/common_constant.dart';
import '../constant/key_constant.dart';
import '../constant/style_constant.dart';
import '../controller/player_controller.dart';
import '../controller/ui_controller.dart';
import '../state/player_state.dart';
import '../utils/calculate_color_utils.dart';
import '../widget/clickable_button_widget.dart';

// 播放倍数ui
class PlaySpeedUI extends StatefulWidget {
  const PlaySpeedUI({
    super.key,
    required this.uiController,
    this.bottomSheet = false,
    this.singleHorizontalScroll = false,
    this.backgroundColor,
    this.textColor,
    this.activatedTextColor,
    this.activatedBackgroundColor,
    this.showActivatedBackgroundColor = true,
    this.width,
  });
  final UIController uiController;
  final bool bottomSheet;
  final bool singleHorizontalScroll;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? activatedTextColor;
  final Color? activatedBackgroundColor;
  final bool showActivatedBackgroundColor;
  final double? width;

  @override
  State<PlaySpeedUI> createState() => _PlaySpeedUIState();
}

class _PlaySpeedUIState extends State<PlaySpeedUI> {
  UIController get uiController => widget.uiController;
  PlayerController get playerController => uiController.playerController;
  PlayerState get playerState => playerController.playerState;
  late final ScrollController _scrollController;
  late ListObserverController _listObserverController;

  Color get backgroundColor =>
      widget.backgroundColor ?? StyleConstant.uIBackgroundColor;

  Color get textColor =>
      widget.textColor ??
      CalculateColorUtils.calculateTextColor(backgroundColor);

  Color get activatedTextColor =>
      widget.activatedTextColor ?? StyleConstant.primaryColor;

  Color get activatedBackgroundColor =>
      widget.activatedBackgroundColor ??
      activatedTextColor.withValues(alpha: 0.2);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    int playSpeedIndex = CommonConstant.playSpeedList.indexOf(
      playerState.playSpeed.value,
    );
    if (playSpeedIndex == -1) {
      playSpeedIndex = CommonConstant.playSpeedList.indexOf(1.0);
      if (playSpeedIndex == -1) {
        playSpeedIndex = 0;
        playerState.playSpeed.value = CommonConstant.playSpeedList[0];
      } else {
        playerState.playSpeed.value = 1.0;
      }
    }

    _scrollController = ScrollController();
    _listObserverController = ListObserverController(
      controller: _scrollController,
    )..initialIndex = playSpeedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!playerState.isFullscreen.value || widget.bottomSheet) {
      return _createList();
    }

    return Watch((context) {
      return ConstrainedBox(
        key: Key(KeyConstant.independentPlaySpeedList),
        constraints: BoxConstraints(
          maxHeight:
              uiController.uiState.commonUISizeModel.value.maxHeight ??
              double.infinity,
          maxWidth:
              uiController.uiState.commonUISizeModel.value.maxWidth ??
              double.infinity,
        ),
        child: Container(
          width: widget.width ?? uiController.uiState.speedUIWidth.value,
          height: uiController.uiState.commonUISizeModel.value.height,
          color: backgroundColor,
          padding: EdgeInsets.all(StyleConstant.safeSpace),
          child: Center(child: _createList()),
        ),
      );
    });
  }

  Widget _createList() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        scrollbars: false,
      ),
      child: ListViewObserver(
        controller: _listObserverController,
        child: ListView.builder(
          scrollDirection: widget.singleHorizontalScroll
              ? Axis.horizontal
              : Axis.vertical,
          controller: _scrollController,
          shrinkWrap: true,
          itemCount: CommonConstant.playSpeedList.length,
          itemBuilder: (ctx, index) {
            var value = CommonConstant.playSpeedList[index];
            return _createClickableButton(value, index);
          },
        ),
      ),
    );
  }

  Widget _createClickableButton(value, index) {
    return Watch(
      (context) => widget.singleHorizontalScroll
          ? widget.showActivatedBackgroundColor
                ? _horizontalBackgroundButton(value, index)
                : _horizontalNotBackgroundButton(value, index)
          : _otherClickableButton(value, index),
    );
  }

  Widget _horizontalBackgroundButton(value, index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: StyleConstant.safeSpace),
      decoration: BoxDecoration(
        color: value == playerState.playSpeed.value
            ? activatedBackgroundColor
            : null,
        //设置四周圆角 角度
        borderRadius: const BorderRadius.all(
          Radius.circular(StyleConstant.borderRadius),
        ),
      ),
      child: TextButton(
        onPressed: () {
          playerState.playSpeed.value = value;
        },
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(StyleConstant.borderRadius),
            ),
          ),
        ),
        child: Text(
          "${value.toString()}x",
          style: TextStyle(
            color: value == playerState.playSpeed.value
                ? activatedTextColor
                : textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _horizontalNotBackgroundButton(value, index) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            playerState.playSpeed.value = value;
          },
          child: Text(
            "${value.toString()}x",
            style: TextStyle(
              color: value == playerState.playSpeed.value
                  ? StyleConstant.primaryColor
                  : textColor,
            ),
          ),
        ),
        if (index < CommonConstant.playSpeedList.length)
          SizedBox(width: StyleConstant.safeSpace),
      ],
    );
  }

  Widget _otherClickableButton(value, index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: StyleConstant.safeSpace / 6),
      child: ClickableButtonWidget(
        text: "${value.toString()}x",
        textAlign: TextAlign.center,
        activated: value == playerState.playSpeed.value,
        isCard: true,
        showBorder: false,
        unActivatedTextColor: textColor,
        padding: EdgeInsets.symmetric(
          vertical: StyleConstant.safeSpace / 2,
          horizontal: 0,
        ),
        onClick: () {
          playerState.playSpeed.value = value;
        },
      ),
    );
  }
}
