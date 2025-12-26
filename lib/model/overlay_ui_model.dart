import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/position_constant.dart';
import '../constant/tween_constant.dart';
import 'position_model.dart';

abstract class OverlayUIModel {
  /// 标识
  final String name;

  /// 显示的Widget
  final Widget widget;

  /// 是否使用AnimationController
  final bool useAnimationController;

  /// 动画Tween
  Tween? tween;

  /// 动画时长
  Duration? animationDuration;

  /// 隐藏时是否移除
  final bool hideRemove;

  final PositionModel? position;

  final Function()? animateHandleListener;

  OverlayUIModel({
    required this.name,
    required this.widget,
    required this.useAnimationController,
    this.tween,
    this.animationDuration,
    this.hideRemove = false,
    this.position,
    this.animateHandleListener,
  }) {
    _animateControllerEffectCleanup = effect(() {
      final controller = animateController.value;
      if (controller != null) {
        untracked(() {
          if (animateHandleListener != null) {
            controller.addListener(animateHandleListener!);
          }
          controller.addStatusListener(handleAnimationStatus);
        });
      }
    });

    _visibleEffectCleanup = effect(() {
      final isVisible = visible.value;
      final controller = animateController.value;
      if (isVisible) {
        controller?.forward();
      } else {
        controller?.reverse();
      }
    });
  }

  /// 显示隐藏
  final Signal<bool> visible = signal(false);
  final Signal<AnimationController?> animateController = signal(null);
  // 保存 effect 的销毁器
  EffectCleanup? _animateControllerEffectCleanup;
  EffectCleanup? _visibleEffectCleanup;

  final Signal<bool> animateDismissed = signal(false);
  final Signal<bool> animateCompleted = signal(false);

  Widget get ui;

  Animation? get animation => tween != null && animateController.value != null
      ? tween!.animate(animateController.value!)
      : null;

  bool get useAnimate =>
      useAnimationController &&
      animateController.value != null &&
      animation != null;

  void handleAnimationStatus(status) {
    animateDismissed.value = status == AnimationStatus.dismissed;
    animateCompleted.value = status == AnimationStatus.completed;
  }

  void dispose() {
    _animateControllerEffectCleanup?.call();
    _visibleEffectCleanup?.call();

    animateDispose();
  }

  void animateDispose() {
    if (animateHandleListener != null) {
      animateController.value?.removeListener(animateHandleListener!);
    }
    animateController.value?.removeStatusListener(handleAnimationStatus);
    animateController.value?.dispose();
    animateController.value = null;
  }
}

class SlideOverlayUIModel extends OverlayUIModel {
  SlideOverlayUIModel({
    required super.name,
    required super.widget,
    required super.useAnimationController,
    super.tween,
    super.animationDuration,
    super.hideRemove,
    super.position,
    super.animateHandleListener,
  });
  @override
  Widget get ui => removeWidget(
    position == null
        ? uiSlideTransition()
        : Positioned(
            left: position!.left,
            top: position!.top,
            right: position!.right,
            bottom: position!.bottom,
            child: uiSlideTransition(),
          ),
  );

  Widget removeWidget(Widget child) {
    if (hideRemove) {
      return Watch((context) => animateDismissed.value ? Container() : child);
    }
    return child;
  }

  Widget uiSlideTransition() {
    return Watch(
      (context) => Offstage(
        offstage: animateDismissed.value,
        child: SlideTransition(
          position: animation as Animation<Offset>,
          child: widget,
        ),
      ),
    );
  }
}

/// 根据页面大小自动调整弹出滑块面板的位置
/// 只支持两个方向变化
class AutoAdjustSlideOverlayUIModel extends SlideOverlayUIModel {
  AutoAdjustSlideOverlayUIModel({
    required super.name,
    required super.widget,
    required super.useAnimationController,
    super.animationDuration,
    super.hideRemove,
    super.animateHandleListener,
    required this.portraitShow,
    required this.tweenAndPosition,
  });
  final Signal<bool> portraitShow;
  final AutoAdjustSlideOverlayUITweenAndPosition tweenAndPosition;

