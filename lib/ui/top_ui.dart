import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../constant/style_constant.dart';
import '../enum/player_ui_key_enum.dart';
import '../utils/calculate_color_utils.dart';
import '../view_model/ui_view_model.dart';

class TopUI extends StatefulWidget {
  const TopUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<TopUI> createState() => _TopUIState();
}

class _TopUIState extends State<TopUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;

  Color get _color => CalculateColorUtils.calculateTextColor(Colors.black);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: StyleConstant.topUILinearGradient),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 返回按钮
          IconButton(
            onPressed: () => uiViewModel.playerViewModel.fullscreenUtils
                .exitFullscreen(context),
            icon: Icon(Icons.arrow_back_ios, color: _color),
          ),
          // 标题
          Expanded(
            child: Watch(
              (context) => Text(
                "${uiViewModel.playerViewModel.resourceState.playingChapter?.name}",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: _color),
              ),
            ),
            /*child: Obx(
                  () => Text(
                "标题",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),*/
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 最右边的按钮
              IconButton(
                onPressed: () {
                  uiViewModel.onlyShowUIByKeyList([UIKeyEnum.settingUI.name]);
                },
                icon: Icon(Icons.more_vert, color: _color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
