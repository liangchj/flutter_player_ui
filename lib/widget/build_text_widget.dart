import 'package:flutter/material.dart';

/// 文本框Widget
class BuildTextWidget extends StatelessWidget {
  const BuildTextWidget({
    super.key,
    required this.text,
    this.style,
    this.edgeInsets,
  });
  final String text;
  final TextStyle? style;
  final EdgeInsets? edgeInsets;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeInsets ?? const EdgeInsets.only(left: 5, right: 5),
      child: Text(text, style: style ?? const TextStyle(color: Colors.white)),
    );
  }
}
