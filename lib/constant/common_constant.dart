import '../model/screen_aspect_ratio_model.dart';

class CommonConstant {
  /// 画面尺寸列表
  static List<ScreenAspectRatioModel> screenAspectRatioList = [
    ScreenAspectRatioModel("适应", 'contain'),
    ScreenAspectRatioModel("拉伸", 'fill'),
    ScreenAspectRatioModel("填充", 'cover'),
    ScreenAspectRatioModel("16:9", 16 / 9.0),
    ScreenAspectRatioModel("4:3", 4 / 3.0),
  ];

  /// 播放速度
  static const List<double> playSpeedList = [
    0.25,
    0.50,
    0.75,
    1.00,
    1.25,
    1.50,
    1.75,
    2.00
  ];

  static Duration uiShowDuration = const Duration(seconds: 5);

  // ui动画时长
  static Duration  uIAnimationDuration = const Duration(milliseconds: 300);
  // 音量和亮度ui显示时长
  static const Duration volumeOrBrightnessUIShowDuration =
  Duration(milliseconds: 1000);
}