  @override
  PositionModel? get position => portraitShow.value
      ? tweenAndPosition.bottomPopupPosition ??
            tweenAndPosition.topPopupPosition
      : tweenAndPosition.rightPopupPosition ??
            tweenAndPosition.leftPopupPosition;

  @override
  Tween? get tween => portraitShow.value
      ? tweenAndPosition.bottomPopupTween ?? tweenAndPosition.topPopupTween
      : tweenAndPosition.rightPopupTween ?? tweenAndPosition.leftPopupTween;

  /// 动画
  @override
  Animation? get animation => animateController.value != null && tween != null
      ? tween!.animate(animateController.value!)
      : null;
}

class AutoAdjustSlideOverlayUITweenAndPosition {
  Tween<Offset>? bottomPopupTween;
  Tween<Offset>? rightPopupTween;
  Tween<Offset>? topPopupTween;
  Tween<Offset>? leftPopupTween;

  PositionModel? topPopupPosition;
  PositionModel? leftPopupPosition;
  PositionModel? bottomPopupPosition;
  PositionModel? rightPopupPosition;

  AutoAdjustSlideOverlayUITweenAndPosition.fromLT({
    required this.topPopupTween,
    required this.leftPopupTween,
    required this.topPopupPosition,
    required this.leftPopupPosition,
  });

  AutoAdjustSlideOverlayUITweenAndPosition.fromLTFixed() {
    topPopupTween = TweenConstant.topSlideTween;
    leftPopupTween = TweenConstant.leftSlideTween;

    topPopupPosition = PositionConstant.topPosition;
    leftPopupPosition = PositionConstant.leftPosition;
  }

  AutoAdjustSlideOverlayUITweenAndPosition.fromLB({
    required this.leftPopupTween,
    required this.bottomPopupTween,
    required this.leftPopupPosition,
    required this.bottomPopupPosition,
  });
  AutoAdjustSlideOverlayUITweenAndPosition.fromLBFixed() {
    leftPopupTween = TweenConstant.leftSlideTween;
    bottomPopupTween = TweenConstant.bottomSlideTween;

    leftPopupPosition = PositionConstant.leftPosition;
    bottomPopupPosition = PositionConstant.bottomPosition;
  }

  AutoAdjustSlideOverlayUITweenAndPosition.fromRT({
    required this.rightPopupTween,
    required this.topPopupTween,
    required this.rightPopupPosition,
    required this.topPopupPosition,
  });
  AutoAdjustSlideOverlayUITweenAndPosition.fromRTFixed() {
    rightPopupTween = TweenConstant.rightSlideTween;
    topPopupTween = TweenConstant.topSlideTween;

    rightPopupPosition = PositionConstant.rightPosition;
    topPopupPosition = PositionConstant.topPosition;
  }

  AutoAdjustSlideOverlayUITweenAndPosition.fromRB({
    required this.bottomPopupTween,
    required this.rightPopupTween,
    required this.bottomPopupPosition,
    required this.rightPopupPosition,
  });

  AutoAdjustSlideOverlayUITweenAndPosition.fromRBFixed() {
    rightPopupTween = TweenConstant.rightSlideTween;
    bottomPopupTween = TweenConstant.bottomSlideTween;

    rightPopupPosition = PositionConstant.rightPosition;
    bottomPopupPosition = PositionConstant.bottomPosition;
  }
}

class OpacityOverlayUIModel extends OverlayUIModel {
  OpacityOverlayUIModel({
    required super.name,
    required super.widget,
    required super.useAnimationController,
    super.tween,
    super.animationDuration,
    super.hideRemove,
    super.animateHandleListener,
  });

  Tween<double>? get doubleTween =>
      tween is Tween<double> ? tween as Tween<double> : null;

  double get opacity =>
      visible.value ? doubleTween?.end ?? 1.0 : (doubleTween?.begin ?? 0.0);

  @override
  Widget get ui => useAnimate && doubleTween != null
      ? Watch(
          (context) => IgnorePointer(
            ignoring: !visible.value,
            child: FadeTransition(
              opacity: animation as Animation<double>,
              child: widget,
            ),
          ),
        )
      : Watch(
          (context) => IgnorePointer(
            ignoring: !visible.value,
            child: Opacity(opacity: opacity, child: widget),
          ),
        );
}
