import 'package:flutter/material.dart';

class ResourceHeaderWidget extends StatefulWidget {
  const ResourceHeaderWidget({
    super.key,
    required this.left,
    required this.isSelect,
    required this.isDialog,
    this.right,
  });
  final Widget left;
  final bool isSelect;
  final bool isDialog;
  final Widget? right;

  @override
  State<ResourceHeaderWidget> createState() => _ResourceHeaderWidgetState();
}

class _ResourceHeaderWidgetState extends State<ResourceHeaderWidget>
    with SingleTickerProviderStateMixin {
  bool get isSelect => widget.isSelect;
  bool get isDialog => widget.isDialog;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    if (isDialog) {
      _tabController = TabController(length: 1, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return /*isDialog
        ? _dialogHeader()
        : */isSelect
        ? _selectHeader()
        : _normalHeader();
  }

  Widget _dialogHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TabBar(controller: _tabController, tabs: [widget.left]),
        widget.right ?? Container(),
      ],
    );
  }

  Widget _selectHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [widget.left, widget.right ?? Container()],
    );
  }

  Widget _normalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [widget.left, widget.right ?? Container()],
    );
  }
}

