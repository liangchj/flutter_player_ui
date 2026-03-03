import 'package:flutter/material.dart';
import '../view_model/ui_view_model.dart';

class CenterLoadingUI extends StatefulWidget {
  const CenterLoadingUI({super.key, required this.uiViewModel});
  final UIViewModel uiViewModel;

  @override
  State<CenterLoadingUI> createState() => _CenterLoadingUIState();
}

class _CenterLoadingUIState extends State<CenterLoadingUI> {
  UIViewModel get uiViewModel => widget.uiViewModel;
  Color get backgroundColor => uiViewModel.backgroundColor;
  Color get textColor => uiViewModel.textColor;
  Color get activatedTextColor => uiViewModel.activatedTextColor;

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: activatedTextColor));
  }
}
