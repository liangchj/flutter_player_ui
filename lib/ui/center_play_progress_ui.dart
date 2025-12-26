import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../controller/player_controller.dart';
import '../controller/ui_controller.dart';
import '../state/player_state.dart';
import '../state/ui_state.dart';
import '../utils/calculate_color_utils.dart';
import '../utils/time_format_utils.dart';

class CenterPlayProgressUI extends StatefulWidget {
  const CenterPlayProgressUI({super.key, required this.uiController});
  final UIController uiController;

  @override
  State<CenterPlayProgressUI> createState() => _CenterPlayProgressUIState();
}

class _CenterPlayProgressUIState extends State<CenterPlayProgressUI> {
  UIController get uiController => widget.uiController;
  PlayerController get playerController => uiController.playerController;
  PlayerState get playerState => playerController.playerState;
  Color get backgroundColor => uiController.backgroundColor;
  Color get textColor => uiController.textColor;

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(
        width: StyleConstant.playProgressUISize.width,
        height: StyleConstant.playProgressUISize.height,
        decoration: BoxDecoration(
          color: backgroundColor,
          //设置四周圆角 角度
          borderRadius: const BorderRadius.all(
            Radius.circular(StyleConstant.borderRadius),
          ),
        ),
        child: Watch(
          (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${TimeFormatUtils.durationToMinuteAndSecond(Duration(seconds: playerState.draggingSecond.value.abs() > 0 ? playerState.dragProgressPositionDuration.inSeconds + playerState.draggingSecond.value : 0))}/${TimeFormatUtils.durationToMinuteAndSecond(playerState.duration.value)}",
                style: TextStyle(color: textColor),
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
              Text(
                "${playerState.draggingSecond}秒",
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
