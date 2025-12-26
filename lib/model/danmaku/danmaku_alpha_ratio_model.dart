class DanmakuAlphaRatioModel {
  final double min;
  final double max;
  double? _ratio;

  DanmakuAlphaRatioModel({
    required this.min,
    required this.max,
    required double ratio,
  }) {
    _ratio = ratio.round().toDouble();
  }

  DanmakuAlphaRatioModel copyWith({
    double? min,
    double? max,
    double? ratio,
  }) {
    return DanmakuAlphaRatioModel(
      min: min ?? this.min,
      max: max ?? this.max,
      ratio: ratio ?? this.ratio,
    );
  }

  double get ratio => _ratio ?? min;
  set ratio(double d) {
    _ratio = d.round().toDouble();
  }
}
