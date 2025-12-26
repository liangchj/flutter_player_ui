import 'package:flutter/material.dart';

enum DanmakuItemType { scroll, top, bottom, special }

class DanmakuItemModel {
  DanmakuItemModel(
    this.text, {
    this.color = Colors.white,
    this.type = DanmakuItemType.scroll,
    required this.time,
    this.fontSize,
    this.createTime,
    this.poolType,
    this.sendUserId,
    required this.danmakuId,
    this.level,
  });

  /// 弹幕文本
  final String text;

  /// 弹幕颜色
  final Color color;

  /// 弹幕类型
  final DanmakuItemType type;

  // 	视频内弹幕出现时间	毫秒
  final int time;
  // 弹幕字号
  final double? fontSize;
  // 弹幕发送时间	时间戳
  final int? createTime;
  // 弹幕池类型
  final String? poolType;
  // 发送者mid的HASH	string	用于屏蔽用户和查看用户发送的所有弹幕 也可反查用户id
  final String? sendUserId;
  // 弹幕dmid	int64	唯一 可用于操作参数
  final String danmakuId;
  // 弹幕的屏蔽等级
  final int? level;
}
