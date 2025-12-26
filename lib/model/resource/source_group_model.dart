import 'chapter_model.dart';

/// 资源组
class SourceGroupModel {
  final String? name;
  final String? enName;
  final List<ChapterModel> chapterList;

  SourceGroupModel({this.name, this.enName, required this.chapterList});
}
