import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/icon_constant.dart';
import '../constant/style_constant.dart';
import '../enum/player_ui_key_enum.dart';
import '../model/bottom_ui_item_model.dart';
import '../state/danmaku_state.dart';
import 'base_view_model.dart';
import 'player_view_model.dart';
import 'ui_view_model.dart';

class MyDanmakuViewModel extends BaseViewModel {
  final UIViewModel uiViewModel;
  MyDanmakuViewModel({required this.uiViewModel}) {
    _init();
  }

  PlayerViewModel get playerController => uiViewModel.playerViewModel;

  late DanmakuState danmakuState;

  bool get videoIsPlaying => playerController.playerState.isPlaying.value;

  Color get textColor => uiViewModel.textColor;
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  final List<EffectCleanup> _effectCleanupList = [];
  void _init() {
    danmakuState = DanmakuState();

    _effectCleanupList.addAll([
      effect(() {
        var value = danmakuState.isVisible.value;
        if (value) {
          danmakuState.danmakuView.value = Container(color: Colors.cyan);
        } else {
          danmakuState.danmakuView.value = Container(color: Colors.transparent);
        }
      }),
    ]);
  }

  @override
  void dispose() {
    for (var e in _effectCleanupList) {
      e.call();
    }
    disposed = true;
  }
}
