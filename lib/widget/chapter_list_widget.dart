import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:signals/signals_flutter.dart';
import '../constant/style_constant.dart';
import '../model/resource/chapter_model.dart';
import '../model/source_option_model.dart';
import '../state/player_state.dart';
import '../state/resource_state.dart';
import '../utils/auto_compute_sliver_grid_count.dart';
import '../utils/calculate_color_utils.dart';
import '../view_model/player_view_model.dart';
import '../view_model/ui_view_model.dart';
import 'chapter_group_widget.dart';
import 'chapter_widget.dart';

class ChapterListWidget extends StatefulWidget {
  const ChapterListWidget({
    super.key,
    required this.uiViewModel,
    required this.option,
  });
  final UIViewModel uiViewModel;
  final SourceOptionModel option;
  @override
  State<ChapterListWidget> createState() => _ChapterListWidgetState();
}

class _ChapterListWidgetState extends State<ChapterListWidget> {
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
  int get chapterCount => resourceState.activatedChapterCount;
  List<ChapterModel> get chapterList => resourceState.chapterGroupChapterList;
  // 全屏时背景是黑色
  Color get textColor => option.backgroundColor == null
      ? isFullscreen
            ? uiViewModel.textColor
            : CalculateColorUtils.calculateTextColor(Colors.white)
      : CalculateColorUtils.calculateTextColor(Colors.white);
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  bool _showBottomSheet = false;

  List<EffectCleanup> _effectCleanups = [];

  int initialIndex = 0;

  @override
  void initState() {
    var chapterListLoaded = resourceState.chapterListLoaded.value;
    _activatedIndex = resourceState.playingChapterGroupToChapterIndex;
    initialIndex = _activatedIndex > 0 ? _activatedIndex : 0;
    _scrollController = ScrollController();

    _effectCleanups.addAll([
      if (!chapterListLoaded)
        effect(() {
          var loaded = resourceState.chapterListLoaded.value;
          if (loaded) {
            untracked(() {
              _activatedIndex = resourceState.playingChapterGroupToChapterIndex;
              initialIndex = _activatedIndex > 0 ? _activatedIndex : 0;
              if (!_showBottomSheet) {
                if (_gridObserverController == null &&
                    _observerController == null) {
                  _initObserverController();
                }
                _gridObserverController?.jumpTo(
                  index: initialIndex,
                  isFixedHeight: true,
                );
                _observerController?.jumpTo(
                  index: initialIndex,
                  isFixedHeight: true,
                );
              }
            });
          }
        }),
      effect(() {
        int apiActivatedIndex = resourceState.apiActivatedIndex.value;
        int apiGroupActivatedIndex = resourceState.apiGroupActivatedIndex.value;
        int chapterGroupActivatedIndex =
            resourceState.chapterGroupActivatedIndex.value;
        untracked(() {
          // int index = resourceState.playingChapterGroupToChapterIndex;
          int index = resourceState.activatedChapterGroupToChapterIndex;
          if (index == 0 && !resourceState.chapterAsc.value) {
            index = resourceState.activatedChapterGroupList.length;
          }
          if (index < 0) {
            index = 0;
          }
          if (!_showBottomSheet) {
            if (_gridObserverController == null &&
                _observerController == null) {
              _initObserverController();
            }
            _gridObserverController?.jumpTo(index: index, isFixedHeight: true);
            _observerController?.jumpTo(index: index, isFixedHeight: true);
          }
        });
      }),
    ]);

    super.initState();
  }

  @override
  void dispose() {
    for (var element in _effectCleanups) {
      element.call();
    }
    int index = resourceState.playingChapterGroupToChapterIndex;
    index = index >= 0 ? index : 0;
    if (_scrollController != null && index != _activatedIndex) {
      option.onDispose?.call(index);
    }
    _scrollController?.dispose();
    super.dispose();
  }

  void _initObserverController() {
    if (option.isGrid && resourceState.maxChapterTitleLen < 8) {
      _initGridObserverController();
    } else {
      _initListObserverController();
    }
  }

  void _initGridObserverController() {
    if (_gridObserverController == null) {
      _gridObserverController = GridObserverController(
        controller: _scrollController,
      )..initialIndex = initialIndex;
    } else {
      _gridObserverController?.initialIndex = initialIndex;
    }
  }

