import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../controller/ui_controller.dart';
import '../enum/player_ui_key_enum.dart';

class LockCtrUI extends StatelessWidget {
  const LockCtrUI({super.key, required this.uiController});
  final UIController uiController;

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => IconButton(
        color: uiController.textColor,
        onPressed: () {
          uiController.uiState.uiLocked.value =
              !uiController.uiState.uiLocked.value;
          if (uiController.uiState.uiLocked.value) {
            uiController.onlyShowUIByKeyList([UIKeyEnum.lockCtrUI.name]);
          } else {
            uiController.onlyShowUIByKeyList(
              uiController.uiState.touchBackgroundShowUIKeyList,
            );
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(
            Colors.black.withValues(alpha: 0.1),
          ),
        ),
        icon: Icon(
          uiController.uiState.uiLocked.value
              ? Icons.lock_clock_rounded
              : Icons.lock_open_rounded,
        ),
      ),
    );
  }
}
