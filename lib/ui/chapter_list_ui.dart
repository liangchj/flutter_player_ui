import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../controller/ui_controller.dart';
import '../enum/player_ui_key_enum.dart';
import '../model/source_option_model.dart';
import '../state/resource_state.dart';
import '../widget/chapter_list_widget.dart';

class ChapterListUI extends StatefulWidget {
  const ChapterListUI({
    super.key,
    required this.uiController,
    this.bottomSheet = false,
  });
  final UIController uiController;
  final bool bottomSheet;

  @override
  State<ChapterListUI> createState() => _ChapterListUIState();
}

class _ChapterListUIState extends State<ChapterListUI> {
  UIController get uiController => widget.uiController;

  ResourceState get resourceState =>
      uiController.playerController.resourceState;
  String get apiName =>
      resourceState.activatedApi?.api?.name ??
      resourceState.activatedApi?.api?.enName ??
      "";
  String get activeApiSourceName =>
      resourceState.activatedSourceGroup?.name ??
      resourceState.activatedSourceGroup?.enName ??
      "";

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              uiController.uiState.commonUISizeModel.value.maxHeight ??
              double.infinity,
          maxWidth:
              uiController.uiState.commonUISizeModel.value.maxWidth ??
              double.infinity,
        ),
        child: Container(
          key: ValueKey("chapterListUI"),
          color: uiController.backgroundColor,
          width: uiController.uiState.commonUISizeModel.value.width,
          height: uiController.uiState.commonUISizeModel.value.height,
          padding: EdgeInsetsGeometry.symmetric(
            vertical: StyleConstant.safeSpace / 2,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: StyleConstant.safeSpace),
                child: _createApiSource(),
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
              _createHeader(),
              Expanded(
                child: ChapterListWidget(
                  uiController: uiController,
                  option: SourceOptionModel(
                    isGrid: true,
                    // singleHorizontalScroll: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  LayoutBuilder _createApiSource() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) {
          return const SizedBox();
        }
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: StyleConstant.safeSpace,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "资源：",
                      style: TextStyle(
                        color: uiController.textColor,
                        fontSize: StyleConstant.titleTextSize,
                      ),
                    ),
                    // 总共能够显示12个字
                    InkWell(
                      onTap: () {
                        uiController.onlyShowUIByKeyList([
                          UIKeyEnum.apiSourceUI.name,
                        ]);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 只能显示5个字的宽度
                          Watch(
                            (context) => apiName.isEmpty
                                ? Container()
                                : ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: StyleConstant.titleTextSize * 5,
                                    ),
                                    child: Text(
                                      apiName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                      style: TextStyle(
                                        color: uiController.textColor,
                                        fontSize: StyleConstant.titleTextSize,
                                      ),
                                    ),
                                  ),
                          ),
                          Watch(
                            (context) =>
                                apiName.isNotEmpty &&
                                    activeApiSourceName.isNotEmpty
                                ? Text(
                                    " - ",
                                    style: TextStyle(
                                      color: uiController.textColor,
                                      fontSize: StyleConstant.titleTextSize,
                                    ),
                                  )
                                : Container(),
                          ),
                          Watch(
                            (context) => activeApiSourceName.isEmpty
                                ? Container()
                                : ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: StyleConstant.titleTextSize * 5,
                                    ),
                                    child: Text(
                                      activeApiSourceName,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        color: uiController.textColor,
                                        fontSize: StyleConstant.titleTextSize,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  LayoutBuilder _createHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= 0) {
          return const SizedBox();
        }
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(
                  horizontal: StyleConstant.safeSpace,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Watch(
                      (context) => Text(
                        "章节(${uiController.playerController.resourceState.activatedChapterCount})：",
                        style: TextStyle(
                          color: uiController.textColor,
                          fontSize: StyleConstant.titleTextSize,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip:
                          uiController
                              .playerController
                              .resourceState
                              .chapterAsc
                              .value
                          ? "正序"
                          : "倒叙",
                      icon:
                          uiController
                              .playerController
                              .resourceState
                              .chapterAsc
                              .value
                          ? Icon(Icons.upgrade_rounded)
                          : Icon(Icons.download_rounded),
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(EdgeInsets.zero),
                      ),
                      onPressed: () {
                        uiController
                            .playerController
                            .resourceState
                            .chapterAsc
                            .value = !uiController
                            .playerController
                            .resourceState
                            .chapterAsc
                            .value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
