import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../controller/player_controller.dart';
import '../controller/ui_controller.dart';
import '../state/player_state.dart';
import '../state/ui_state.dart';

class BrightnessUI extends StatefulWidget {
  const BrightnessUI({super.key, required this.uiController});
  final UIController uiController;

  @override
  State<BrightnessUI> createState() => _BrightnessUIState();
}

class _BrightnessUIState extends State<BrightnessUI> {
  UIController get uiController => widget.uiController;
  UIState get uiState => uiController.uiState;
  PlayerController get playerController => uiController.playerController;

  PlayerState get playerState => playerController.playerState;
  Color get backgroundColor => uiController.backgroundColor;
  Color get textColor => uiController.textColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: UnconstrainedBox(
        child: Container(
          width: StyleConstant.volumeOrBrightnessUISize.width,
          height: StyleConstant.volumeOrBrightnessUISize.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            //设置四周圆角 角度
            borderRadius: const BorderRadius.all(
              Radius.circular(StyleConstant.borderRadius),
            ),
          ),
          child: Watch((context) {
            List<Widget> uiList = [
              Icon(Icons.brightness_6_rounded, color: textColor),
              const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
              Text(
                "${playerState.brightness}%",
                style: TextStyle(color: textColor),
              ),
            ];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: uiList.map((e) => e).toList(),
            );
          }),
        ),
      ),
    );
  }
}
