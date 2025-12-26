import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../controller/ui_controller.dart';
import '../enum/player_ui_key_enum.dart';
import '../model/source_option_model.dart';
import '../state/resource_state.dart';
import '../widget/api_widget.dart';
import '../widget/source_group_widget.dart';

class ApiSourceUI extends StatefulWidget {
  const ApiSourceUI({
    super.key,
    required this.uiController,
    this.bottomSheet = false,
  });
  final UIController uiController;
  final bool bottomSheet;

  @override
  State<ApiSourceUI> createState() => _ApiSourceUIState();
}

class _ApiSourceUIState extends State<ApiSourceUI> {
  UIController get uiController => widget.uiController;
  Color get backgroundColor => uiController.backgroundColor;
  Color get textColor => uiController.textColor;
  Color get activatedTextColor => uiController.activatedTextColor;

  ResourceState get resourceState =>
      uiController.playerController.resourceState;
  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              uiController.uiState.commonUISizeModel.value.maxHeight ??
              double.infinity,
          maxWidth:
              uiController.uiState.commonUISizeModel.value.maxWidth ??
              double.infinity,
        ),
        child: Container(
          key: Key("fullscreenApiSourceUI"),
          color: backgroundColor,
          width: uiController.uiState.commonUISizeModel.value.width,
          height: uiController.uiState.commonUISizeModel.value.height,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    color: activatedTextColor,
                    onPressed: () {
                      uiController.onlyShowUIByKeyList([
                        UIKeyEnum.chapterListUI.name,
                      ]);
                    },
                  ),
                  CloseButton(
                    color: activatedTextColor,
                    onPressed: () {
                      uiController.hideUIByKeyList([
                        UIKeyEnum.apiSourceUI.name,
                      ]);
                    },
                  ),
                ],
              ),
              // api
              _createApiUI(),
              // api下的资源组
              _createSourceGroupUI(),
            ],
          ),
        ),
      ),
    );
  }

  _createApiUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Watch((context) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: StyleConstant.safeSpace),
            child: Text(
              "资源API(${resourceState.apiCount})：",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: uiController.textColor,
                fontSize: StyleConstant.titleTextSize,
              ),
            ),
          );
        }),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: StyleConstant.safeSpace,
            horizontal: StyleConstant.safeSpace,
          ),
          child: ApiWidget(
            uiController: uiController,
            option: SourceOptionModel(singleHorizontalScroll: true),
          ),
        ),
      ],
    );
  }

  _createSourceGroupUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Watch((context) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: StyleConstant.safeSpace),
            child: Text(
              "播放组(${resourceState.activatedApiSourceGroupCount})：",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: uiController.textColor,
                fontSize: StyleConstant.titleTextSize,
              ),
            ),
          );
        }),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: StyleConstant.safeSpace,
            horizontal: StyleConstant.safeSpace,
          ),
          child: SourceGroupWidget(
            uiController: uiController,
            option: SourceOptionModel(singleHorizontalScroll: true),
          ),
        ),
      ],
    );
  }
}
