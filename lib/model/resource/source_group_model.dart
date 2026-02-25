import 'dart:convert';

import 'chapter_model.dart';

List<SourceGroupModel> sourceGroupModelListFromJsonStr(String str) =>
    List<SourceGroupModel>.from(
      json.decode(str).map((x) => SourceGroupModel.fromJson(x)),
    );
List<SourceGroupModel> sourceGroupModelListFromJson(
  List<Map<String, dynamic>> data,
) => List<SourceGroupModel>.from(data.map((x) => SourceGroupModel.fromJson(x)));

List<SourceGroupModel> sourceGroupModelListFromDynamic(dynamic data) {
  if (data is List<SourceGroupModel>) {
    return data;
  } else if (data is List<dynamic>) {
    return List<SourceGroupModel>.from(
      data.map((x) => SourceGroupModel.fromJson(Map.from(x))),
    );
  } else if (data is List<Map<String, dynamic>>) {
    return sourceGroupModelListFromJson(data);
  } else {
    return sourceGroupModelListFromJsonStr(data.toString());
  }
}

String sourceGroupModelListToJson(List<SourceGroupModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

/// 资源组
class SourceGroupModel {
  final String? name;
  final String? enName;
  final List<ChapterModel> chapterList;

  SourceGroupModel({this.name, this.enName, required this.chapterList});

  factory SourceGroupModel.fromJson(Map<dynamic, dynamic> json) {
    List<ChapterModel> chapterList = [];
    var chapterListVar = json['chapterList'];
    if (chapterListVar != null) {
      try {
        chapterList = chapterModelListFromDynamic(chapterListVar);
        // List<Map<String, dynamic>> chapters = List.from(chapterListVar);
        // chapterList = chapters.map((e) => ChapterModel.fromJson(e)).toList();
      } catch (e) {
        throw Exception("结果转换成json报错：\n${e.toString()}");
      }
    }
    return SourceGroupModel(
      name: json["name"],
      enName: json["enName"] ?? json["name"],
      chapterList: chapterList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "enName": enName,
      "chapterList": chapterList.map((e) => e.toJson()).toList(),
    };
  }
}
