class ChapterModel {
  final String name;

  /// 是否选中
  bool activated;

  /// 是否播放中
  bool playing;

  /// 下标，用于升序和降序
  int index;

  /// 播放链接
  final String? playUrl;

  final String? danmakuPath;
  final String? subtitlePath;

  Map<String, dynamic>? extras;
  Map<String, String>? httpHeaders;
  Duration? start;
  Duration? end;

  /// 历史播放时间
  Duration? historyDuration;

  ChapterModel({
    required this.name,
    this.activated = false,
    this.playing = false,
    required this.index,
    this.playUrl,
    this.danmakuPath,
    this.subtitlePath,
    this.extras,
    this.httpHeaders,
    this.start,
    this.end,
    this.historyDuration,
  });
}
