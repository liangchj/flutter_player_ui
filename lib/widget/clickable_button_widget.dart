import 'package:flutter/material.dart';

import '../constant/style_constant.dart';

class ClickableButtonWidget extends StatelessWidget {
  const ClickableButtonWidget({
    super.key,
    required this.text,
    required this.activated,
    required this.isCard,
    this.onClick,
    this.left,
    this.right,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.padding,
    this.showBorder = true,
    this.activatedTextColor,
    this.unActivatedTextColor,
    this.activatedBackgroundColor,
    this.unActivatedBackgroundColor,
    this.activatedBorderColor,
    this.unActivatedBorderColor,
  });
  final String text;
  final bool activated;
  final bool isCard;
  final VoidCallback? onClick;
  final Widget? left;
  final Widget? right;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final EdgeInsetsGeometry? padding;
  final bool showBorder;
  final Color? activatedTextColor;
  final Color? unActivatedTextColor;
  final Color? activatedBackgroundColor;
  final Color? unActivatedBackgroundColor;
  final Color? activatedBorderColor;
  final Color? unActivatedBorderColor;

  @override
  Widget build(BuildContext context) {
    ShapeBorder? shape;
    late Color textFontColor;
    if (activated) {
      textFontColor = activatedTextColor ?? StyleConstant.primaryColor;
      if (showBorder) {
        shape = RoundedRectangleBorder(
          //边框颜色
          side: BorderSide(
            color: activatedBorderColor ?? activatedTextColor ?? textFontColor,
            width: StyleConstant.borderWidth,
          ),
          //边框圆角
          borderRadius: BorderRadius.all(
            Radius.circular(StyleConstant.borderRadius),
          ),
        );
      }
    } else {
      textFontColor =
          unActivatedTextColor ?? StyleConstant.defaultUnactiveTextColor;
      if (showBorder) {
        shape = RoundedRectangleBorder(
          //边框颜色
          side: BorderSide(
            color: unActivatedBorderColor ?? textFontColor,
            width: StyleConstant.borderWidth,
          ),
          //边框圆角
          borderRadius: BorderRadius.all(
            Radius.circular(StyleConstant.borderRadius),
          ),
        );
      }
    }
    return MaterialButton(
      color: activated
          ? activatedBackgroundColor ?? textFontColor.withValues(alpha: 0.2)
          : unActivatedBackgroundColor,
      //边框样式
      shape: shape,
      onPressed: () => onClick?.call(),
      child: Padding(
        padding: padding ?? EdgeInsetsGeometry.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (left != null) left!,
            Expanded(
              child: Text(
                text,
                maxLines: maxLines,
                overflow: overflow,
                textAlign: textAlign,
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
