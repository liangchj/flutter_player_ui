import 'package:flutter/material.dart';
import 'package:flutter_player_ui/controller/player_controller.dart';
import 'package:flutter_player_ui/controller/ui_controller.dart';
import 'package:signals/signals_flutter.dart';

class PlayerUI extends StatefulWidget {
  const PlayerUI({super.key, required this.playerController});
  final PlayerController playerController;

  @override
  State<PlayerUI> createState() => _PlayerUIState();
}

class _PlayerUIState extends State<PlayerUI> with TickerProviderStateMixin {
  UIController get uiController => widget.playerController.uiController;
  @override
  void initState() {
    super.initState();
    uiController.uiState.tickerProvider.value = this;
  }

  @override
  void dispose() {
    uiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            uiController.uiState.uiSize.value = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            uiController.handleScreenChange(
              Size(constraints.maxWidth, constraints.maxHeight),
            );
            return _ui();
          },
        ),
      ),
    );
  }

  Widget _ui() {
    return Watch(
      (context) => uiController.uiState.tickerProvider.value == null
          ? Container()
          : Stack(
              children: [
                Positioned.fill(
                  child: Watch(
                    (context) =>
                        uiController
                            .myDanmakuController
                            .danmakuState
                            .danmakuView
                            .value ??
                        Container(),
                  ),
                ),
                ...uiController.uiState.overlayUIList,
              ],
            ),
    );
  }
}
