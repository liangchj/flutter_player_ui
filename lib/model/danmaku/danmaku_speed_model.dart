
// 弹幕速度
class DanmakuSpeedModel {
  final double min;
  final double max;
  double? _speed;
  double get speed => _speed ?? min;

  DanmakuSpeedModel({required this.min, required this.max, required double speed}) {
    _speed = speed.round().toDouble();
  }

  DanmakuSpeedModel copyWith({
    double? min,
    double? max,
    double? speed
  }) {
    return DanmakuSpeedModel(
      min: min ?? this.min,
      max: max ?? this.max,
      speed: speed ?? this.speed,
    );
  }

  set speed(double s) {
    _speed = s.round().toDouble();
  }
}