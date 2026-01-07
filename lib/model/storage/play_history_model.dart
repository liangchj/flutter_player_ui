class PlayHistoryModel {
  // 本地视频为播放地址
  // 网络视频为资源id
  final String resourceId;
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
    required this.resourceId,
    this.apiKey,
    this.sourceGroupKey,
    required this.chapterUrl,
    required this.chapterIndex,
    required this.chapterName,
    required this.durationInMilli,
    required this.positionInMilli,
    required this.time,
  });

  double get progress => positionInMilli / durationInMilli;

  String get key => apiKey == null
      ? resourceId
      : 'resourceId:${resourceId}_apiKey:${apiKey}_sourceGroupKey:$sourceGroupKey';

  Map<String, dynamic> toJson() {
    return {
      'resourceId': resourceId,
      'apiKey': apiKey,
      'sourceGroupKey': sourceGroupKey,
      'chapterUrl': chapterUrl,
      'chapterIndex': chapterIndex,
      'chapterName': chapterName,
      'durationInMilli': durationInMilli,
      'positionInMilli': positionInMilli,
      'time': time.millisecondsSinceEpoch,
    };
  }
}
