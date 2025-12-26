import 'package:flutter/material.dart';
import 'package:flutter_player_ui/controller/player_controller.dart';
import 'package:flutter_player_ui/ui/player_ui.dart';
import 'package:signals/signals_flutter.dart';

import 'iplayer.dart';

class PlayerView extends StatefulWidget {
  const PlayerView({
    super.key,
    this.controller,
    this.player,
    this.onCreatePlayerController,
  }) : assert(controller != null || (controller == null && player != null));
  final PlayerController? controller;
  final IPlayer? player;
  final Function(PlayerController)? onCreatePlayerController;

  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  late PlayerController playerController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      playerController = widget.player?.playerController ?? PlayerController();
    } else {
      playerController = widget.controller!;
    }
    assert(widget.player != null || playerController.player.value != null);
    if (playerController.player.value  == null) {
      playerController.player.value = widget.player;
    }
    widget.onCreatePlayerController?.call(playerController);
  }

  @override
  void dispose() {
    if (widget.controller == null && (widget.player == null || widget.player?.playerController == null)) {
      playerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // VideoPlayer(controller),
        // Positioned.fill(child: Container(color: Colors.grey)),
        Positioned.fill(
          child: Watch((c) => playerController.playerState.playerView.value),
        ),
        PlayerUI(playerController: playerController),
      ],
    );
  }
}
