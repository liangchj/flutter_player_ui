import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../model/resource/api_model.dart';
import '../model/source_option_model.dart';
import '../state/player_state.dart';
import '../state/resource_state.dart';
import '../utils/auto_compute_sliver_grid_count.dart';
import '../utils/calculate_color_utils.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';
import 'clickable_button_widget.dart';

class ApiWidget extends StatefulWidget {
  const ApiWidget({
    super.key,
    required this.uiViewModel,
    required this.option,
  });
  final UIViewModel uiViewModel;
  final SourceOptionModel option;

  @override
  State<ApiWidget> createState() => _ApiWidgetState();
}

class _ApiWidgetState extends State<ApiWidget> {
  SourceOptionModel get option => widget.option;
  UIViewModel get uiViewModel => widget.uiViewModel;
  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;
  PlayerState get playerState => playerViewModel.playerState;
  ResourceState get resourceState => playerViewModel.resourceState;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;
  bool get isFullscreen => playerState.isFullscreen.value;
  int get apiCount => resourceState.apiCount;
  List<ApiModel> get apiList => apiCount > 0 ? resourceState.apiList! : [];

  // 全屏时背景是黑色
  Color get textColor => option.backgroundColor == null
      ? isFullscreen
            ? uiViewModel.textColor
            : CalculateColorUtils.calculateTextColor(Colors.white)
      : CalculateColorUtils.calculateTextColor(Colors.white);
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  Color get backgroundColor =>
      option.backgroundColor ?? uiViewModel.backgroundColor;

  @override
  void initState() {
    _activatedIndex = resourceState.apiActivatedIndex.value;
    if (!option.isSelect) {
      _scrollController = ScrollController();

      if (option.isGrid) {
        _gridObserverController = GridObserverController(
          controller: _scrollController,
        )..initialIndex = _activatedIndex;
      } else {
        _observerController = ListObserverController(
          controller: _scrollController,
        )..initialIndex = _activatedIndex;
      }
    }

    super.initState();
  }

  @override
  void dispose() {
    if (_scrollController != null &&
        resourceState.apiActivatedIndex.value != _activatedIndex) {
      option.onDispose?.call(resourceState.apiActivatedIndex.value);
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (apiCount < 1) {
        return Container();
      }
      return Column(
        children: [
          option.bottomSheet
              ? _bottomSheetList(context)
              : option.isSelect
              ? _selectList(context)
              : option.singleHorizontalScroll
              ? _horizontalScroll(context)
              : _list(context),
        ],
      );
    });
  }

  Widget _list(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          vertical: StyleConstant.safeSpace,
          horizontal: StyleConstant.safeSpace,
        ),
        child: option.isGrid ? _gridView(context) : _listView(context),
      ),
    );
  }

  Widget _selectList(BuildContext context) {
    return Container();
  }

  // bottomSheet弹出内容
  Widget _bottomSheetList(BuildContext context) {
    return Expanded(
      child: option.isGrid ? _gridView(context) : _listView(context),
    );
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return Watch((context) {
      int activatedIndex = resourceState.apiActivatedIndex.value;
      return ListViewObserver(
        controller: _observerController,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: StyleConstant.safeSpace,
            vertical: StyleConstant.safeSpace,
          ),
          itemCount: apiCount,
          itemBuilder: (context, index) {
            final item = apiList[index];
            return SizedBox(
              height: StyleConstant.sourceListHeight,
              child: ClickableButtonWidget(
                key: ValueKey("api_${option.bottomSheet}_listView_$index"),
                text: item.api?.name ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                activated: index == activatedIndex,
                isCard: false,
                activatedTextColor: activatedTextColor,
                unActivatedTextColor: textColor,
                activatedBorderColor: activatedTextColor,
                unActivatedBorderColor: backgroundColor,
                activatedBackgroundColor: activatedTextColor.withValues(
                  alpha: 0.2,
                ),
                unActivatedBackgroundColor: textColor,
                onClick: () {
                  resourceState.apiActivatedIndex.value = index;
                },
              ),
            );
          },
        ),
      );
    });
  }

  // 列表（网格）方式
  Widget _gridView(BuildContext context) {
    return Watch((context) {
      int activatedIndex = resourceState.apiActivatedIndex.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 0) {
            // 如果宽度无效，返回空容器或者使用默认宽度
            return Container();
          }
          return GridViewObserver(
            controller: _gridObserverController,
            child: GridView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: StyleConstant.safeSpace,
                vertical: StyleConstant.safeSpace,
              ),
              controller: _scrollController,
              itemCount: apiCount,
              gridDelegate: SliverGridDelegateWithExtentAndRatio(
                crossAxisSpacing: StyleConstant.safeSpace,
                mainAxisSpacing: StyleConstant.safeSpace,
                maxCrossAxisExtent: StyleConstant.sourceGridMaxWidth,
                childAspectRatio: StyleConstant.sourceGridRatio,
              ),
              itemBuilder: (context, index) {
                final item = apiList[index];
                return ClickableButtonWidget(
                  key: ValueKey("api_${option.bottomSheet}_gridView_$index"),
                  text: item.api?.name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  activated: index == activatedIndex,
                  isCard: false,
                  textAlign: TextAlign.center,
                  activatedTextColor: activatedTextColor,
                  unActivatedTextColor: textColor,
                  activatedBorderColor: activatedTextColor,
                  unActivatedBorderColor: backgroundColor,
                  activatedBackgroundColor: activatedTextColor.withValues(
                    alpha: 0.2,
                  ),
                  unActivatedBackgroundColor: textColor,
                  onClick: () {
                    resourceState.apiActivatedIndex.value = index;
                  },
                );
              },
            ),
          );
        },
      );
    });
  }

  // 横向滚动
  Widget _horizontalScroll(BuildContext context) {
    return Container(
      // padding: EdgeInsets.symmetric(horizontal: StyleConstant.safeSpace),
      width: double.infinity,
      height: StyleConstant.sourceGridHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: Watch((context) {
          int activatedIndex = resourceState.apiActivatedIndex.value;
          return ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: apiCount,
            itemBuilder: (context, index) {
              final item = apiList[index];
              return Container(
                margin: EdgeInsets.only(right: StyleConstant.safeSpace),
                child: AspectRatio(
                  aspectRatio: StyleConstant.sourceGridRatio,
                  child: ClickableButtonWidget(
                    key: ValueKey("api_horizontalScroll_$index"),
                    text: item.api?.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    activated: index == activatedIndex,
                    isCard: false,
                    textAlign: TextAlign.center,
                    activatedTextColor: activatedTextColor,
                    unActivatedTextColor: textColor,
                    activatedBorderColor: activatedTextColor,
                    unActivatedBorderColor: backgroundColor,
                    activatedBackgroundColor: activatedTextColor.withValues(
                      alpha: 0.2,
                    ),
                    unActivatedBackgroundColor: textColor,
                    onClick: () {
                      resourceState.apiActivatedIndex.value = index;
                    },
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
