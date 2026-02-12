import 'package:flutter/material.dart';

class IconConstant {
  static const ImageIcon backIcon = ImageIcon(
    AssetImage("assets/icons/back.png", package: "flutter_player_ui"),
  );
  static const ImageIcon settingIcon = ImageIcon(
    AssetImage("assets/icons/more_h.png", package: "flutter_player_ui"),
  );

  // 锁
  static const ImageIcon lockedIcon = ImageIcon(
    AssetImage("assets/icons/locked.png", package: "flutter_player_ui"),
  );
  static const ImageIcon unLockedIcon = ImageIcon(
    AssetImage("assets/icons/unlocked.png", package: "flutter_player_ui"),
  );

  // 截图
  static const ImageIcon screenshotIcon = ImageIcon(
    AssetImage("assets/icons/screenshot.png", package: "flutter_player_ui"),
  );

  // 中间的播放图标
  static const ImageIcon centerPlayIcon = ImageIcon(
    AssetImage("assets/icons/center_play.png", package: "flutter_player_ui"),
  );
  // 中间的暂停图标
  static const ImageIcon centerPauseIcon = ImageIcon(
    AssetImage("assets/icons/center_pause.png", package: "flutter_player_ui"),
  );
  // 中间的重新播放图标
  static const Icon centerReplayPlayIcon = Icon(Icons.replay_rounded);

  // 底部播放图标
  static const ImageIcon bottomPlayIcon = ImageIcon(
    AssetImage("assets/icons/bottom_play.png", package: "flutter_player_ui"),
  );
  // 底部暂停图标
  static const ImageIcon bottomPauseIcon = ImageIcon(
    AssetImage("assets/icons/bottom_pause.png", package: "flutter_player_ui"),
  );
  // 底部重新播放图标
  static const ImageIcon bottomReplayPlayIcon = ImageIcon(
    AssetImage("assets/icons/bottom_replay.png", package: "flutter_player_ui"),
  );

  // 下一个视频图标
  static const ImageIcon nextPlayIcon = ImageIcon(
    AssetImage(
      "assets/icons/bottom_next_play.png",
      package: "flutter_player_ui",
    ),
  );

  // 进入全屏图标
  // static const Icon entryFullScreenIcon = Icon(Icons.fullscreen_rounded);
  // // 退出全屏图标
  // static const Icon exitFullScreenIcon = Icon(Icons.fullscreen_exit_rounded);

  /*static final Widget danmakuOpen = Image.asset(
    "assets/icons/danmaku_open.png",
    width: 24,
    height: 24,
  );
  static final Widget danmakuClose = Image.asset(
    "assets/icons/danmaku_close.png",
    width: 24,
    height: 24,
  );*/
  // 弹幕开
  static final String danmakuOpenImgPath = "assets/icons/danmaku_open.png";
  static final ImageIcon danmakuOpen = ImageIcon(
    AssetImage(danmakuOpenImgPath, package: "flutter_player_ui"),
  );
  static final String danmakuOpenColorImgPath =
      "assets/icons/danmaku_open_color.png";
  static final AssetImage danmakuOpenColor = AssetImage(
    danmakuOpenColorImgPath,
    package: "flutter_player_ui",
  );
  static final String danmakuOpenCircleImgPath =
      "assets/icons/danmaku_open_circle.png";
  static final AssetImage danmakuOpenCircle = AssetImage(
    danmakuOpenCircleImgPath,
    package: "flutter_player_ui",
  );

  // 弹幕关
  static final String danmakuCloseImgPath = "assets/icons/danmaku_close.png";
  static final ImageIcon danmakuClose = ImageIcon(
    AssetImage(danmakuCloseImgPath, package: "flutter_player_ui"),
  );
  // 弹幕设置
  static const ImageIcon danmakuSetting = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_setting.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕滚动开
  static const ImageIcon danmakuScrollOpen = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_scroll_open.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕滚动关
  static const ImageIcon danmakuScrollClose = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_scroll_close.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕顶部开
  static const ImageIcon danmakuTopOpen = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_top_open.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕顶部关
  static const ImageIcon danmakuTopClose = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_top_close.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕底部开
  static const ImageIcon danmakuBottomOpen = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_bottom_open.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕底部关
  static const ImageIcon danmakuBottomClose = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_bottom_close.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕彩色开
  static const ImageIcon danmakuColorOpen = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_color_open.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕彩色关
  static const ImageIcon danmakuColorClose = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_color_close.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕重复开
  static const ImageIcon danmakuRepeatOpen = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_repeat_open.png",
      package: "flutter_player_ui",
    ),
  );

  // 弹幕重复关
  static const ImageIcon danmakuRepeatClose = ImageIcon(
    AssetImage(
      "assets/icons/danmaku_repeat_close.png",
      package: "flutter_player_ui",
    ),
  );
}