  void _initListObserverController() {
    if (_observerController == null) {
      _observerController = ListObserverController(
        controller: _scrollController,
      )..initialIndex = initialIndex;
    } else {
      _observerController?.initialIndex = initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      if (!resourceState.chapterListLoaded.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (chapterCount <= 1) {
        return Container();
      }
      return Column(
        children: [
          // _createHeader(context),
          ChapterGroupWidget(
            option: SourceOptionModel(),
            uiViewModel: uiViewModel,
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(
              bottom: StyleConstant.safeSpace / 2,
            ),
          ),
          // 添加分割线
          Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
          ),
          Watch(
            (context) => resourceState.chapterListLoaded.value
                ? option.bottomSheet
                      ? _bottomSheetList(context)
                      : option.singleHorizontalScroll
                      ? Padding(
                          padding: EdgeInsetsGeometry.symmetric(
                            vertical: StyleConstant.safeSpace,
                          ),
                          child: _horizontalScroll(context),
                        )
                      : _list(context)
                : Text("列表加载中...", style: TextStyle(color: textColor),),
          ),
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
        child: option.isGrid && resourceState.maxChapterTitleLen < 8
            ? _gridView(context)
            : _listView(context),
      ),
    );
  }

  // bottomSheet弹出内容
  Widget _bottomSheetList(BuildContext context) {
    return Expanded(
      child: option.isGrid && resourceState.maxChapterTitleLen < 8
          ? _gridView(context)
          : _listView(context),
    );
  }

  // 列表方式
  Widget _listView(BuildContext context) {
    _initListObserverController();
    return Watch((context) {
      var list = resourceState.chapterAsc.value
          ? chapterList
          : chapterList.reversed.toList();
      String activeKey =
          "${resourceState.resourcePlayingState.value.apiIndex}-${resourceState.resourcePlayingState.value.apiGroupIndex}-${resourceState.resourcePlayingState.value.chapterGroupIndex}-${resourceState.resourcePlayingState.value.chapterIndex}";

      return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: ListViewObserver(
          controller: _observerController,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: list.length,
            itemBuilder: (context, index) {
              var item = list[index];
              var currentItemKey =
                  "${resourceState.apiActivatedIndex.value}-${resourceState.apiGroupActivatedIndex.value}-${resourceState.chapterGroupActivatedIndex.value}-${item.index}";
              return Container(
                padding: EdgeInsetsGeometry.only(
                  top: index == 0 ? 0 : StyleConstant.safeSpace / 2,
                  bottom: StyleConstant.safeSpace / 2,
                ),
                child: ChapterWidget(
                  key: ValueKey(
                    "chapter_${option.bottomSheet}_listView_$currentItemKey",
                  ),
                  chapter: item,
                  textAlign: TextAlign.left,
                  // activated: item.index == activeIndex,
                  activated: currentItemKey == activeKey,
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
                    resourceState.chapterActivatedIndex.value = item.index;
                  },
                ),
              );
            },
          ),
        ),
      );
    });
  }

  // 列表方式（grid）
  Widget _gridView(BuildContext context) {
    _initGridObserverController();
    return Watch((context) {
      var list = resourceState.chapterAsc.value
          ? chapterList
          : chapterList.reversed.toList();
      if (list.isEmpty) {
        return Container();
      }
      String activeKey =
          "${resourceState.resourcePlayingState.value.apiIndex}-${resourceState.resourcePlayingState.value.apiGroupIndex}-${resourceState.resourcePlayingState.value.chapterGroupIndex}-${resourceState.resourcePlayingState.value.chapterIndex}";

      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 0) {
            // 如果宽度无效，返回空容器或者使用默认宽度
            return Container();
          }
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
            ),
            child: GridViewObserver(
              controller: _gridObserverController,
              child: GridView.builder(
                controller: _scrollController,
                itemCount: list.length,
                gridDelegate: SliverGridDelegateWithExtentAndRatio(
                  crossAxisSpacing: StyleConstant.safeSpace,
                  mainAxisSpacing: StyleConstant.safeSpace,
                  maxCrossAxisExtent: StyleConstant.chapterGridMaxWidth,
                  childAspectRatio: StyleConstant.chapterGridRatio,
                ),
                itemBuilder: (context, index) {
                  var item = list[index];
                  var currentItemKey =
                      "${resourceState.apiActivatedIndex.value}-${resourceState.apiGroupActivatedIndex.value}-${resourceState.chapterGroupActivatedIndex.value}-${item.index}";
                  return ChapterWidget(
                    key: ValueKey(
                      "chapter_${option.bottomSheet}_gridView_$currentItemKey",
                    ),
                    chapter: item,
                    // activated: item.index == activeIndex,
                    activated: currentItemKey == activeKey,
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
                      resourceState.chapterActivatedIndex.value = item.index;
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    });
  }

  // 横向滚动
  Widget _horizontalScroll(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: StyleConstant.safeSpace),
      width: double.infinity,
      height: StyleConstant.chapterHeight,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          scrollbars: false,
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
        ),
        child: Watch((context) {
          var list = resourceState.chapterAsc.value
              ? chapterList
              : chapterList.reversed.toList();
          String activeKey =
              "${resourceState.resourcePlayingState.value.apiIndex}-${resourceState.resourcePlayingState.value.apiGroupIndex}-${resourceState.resourcePlayingState.value.chapterGroupIndex}-${resourceState.resourcePlayingState.value.chapterIndex}";

          return ListViewObserver(
            controller: _observerController,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              itemBuilder: (context, index) {
                var item = list[index];
                var currentItemKey =
                    "${resourceState.apiActivatedIndex.value}-${resourceState.apiGroupActivatedIndex.value}-${resourceState.chapterGroupActivatedIndex.value}-${item.index}";
                return Container(
                  margin: EdgeInsets.only(right: StyleConstant.safeSpace),
                  child: AspectRatio(
                    aspectRatio: StyleConstant.chapterGridRatio,
                    child: ChapterWidget(
                      key: ValueKey("chapter_horizontalScroll_$currentItemKey"),
                      chapter: item,
                      // activated: item.index == activeIndex,
                      activated: currentItemKey == activeKey,
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
                        resourceState.chapterActivatedIndex.value = item.index;
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
