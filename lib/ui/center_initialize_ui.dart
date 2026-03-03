import 'package:flutter/material.dart';
import '../constant/style_constant.dart';
import '../view_model/ui_view_model.dart';

class CenterInitializeUI extends StatefulWidget {
  const CenterInitializeUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<CenterInitializeUI> createState() => _CenterInitializeUIState();
}

class _CenterInitializeUIState extends State<CenterInitializeUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  Color get backgroundColor => uiViewModel.backgroundColor;
  Color get textColor => uiViewModel.textColor;
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: UnconstrainedBox(
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            //设置四周圆角 角度
            borderRadius: const BorderRadius.all(
              Radius.circular(StyleConstant.borderRadius),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: activatedTextColor),
              const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
              Text("视频初始化中...", style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
