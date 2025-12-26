import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/icon_constant.dart';
import '../constant/style_constant.dart';
import '../enum/player_ui_key_enum.dart';
import '../model/bottom_ui_item_model.dart';
import '../state/danmaku_state.dart';
import 'player_controller.dart';
import 'ui_controller.dart';

class MyDanmakuController {
  final UIController uiController;
  MyDanmakuController({required this.uiController}) {
    _init();
  }

  PlayerController get playerController => uiController.playerController;

  late DanmakuState danmakuState;

  bool get videoIsPlaying => playerController.playerState.isPlaying.value;

  Color get textColor => uiController.textColor;
  Color get activatedTextColor => uiController.activatedTextColor;

  final List<EffectCleanup> _effectCleanupList = [];
  void _init() {
    danmakuState = DanmakuState();

    _effectCleanupList.addAll([
      effect(() {
        var value = danmakuState.isVisible.value;
        if ( value) {
          danmakuState.danmakuView.value = Container(color: Colors.cyan,);
        } else {
          danmakuState.danmakuView.value = Container();
        }
      })
    ]);

  }

  void dispose() {
    for (var e in _effectCleanupList) {
      e.call();
    }
  }
}
