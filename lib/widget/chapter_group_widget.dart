import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../model/resource/chapter_group_model.dart';
import '../model/source_option_model.dart';
import '../state/player_state.dart';
import '../state/resource_state.dart';
import '../utils/calculate_color_utils.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';
import 'clickable_button_widget.dart';

class ChapterGroupWidget extends StatefulWidget {
  const ChapterGroupWidget({
    super.key,
    required this.uiViewModel,
    required this.option,
  });
  final UIViewModel uiViewModel;
  final SourceOptionModel option;

  @override
  State<ChapterGroupWidget> createState() => _ChapterGroupWidgetState();
}

class _ChapterGroupWidgetState extends State<ChapterGroupWidget> {
  SourceOptionModel get option => widget.option;
  UIViewModel get uiViewModel => widget.uiViewModel;
  PlayerViewModel get playerViewModel => uiViewModel.playerViewModel;
  PlayerState get playerState => playerViewModel.playerState;

  ResourceState get resourceState => playerViewModel.resourceState;
  ScrollController? _scrollController;
  ListObserverController? _observerController;
  late int _activatedIndex;

  bool get isFullscreen => playerState.isFullscreen.value;
  int get groupCount => resourceState.activatedChapterGroupCount;
  List<ChapterGroupModel> get chapterGroupList =>
      groupCount > 0 ? resourceState.activatedChapterGroupList : [];

  // 全屏时背景是黑色
  Color get textColor => option.backgroundColor == null
      ? isFullscreen
            ? uiViewModel.textColor
            : CalculateColorUtils.calculateTextColor(Colors.white)
      : CalculateColorUtils.calculateTextColor(Colors.white);
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  @override
  void initState() {
    _activatedIndex = resourceState.chapterGroupActivatedIndex.value;
    int initialIndex = _activatedIndex >= 0 ? _activatedIndex : 0;
    _scrollController = ScrollController();
    _observerController = ListObserverController(controller: _scrollController)
      ..initialIndex = initialIndex;

    super.initState();
  }

  @override
  void dispose() {
    int index = resourceState.chapterGroupActivatedIndex.value;
    index = index >= 0 ? index : 0;
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
      return Padding(
        padding: EdgeInsets.only(
          top: isFullscreen ? StyleConstant.safeSpace : 0,
        ),
        child: _chapterGroup(context),
      );
    });
  }

  // 章节分组显示
  Widget _chapterGroup(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: StyleConstant.safeSpace,
        right: StyleConstant.safeSpace,
        bottom: StyleConstant.safeSpace / 2,
      ),
      width: double.infinity,
      height: StyleConstant.chapterHeight,
      child: Watch((context) {
        var list = resourceState.chapterAsc.value
            ? chapterGroupList
            : chapterGroupList.reversed.toList();
        int activeIndex = resourceState.chapterGroupActivatedIndex.value;
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
          ),
          child: ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                int realIndex = resourceState.chapterAsc.value
                    ? index
                    : list.length - index - 1;
                return Container(
                  margin: EdgeInsets.only(right: StyleConstant.safeSpace),
                  child: AspectRatio(
                    aspectRatio: StyleConstant.chapterGridRatio,
                    child: ClickableButtonWidget(
                      key: ValueKey(
                        "chapterGroup_${resourceState.apiActivatedIndex.value}-${resourceState.apiGroupActivatedIndex.value}-$realIndex",
                      ),
                      text: item.name,
                      textAlign: TextAlign.center,
                      activated: realIndex == activeIndex,
                      isCard: true,
                      activatedTextColor: activatedTextColor,
                      unActivatedTextColor: textColor,
                      activatedBorderColor: activatedTextColor,
                      unActivatedBorderColor: textColor,
                      activatedBackgroundColor: activatedTextColor.withValues(
                        alpha: 0.2,
                      ),
                      unActivatedBackgroundColor: null,
                      onClick: () {
                        resourceState.chapterGroupActivatedIndex.value =
                            realIndex;
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
