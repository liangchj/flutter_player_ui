import 'dart:ui';

class SourceOptionModel {
  final VoidCallback? onClose;
  final bool singleHorizontalScroll;
  final bool listVerticalScroll;
  final bool isGrid;
  final bool isSelect;
  final bool bottomSheet;
  final Function(int)? onDispose;
  final Color? backgroundColor;

  SourceOptionModel({
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.isSelect = false,
    this.bottomSheet = false,
    this.onDispose,
    this.backgroundColor
  });
}