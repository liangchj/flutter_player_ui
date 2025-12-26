import 'package:flutter/material.dart';

class StyleConstant {
  // 间距
  static double safeSpace = 12;

  // 主色调
  static const Color primaryColor = Color(0xFFB1ECE9);

  // 播放器信息
  // ui背景色
  static Color uIBackgroundColor = Colors.black.withValues(alpha: 0.8);

  // 渐变色
  static List<Color> gradientBackground = [
    Colors.black54,
    Colors.black45,
    Colors.black38,
    Colors.black26,
    Colors.black12,
    Colors.transparent,
  ];
  // 顶部UI渐变色
  static final LinearGradient topUILinearGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: gradientBackground,
  );

  // 顶部UI渐变色
  static final LinearGradient bottomUILinearGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: gradientBackground,
  );

  // 文本文字
  // 文本文字颜色
  static const Color textColor = Colors.white;

  // 标题类字体大小
  static const double titleTextSize = 16.0;

  static const Color defaultUnactiveTextColor = Colors.black;

  // 默认的图标颜色
  static const Color iconColor = Colors.white;

  // 边框圆角
  static const double borderRadius = 6.0;

  static const double borderWidth = 1;

  // 底部按钮大小
  static const double bottomBtnSize = 40.0;

  // 进度条
  // 高度
  static const double progressBarHeight = 4.0;
  // 滑块圆角
  static const double progressBarThumbRadius = 12.0;
  // 滑块内部圆角
  static const double progressBarThumbInnerRadius = 6.0;
  // 滑块外部颜色
  static Color progressBarThumbOverlayColor = Colors.redAccent.withValues(
    alpha: 0.24,
  );
  static Color progressBarThumbOverlayShapeColor = Colors.redAccent.withValues(
    alpha: 0.5,
  );
  // 滑块滑动或选中时显示外围的圆角
  static const double progressBarThumbOverlayColorShapeRadius = 16.0;

  // 设置默认宽度
  static const double uiDefaultWidth = speedSettingUIDefaultWidth * 3;
  // 默认高度
  static const double uiDefaultHeight = 300.0;

  // 播放速度默认宽度
  static const double speedSettingUIDefaultWidth = 150.0;

  // 音量和亮度UI大小
  static const Size volumeOrBrightnessUISize = Size(80, 70);
  static const Size playProgressUISize = Size(100, 70);

  // 源列表grid宽高
  static const double sourceGridMaxWidth = 120;
  static const double sourceGridRatio = 2 / 1;
  static const double sourceGridHeight = 40;
  // 源列表高度
  static const double sourceListHeight = 44;

  // 章节信息
  static const int chapterGroupCount = 50;
  static const double chapterGridMaxWidth = 120;
  static const double chapterHeight = 50;
  static const double chapterGridRatio = 2 / 1;
  static const double chapterBorderWidth = 1;
  static const Color chapterBackgroundColor = Color(0xFFD1D5D5);
  static const EdgeInsets chapterPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 10);
}
