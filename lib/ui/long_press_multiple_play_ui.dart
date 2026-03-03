import 'package:flutter/material.dart';
import '../constant/style_constant.dart';
import '../state/player_state.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';

class LongPressMultiplePlayUI extends StatefulWidget {
  const LongPressMultiplePlayUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<LongPressMultiplePlayUI> createState() =>
      _LongPressMultiplePlayUIState();
}

class _LongPressMultiplePlayUIState extends State<LongPressMultiplePlayUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;
  PlayerState get playerState => playerViewModel.playerState;
  Color get backgroundColor => uiViewModel.backgroundColor;
  Color get textColor => uiViewModel.textColor;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: UnconstrainedBox(
        child: Container(
          transform: Matrix4.translationValues(
            0.0,
            0 - (uiViewModel.uiState.uiSize.value.height * 0.15),
            0.0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: StyleConstant.safeSpace * 0.5,
            vertical: StyleConstant.safeSpace * 0.3,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            //设置四周圆角 角度
            borderRadius: const BorderRadius.all(
              Radius.circular(StyleConstant.borderRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.keyboard_double_arrow_right, color: textColor),
              Text(
                "${playerState.longPressMultiplePlay}倍数播放",
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
