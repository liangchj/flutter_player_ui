import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/player_controller.dart';
import '../state/player_state.dart';

class FullscreenUtils {
  final PlayerController playerController;

  FullscreenUtils(this.playerController);

  PlayerState get playerState => playerController.playerState;

  void toggleFullscreen({bool exit = false, required BuildContext context}) {
    bool playing = playerController.player.value?.playing ?? false;
    if (playerController.player.value != null && playing) {
      playerController.player.value!.pause();
    }
    if (playerState.isFullscreen.value || exit) {
      bool fullscreen = playerState.isFullscreen.value;
      exitFullscreen(context);
      if (fullscreen && !playerController.onlyFullscreen && playing) {
        playerController.player.value!.play();
      }
    } else {
      enterFullscreen();
      if (playing) {
        playerController.player.value!.play();
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
    if (!playerState.isFullscreen.value ||
        playerController.onlyFullscreen) {
      if (playerController.onlyFullscreen) {
        playerController.pause();
        playerController.player.value?.onDisposePlayer();
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
