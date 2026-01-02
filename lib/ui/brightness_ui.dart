import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../state/player_state.dart';
import '../state/ui_state.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';

class BrightnessUI extends StatefulWidget {
  const BrightnessUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<BrightnessUI> createState() => _BrightnessUIState();
}

class _BrightnessUIState extends State<BrightnessUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  UIState get uiState => uiViewModel.uiState;
  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;

  PlayerState get playerState => playerViewModel.playerState;
  Color get backgroundColor => uiViewModel.backgroundColor;
  Color get textColor => uiViewModel.textColor;

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
