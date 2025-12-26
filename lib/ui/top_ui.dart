import 'package:flutter/material.dart';
import '../constant/style_constant.dart';
import '../controller/ui_controller.dart';
import '../enum/player_ui_key_enum.dart';
import '../utils/calculate_color_utils.dart';

class TopUI extends StatefulWidget {
  const TopUI({super.key, required this.uiController});
  final UIController uiController;

  @override
  State<TopUI> createState() => _TopUIState();
}

class _TopUIState extends State<TopUI> {
  UIController get uiController => widget.uiController;

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
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back_ios,
              color: _color,
            ),
          ),
          // 标题
          Expanded(
            child: Text(
              "标题",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _color),
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
                  uiController.onlyShowUIByKeyList([UIKeyEnum.settingUI.name]);
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
