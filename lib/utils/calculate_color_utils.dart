

import 'package:flutter/material.dart';

class CalculateColorUtils {
  /// 根据背景色计算文字色
  static Color calculateTextColor(Color backgroundColor, {Color? textColor}) {
    // 若用户自定义文字色，直接使用
    if (textColor != null) return textColor;
    // 计算背景色亮度，自动适配文字色
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}