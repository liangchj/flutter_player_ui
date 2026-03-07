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
  final Function(SourceOptionDialogType)? dialogFn;

  SourceOptionModel({
    this.onClose,
    this.singleHorizontalScroll = false,
    this.listVerticalScroll = true,
    this.isGrid = false,
    this.isSelect = false,
    this.bottomSheet = false,
    this.onDispose,
    this.backgroundColor,
    this.dialogFn,
  });
}

enum SourceOptionDialogType {
  open,
  close,
  none,
}