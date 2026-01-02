import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/player_state.dart';
import '../view_model/player_view_model.dart';

class FullscreenUtils {
  final PlayerViewModel playerViewModel;

  FullscreenUtils(this.playerViewModel);

  PlayerState get playerState => playerViewModel.playerState;

  void toggleFullscreen({bool exit = false, required BuildContext context}) {
    bool playing = playerViewModel.player.value?.playing ?? false;
    if (playerViewModel.player.value != null && playing) {
      playerViewModel.player.value!.pause();
    }
    if (playerState.isFullscreen.value || exit) {
      bool fullscreen = playerState.isFullscreen.value;
      exitFullscreen(context);
      if (fullscreen && !playerViewModel.onlyFullscreen && playing) {
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

  void enterFullscreen() {
    // FullScreen.setFullScreen(true);
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

  void exitFullscreen(BuildContext context) {
    // FullScreen.setFullScreen(false);
    if (!playerState.isFullscreen.value || playerViewModel.onlyFullscreen) {
      if (playerViewModel.onlyFullscreen) {
        playerViewModel.pause();
        playerViewModel.player.value?.onDisposePlayer();
      }
      Navigator.of(context).pop();
    }
    playerState.isFullscreen.value = false;
    unlockOrientation();
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
