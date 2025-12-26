

// 弹幕文字大小
class DanmakuFontSizeModel {
  // 基础字体大小
  final double size;
  final double min;
  final double max;
  double? _fontSize;
  double get fontSize => _fontSize ?? min;

  DanmakuFontSizeModel(
      {this.size = 16.0,
        required this.min,
        required this.max,
        required double fontSize}) {
    _fontSize = fontSize.round().toDouble();
  }

  DanmakuFontSizeModel copyWith({
    double? size,
    double? min,
    double? max,
    double? fontSize,
  }) {
    return DanmakuFontSizeModel(
      size: size ?? this.size,
      min: min ?? this.min,
      max: max ?? this.max,
      fontSize: fontSize ?? this.fontSize,
    );
  }

  set fontSize(double d) {
    _fontSize = d.round().toDouble();
  }
}