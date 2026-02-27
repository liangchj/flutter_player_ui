import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';

import '../state/player_state.dart';
import '../view_model/player_view_model.dart';

class FullscreenUtils {
  final PlayerViewModel playerViewModel;

  FullscreenUtils(this.playerViewModel) {
    FullScreen.ensureInitialized().then(
      (v) => _fullscreenEnsureInitialized = true,
    );
  }

  bool _fullscreenEnsureInitialized = false;

  PlayerState get playerState => playerViewModel.playerState;

  void toggleFullscreen({bool exit = false}) {
    bool playing = playerViewModel.player.value?.playing ?? false;
    if (playerViewModel.player.value != null && playing) {
      playerViewModel.player.value!.pause();
    }
    if (playerState.isFullscreen.value || exit) {
      bool fullscreen = playerState.isFullscreen.value;
      exitFullscreen();
      if (fullscreen && !playerViewModel.onlyFullscreen.value && playing) {
        playerViewModel.player.value!.play();
      }
    } else {
      enterFullscreen();
      if (playing) {
        playerViewModel.player.value!.play();
      }
    }
    /*if (exit) {
      playerState.isFullscreen(false);
    } else {
      playerState.isFullscreen.toggle();
    }*/
  }

  Future<void> enterFullscreen() async {
    if (!_fullscreenEnsureInitialized) {
      await FullScreen.ensureInitialized();
      _fullscreenEnsureInitialized = true;
    }
    FullScreen.setFullScreen(true);
    playerState.isFullscreen.value = true;
    lockLandscapeOrientation();
  }

  void lockLandscapeOrientation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      overlays: [],
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> exitFullscreen() async {
    if (!_fullscreenEnsureInitialized) {
      await FullScreen.ensureInitialized();
      _fullscreenEnsureInitialized = true;
    }
    FullScreen.setFullScreen(false);
    if (!playerState.isFullscreen.value || playerViewModel.onlyFullscreen.value) {
      if (playerViewModel.onlyFullscreen.value) {
        playerViewModel.pause();
        playerViewModel.player.value?.onDisposePlayer();
      }
      _pop();
    }
    playerState.isFullscreen.value = false;
    unlockOrientation();
  }

  void _pop() {
    Navigator.of(playerViewModel.context).pop();
  }

  // 恢复竖屏
  void unlockOrientation() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    // 恢复竖屏
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}
