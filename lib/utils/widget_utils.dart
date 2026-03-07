import 'package:flutter/material.dart';

class WidgetUtils {
  static Widget dialogCloseButton({
    Icon? icon,
    String tooltip = '关闭',
    ButtonStyle? buttonStyle,
    Function()? onClose,
  }) {
    return IconButton(
      tooltip: tooltip,
      icon: icon ?? Icon(Icons.close),
      style:
          buttonStyle ??
          ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
      onPressed: () {
        onClose?.call();
      },
    );
  }
}
