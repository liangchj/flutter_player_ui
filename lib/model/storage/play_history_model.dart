class PlayHistoryModel {
  // 本地视频为播放地址
  // 网络视频为资源id
  final String id;
  final String? apiKey;
  final String? sourceGroupKey;
  // 章节地址（有些网站基础地址可能会变）
  final String chapterUrl;
  // 章节索引（有些网站的倒叙的列表，直接使用下标不对）
  final int chapterIndex;
  final String chapterName;
  final int durationInMilli;
  final int positionInMilli;
  final DateTime time;

  PlayHistoryModel({
    required this.id,
    required this.apiKey,
    required this.sourceGroupKey,
    required this.chapterUrl,
    required this.chapterIndex,
    required this.chapterName,
    required this.durationInMilli,
    required this.positionInMilli,
    required this.time,
  });

  double get progress => positionInMilli / durationInMilli;

  String get key => apiKey == null
      ? id
      : 'id:${id}_apiKey:${apiKey}_sourceGroupKey:$sourceGroupKey';
}
