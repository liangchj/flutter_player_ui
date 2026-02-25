import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';

class PlayerUI extends StatefulWidget {
  const PlayerUI({super.key, required this.playerViewModel});
  final PlayerViewModel playerViewModel;

  @override
  State<PlayerUI> createState() => _PlayerUIState();
}

class _PlayerUIState extends State<PlayerUI> with TickerProviderStateMixin {
  UIViewModel get uiViewModel => widget.playerViewModel.uiViewModel;
  @override
  void initState() {
    super.initState();
    uiViewModel.uiState.tickerProvider.value = this;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            uiViewModel.uiState.uiSize.value = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );
            uiViewModel.handleScreenChange(
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
      (context) => uiViewModel.uiState.tickerProvider.value == null
          ? Container()
          : Stack(
              children: [
                Positioned.fill(
                  child: Watch(
                    (context) =>
                        uiViewModel.danmakuState.danmakuView.value ??
                        Container(),
                  ),
                ),
                ...uiViewModel.uiState.overlayUIList,
                Watch(
                  (context) =>
                      uiViewModel
                          .playerViewModel
                          .playerState
                          .isInitialized
                          .value
                      ? SizedBox.shrink()
                      : Positioned.fill(
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
