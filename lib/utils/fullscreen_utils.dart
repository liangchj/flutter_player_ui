import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller/player_controller.dart';
import '../state/player_state.dart';

class FullscreenUtils {
  final PlayerController playeController;

  FullscreenUtils(this.playeController);

  PlayerState get playerState => playeController.playerState;

  void toggleFullscreen({bool exit = false, required BuildContext context}) {
    bool playing = playeController.player.value?.playing ?? false;
    if (playeController.player.value != null && playing) {
      playeController.player.value!.pause();
    }
    if (playerState.isFullscreen.value || exit) {
      bool fullscreen = playerState.isFullscreen.value;
      exitFullscreen(context);
      if (fullscreen && !playeController.onlyFullscreen && playing) {
        playeController.player.value!.play();
      }
    } else {
      enterFullscreen();
      if (playing) {
        playeController.player.value!.play();
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
        playeController.onlyFullscreen) {
      if (playeController.onlyFullscreen) {
        playeController.pause();
        playeController.player.value?.onDisposePlayer();
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
