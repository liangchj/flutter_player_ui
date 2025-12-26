import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../controller/player_controller.dart';
import '../controller/ui_controller.dart';
import '../model/resource/source_group_model.dart';
import '../model/source_option_model.dart';
import '../state/player_state.dart';
import '../state/resource_state.dart';
import '../utils/auto_compute_sliver_grid_count.dart';
import '../utils/calculate_color_utils.dart';
import 'clickable_button_widget.dart';

class SourceGroupWidget extends StatefulWidget {
  const SourceGroupWidget({
    super.key,
    required this.uiController,
    required this.option,
  });
  final UIController uiController;
  final SourceOptionModel option;

  @override
  State<SourceGroupWidget> createState() => _SourceGroupWidgetState();
}

class _SourceGroupWidgetState extends State<SourceGroupWidget> {
  SourceOptionModel get option => widget.option;
  UIController get uiController => widget.uiController;
  PlayerController get playerController => uiController.playerController;
  PlayerState get playerState => playerController.playerState;

  ResourceState get resourceState => playerController.resourceState;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  GridObserverController? _gridObserverController;
  late int _activatedIndex;
  bool get isFullscreen => playerState.isFullscreen.value;
  int get groupCount => resourceState.activatedApiSourceGroupCount;
  List<SourceGroupModel> get sourceGroupList =>
      groupCount > 0 ? resourceState.activatedApiSourceGroupList! : [];

  // 全屏时背景是黑色
  Color get textColor => option.backgroundColor == null
      ? isFullscreen
            ? uiController.textColor
            : CalculateColorUtils.calculateTextColor(Colors.white)
      : CalculateColorUtils.calculateTextColor(Colors.white);
  Color get activatedTextColor => uiController.activatedTextColor;
  Color get backgroundColor =>
      option.backgroundColor ?? uiController.backgroundColor;
  @override
  void initState() {
    _activatedIndex = resourceState.apiGroupActivatedIndex.value;
    if (!option.isSelect) {
      int initialIndex = _activatedIndex >= 0 ? _activatedIndex : 0;
      _scrollController = ScrollController();
      if (option.isGrid) {
        _gridObserverController = GridObserverController(
          controller: _scrollController,
        )..initialIndex = initialIndex;
      } else {
        _observerController = ListObserverController(
          controller: _scrollController,
        )..initialIndex = initialIndex;
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    int index = resourceState.apiGroupActivatedIndex.value;
    if (index < 0) {
      index = 0;
    }
    if (_scrollController != null && index != _activatedIndex) {
      option.onDispose?.call(index);
    }
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (groupCount <= 1) {
        return Container();
      }
      return Column(
        children: [
          // _createHeader(context),
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

  // bottomSheet弹出内容
  Widget _bottomSheetList(BuildContext context) {
    return Expanded(
      child: option.isGrid ? _gridView(context) : _listView(context),
    );
  }

  Widget _selectList(BuildContext context) {
    return Container();
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    return Watch((context) {
      int activatedIndex = resourceState.apiGroupActivatedIndex.value;
      return ListViewObserver(
        controller: _observerController,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(
            horizontal: StyleConstant.safeSpace,
            vertical: StyleConstant.safeSpace,
          ),
          itemCount: sourceGroupList.length,
          itemBuilder: (context, index) {
            final item = sourceGroupList[index];
            return SizedBox(
              height: 44,
              child: ClickableButtonWidget(
                key: ValueKey(
                  "source_group_${option.bottomSheet}_listView_${resourceState.apiActivatedIndex.value}_$index",
                ),
                text: item.name ?? "未知分组",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                activated: index == activatedIndex,
                activatedTextColor: activatedTextColor,
                unActivatedTextColor: textColor,
                activatedBorderColor: activatedTextColor,
                unActivatedBorderColor: textColor,
                activatedBackgroundColor: activatedTextColor.withValues(
                  alpha: 0.2,
                ),
                unActivatedBackgroundColor: null,
                isCard: false,
                onClick: () {
                  resourceState.apiGroupActivatedIndex.value = index;
                },
              ),
            );
          },
        ),
      );
    });
  }

  // 列表（grid）方式
  Widget _gridView(BuildContext context) {
    return Watch((context) {
      int activatedIndex = resourceState.apiGroupActivatedIndex.value;
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
              itemCount: sourceGroupList.length,
              gridDelegate: SliverGridDelegateWithExtentAndRatio(
                crossAxisSpacing: StyleConstant.safeSpace,
                mainAxisSpacing: StyleConstant.safeSpace,
                maxCrossAxisExtent: StyleConstant.sourceGridMaxWidth,
                childAspectRatio: StyleConstant.sourceGridRatio,
              ),
              itemBuilder: (context, index) {
                final item = sourceGroupList[index];
                return ClickableButtonWidget(
                  key: ValueKey(
                    "source_group_${option.bottomSheet}_gridView_${resourceState.apiActivatedIndex.value}_$index",
                  ),
                  text: item.name ?? "未知分组",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  activated: index == activatedIndex,
                  isCard: false,
                  textAlign: TextAlign.center,
                  activatedTextColor: activatedTextColor,
                  unActivatedTextColor: textColor,
                  activatedBorderColor: activatedTextColor,
                  unActivatedBorderColor: textColor,
                  activatedBackgroundColor: activatedTextColor.withValues(
                    alpha: 0.2,
                  ),
                  unActivatedBackgroundColor: null,
                  onClick: () {
                    resourceState.apiGroupActivatedIndex.value = index;
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
          int activatedIndex = resourceState.apiGroupActivatedIndex.value;
          return ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: sourceGroupList.length,
              itemBuilder: (context, index) {
                final item = sourceGroupList[index];
                return Container(
                  margin: EdgeInsets.only(right: StyleConstant.safeSpace),
                  child: AspectRatio(
                    aspectRatio: StyleConstant.sourceGridRatio,
                    child: ClickableButtonWidget(
                      key: ValueKey(
                        "source_group_${option.bottomSheet}_horizontalScroll_${resourceState.apiActivatedIndex.value}_$index",
                      ),
                      text: item.name ?? "未知分组",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      activated: index == activatedIndex,
                      isCard: false,
                      textAlign: TextAlign.center,
                      activatedTextColor: activatedTextColor,
                      unActivatedTextColor: textColor,
                      activatedBorderColor: activatedTextColor,
                      unActivatedBorderColor: textColor,
                      activatedBackgroundColor: activatedTextColor.withValues(
                        alpha: 0.2,
                      ),
                      unActivatedBackgroundColor: null,
                      onClick: () {
                        resourceState.apiGroupActivatedIndex.value = index;
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
