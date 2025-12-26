import 'package:flutter/material.dart';

class TweenConstant {
  /// 顶部滑动tween
  static Tween<Offset> topSlideTween = Tween<Offset>(
    begin: const Offset(0.0, -1),
    end: Offset.zero,
  );
  /// 底部滑动tween
  static Tween<Offset> bottomSlideTween = Tween<Offset>(
    begin: const Offset(0.0, 1),
    end: Offset.zero,
  );
  /// 左侧滑动tween
  static Tween<Offset> leftSlideTween = Tween<Offset>(
    begin: const Offset(-1, 0.0),
    end: Offset.zero,
  );
  /// 右侧滑动tween
  static Tween<Offset> rightSlideTween = Tween<Offset>(
    begin: const Offset(1, 0.0),
    end: Offset.zero,
  );

  /// 透明度tween
  static Tween<double> opacityTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );
}
