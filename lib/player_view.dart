import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import 'interface/iplayer.dart';
import 'ui/player_ui.dart';
import 'view_model/player_view_model.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    this.playerViewModel,
    this.player,
    this.onCreatePlayerViewModel,
    this.fullScreen = false,
    this.onlyFullscreen = false,
  }) : assert(
         playerViewModel != null || (playerViewModel == null && player != null),
       );
  final PlayerViewModel? playerViewModel;
  final IPlayer? player;
  final Function(PlayerViewModel)? onCreatePlayerViewModel;
  final bool fullScreen;
  final bool onlyFullscreen;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late PlayerViewModel playerViewModel;

  bool viewModelIsNull = false;

  @override
  void initState() {
    super.initState();
    if (widget.playerViewModel == null) {
      if (widget.player?.playerViewModel == null) {
        viewModelIsNull = true;
      }
      playerViewModel = widget.player?.playerViewModel ?? PlayerViewModel(fullScreen: widget.fullScreen, onlyFullscreen: widget.onlyFullscreen);
    } else {
      playerViewModel = widget.playerViewModel!;
    }
    assert(widget.player != null || playerViewModel.player.value != null);
    if (playerViewModel.player.value == null && widget.player != null) {
      playerViewModel.player.value = widget.player;
    }
    if (playerViewModel.player.value!.playerViewModel == null &&
        playerViewModel.player.value!.playerViewModel != playerViewModel) {
      playerViewModel.player.value!.playerViewModel = playerViewModel;
    }

    // 初始化 context
    playerViewModel.initContext(context);
    widget.onCreatePlayerViewModel?.call(playerViewModel);
  }

  @override
  void dispose() {
    if (viewModelIsNull) {
      playerViewModel.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Watch((c) => playerViewModel.playerState.playerView.value),
        ),
        PlayerUI(playerViewModel: playerViewModel),
      ],
    );
  }
}
