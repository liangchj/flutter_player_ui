import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../state/player_state.dart';
import '../utils/time_format_utils.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';

class CenterPlayProgressUI extends StatefulWidget {
  const CenterPlayProgressUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<CenterPlayProgressUI> createState() => _CenterPlayProgressUIState();
}

class _CenterPlayProgressUIState extends State<CenterPlayProgressUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;
  PlayerState get playerState => playerViewModel.playerState;
  Color get backgroundColor => uiViewModel.backgroundColor;
  Color get textColor => uiViewModel.textColor;

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
