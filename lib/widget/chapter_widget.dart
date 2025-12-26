import 'package:flutter/material.dart';

import '../constant/style_constant.dart';
import '../model/resource/chapter_model.dart';

class ChapterWidget extends StatelessWidget {
  const ChapterWidget({
    super.key,
    required this.chapter,
    required this.activated,
    this.isCard = false,
    this.onClick,
    this.left,
    this.right,
    required this.activatedTextColor,
    required this.unActivatedTextColor,
    this.activatedBackgroundColor,
    this.unActivatedBackgroundColor,
    this.activatedBorderColor,
    this.unActivatedBorderColor,
    this.textAlign,
    this.maxLines = 1,
  });
  final ChapterModel chapter;
  final bool activated;
  final bool isCard;
  final VoidCallback? onClick;
  final Widget? left;
  final Widget? right;
  final Color activatedTextColor;
  final Color unActivatedTextColor;
  final Color? activatedBackgroundColor;
  final Color? unActivatedBackgroundColor;
  final Color? activatedBorderColor;
  final Color? unActivatedBorderColor;
  final TextAlign? textAlign;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    late ShapeBorder shape;
    late Color textFontColor;
    if (activated) {
      shape = RoundedRectangleBorder(
        //边框颜色
        side: BorderSide(
          color: activatedBorderColor ?? activatedTextColor,
          width: StyleConstant.chapterBorderWidth,
        ),
        //边框圆角
        borderRadius: BorderRadius.all(
          Radius.circular(StyleConstant.borderRadius),
        ),
      );
      textFontColor = activatedTextColor;
    } else {
      shape = RoundedRectangleBorder(
        //边框颜色
        side: BorderSide(
          color: unActivatedBorderColor ?? StyleConstant.chapterBackgroundColor,
          width: StyleConstant.chapterBorderWidth,
        ),
        //边框圆角
        borderRadius: BorderRadius.all(
          Radius.circular(StyleConstant.borderRadius),
        ),
      );
      textFontColor = unActivatedTextColor;
    }
    return MaterialButton(
      color: activated
          ? activatedBackgroundColor ?? textFontColor.withValues(alpha: 0.2)
          : unActivatedBackgroundColor,
      //边框样式
      shape: shape,
      onPressed: () => onClick?.call(),
      child: Padding(
        padding: StyleConstant.chapterPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (left != null) left!,
            Expanded(
              child: Text(
                chapter.name,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                textAlign: textAlign ?? TextAlign.center,
                style: TextStyle(color: textFontColor),
              ),
            ),
            if (right != null) right!,
          ],
        ),
      ),
    );
  }
}
