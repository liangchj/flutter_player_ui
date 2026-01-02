import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../constant/style_constant.dart';
import '../enum/player_ui_key_enum.dart';
import '../model/source_option_model.dart';
import '../state/resource_state.dart';
import '../view_model/ui_view_model.dart';
import '../widget/api_widget.dart';
import '../widget/source_group_widget.dart';

class ApiSourceUI extends StatefulWidget {
  const ApiSourceUI({
    super.key,
    required this.uiViewModel,
    this.bottomSheet = false,
  });
  final UIViewModel uiViewModel;
  final bool bottomSheet;

  @override
  State<ApiSourceUI> createState() => _ApiSourceUIState();
}

class _ApiSourceUIState extends State<ApiSourceUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  Color get backgroundColor => uiViewModel.backgroundColor;
  Color get textColor => uiViewModel.textColor;
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  ResourceState get resourceState => uiViewModel.playerViewModel.resourceState;
  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              uiViewModel.uiState.commonUISizeModel.value.maxHeight ??
              double.infinity,
          maxWidth:
              uiViewModel.uiState.commonUISizeModel.value.maxWidth ??
              double.infinity,
        ),
        child: Container(
          key: Key("fullscreenApiSourceUI"),
          color: backgroundColor,
          width: uiViewModel.uiState.commonUISizeModel.value.width,
          height: uiViewModel.uiState.commonUISizeModel.value.height,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  BackButton(
                    color: activatedTextColor,
                    onPressed: () {
                      uiViewModel.onlyShowUIByKeyList([
                        UIKeyEnum.chapterListUI.name,
                      ]);
                    },
                  ),
                  CloseButton(
                    color: activatedTextColor,
                    onPressed: () {
                      uiViewModel.hideUIByKeyList([UIKeyEnum.apiSourceUI.name]);
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
                color: uiViewModel.textColor,
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
            uiViewModel: uiViewModel,
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
                color: uiViewModel.textColor,
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
            uiViewModel: uiViewModel,
            option: SourceOptionModel(singleHorizontalScroll: true),
          ),
        ),
      ],
    );
  }
}
