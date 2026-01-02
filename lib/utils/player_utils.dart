import 'package:flutter/material.dart';

import '../iplayer.dart';
import '../model/resource/chapter_model.dart';
import '../model/resource/resource_model.dart';
import '../player_view.dart';
import '../view_model/player_view_model.dart';

class PlayerUtils {
  // 本地视频播放器
  static void openLocalVideo({
    required BuildContext context,
    IPlayer? player,
    ResourceModel? resourceModel,
    List<ChapterModel>? chapterList,
    Function(PlayerViewModel)? playerViewModelCallback,
  }) {
    PlayerViewModel? viewModel = player?.playerViewModel;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              viewModel?.fullscreenUtils.unlockOrientation();
            }
          },
          child: Scaffold(
            body: PlayerView(
              player: player,
              playerViewModel: player?.playerViewModel,
              onCreatePlayerViewModel: (value) {
                viewModel = value;
                viewModel!.onlyFullscreen = true;
                viewModel!.fullscreenUtils.enterFullscreen();

                viewModel!.playerState.autoPlay = true;

                if (resourceModel != null) {
                  viewModel!.resourceState.resourceModel.value = resourceModel;
                }
                if (chapterList != null) {
                  viewModel!.resourceState.chapterList.value = chapterList;
                }

                playerViewModelCallback?.call(viewModel!);
              },
            ),
          ),
        ),
      ),
    );
  }
}
