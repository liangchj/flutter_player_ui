import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../enum/player_ui_key_enum.dart';
import '../view_model/ui_view_model.dart';

class LockCtrUI extends StatelessWidget {
  const LockCtrUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => IconButton(
        color: uiViewModel.textColor,
        onPressed: () {
          uiViewModel.uiState.uiLocked.value =
              !uiViewModel.uiState.uiLocked.value;
          if (uiViewModel.uiState.uiLocked.value) {
            uiViewModel.onlyShowUIByKeyList([UIKeyEnum.lockCtrUI.name]);
          } else {
            uiViewModel.onlyShowUIByKeyList(
              uiViewModel.uiState.touchBackgroundShowUIKeyList,
            );
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Colors.black.withValues(alpha: 0.1),
          ),
        ),
        icon: Icon(
          uiViewModel.uiState.uiLocked.value
              ? Icons.lock_clock_rounded
              : Icons.lock_open_rounded,
        ),
      ),
    );
  }
}
