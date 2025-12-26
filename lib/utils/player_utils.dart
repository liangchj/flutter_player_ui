import 'package:flutter/material.dart';

import '../controller/player_controller.dart';
import '../iplayer.dart';
import '../model/resource/chapter_model.dart';
import '../model/resource/resource_model.dart';
import '../player_view.dart';

class PlayerUtils {
  // 本地视频播放器
  static void openLocalVideo({
    required BuildContext context,
    IPlayer? player,
    ResourceModel? resourceModel,
    List<ChapterModel>? chapterList,
    Function(PlayerController)? playerControllerCallback,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: PlayerView(
            player: player,
            controller: player?.playerController,
            onCreatePlayerController: (playerController) {
              playerController.onlyFullscreen = true;
              playerController.fullscreenUtils.enterFullscreen();

              playerController.playerState.autoPlay = true;

              if (resourceModel != null) {
                playerController.resourceState.resourceModel.value =
                    resourceModel;
              }
              if (chapterList != null) {
                playerController.resourceState.chapterList.value = chapterList;
              }

              playerControllerCallback?.call(playerController);
            },
          ),
        ),
      ),
    );
  }
}
