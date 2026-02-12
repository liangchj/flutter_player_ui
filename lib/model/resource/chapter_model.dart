import 'dart:convert';

import '../file_source_model.dart';

List<ChapterModel> chapterModelListFromJsonStr(String str) =>
    List<ChapterModel>.from(
      json.decode(str).map((x) => ChapterModel.fromJson(x)),
    );

List<ChapterModel> chapterModelListFromJson(List<Map<String, dynamic>> data) =>
    List<ChapterModel>.from(data.map((x) => ChapterModel.fromJson(x)));

List<ChapterModel> chapterModelListFromDynamic(dynamic data) {
  if (data is List<ChapterModel>) {
    return data;
  } else if (data is List<dynamic>) {
    return List<ChapterModel>.from(
      data.map((x) => ChapterModel.fromJson(x as Map<String, dynamic>)),
    );
  } else if (data is List<Map<String, dynamic>>) {
    return chapterModelListFromJson(data);
  } else {
    return chapterModelListFromJsonStr(data.toString());
  }
}

String chapterModelListToJson(List<ChapterModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

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

  final FileSourceModel? danmakuSource;
  final FileSourceModel? subtitleSource;

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
    this.danmakuSource,
    this.subtitleSource,
    this.extras,
    this.httpHeaders,
    this.start,
    this.end,
    this.historyDuration,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    var activated = json['activated'];
    var playing = json['playing'];
    var index = json['index'];
    var extrasVar = json['extras'];
    Map<String, dynamic>? extras;
    if (extrasVar != null) {
      try {
        extras = Map.from(extrasVar);
      } catch (_) {}
    }
    var httpHeadersVar = json['httpHeaders'];
    Map<String, String>? httpHeaders;
    if (httpHeadersVar != null) {
      try {
        httpHeaders = Map<String, String>.from(httpHeadersVar);
      } catch (_) {}
    }
    var startVar = json['start'];
    Duration? start;
    if (startVar != null) {
      try {
        start = Duration(seconds: startVar);
      } catch (_) {}
    }
    var endVar = json['end'];
    Duration? end;
    if (endVar != null) {
      try {
        end = Duration(seconds: endVar);
      } catch (_) {}
    }

    return ChapterModel(
      name: json['name'] ?? "",
      activated: activated == null ? false : bool.tryParse(activated) ?? false,
      playing: playing == null ? false : bool.tryParse(playing) ?? false,
      index: index == null
          ? -1
          : index.runtimeType == int
          ? index
          : int.parse(index.toString()),
      playUrl: json['playUrl'],
      extras: extras,
      httpHeaders: httpHeaders,
      start: start,
      end: end,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "activated": activated,
      "playing": playing,
      "index": index,
      "playUrl": playUrl,
      "extras": extras,
      "httpHeaders": httpHeaders,
      "start": start?.inSeconds,
      "end": end?.inSeconds,
    };
  }
}
