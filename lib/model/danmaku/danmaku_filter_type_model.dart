// 弹幕过滤类型
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

class DanmakuFilterTypeModel {
  final String enName;
  final String chName;
  final List<int> modeList;
  final ImageIcon openImageIcon;
  final ImageIcon closeImageIcon;
  final Signal<bool> filter;

  DanmakuFilterTypeModel({
    required this.enName,
    required this.chName,
    required this.modeList,
    required this.openImageIcon,
    required this.closeImageIcon,
    required this.filter,
  });
}