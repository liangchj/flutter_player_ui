
import 'chapter_model.dart';

class ChapterGroupModel {
  final String id;
  final String name;
  final List<ChapterModel> chapterList;

  ChapterGroupModel({
    required this.id,
    required this.name,
    required this.chapterList,
  });
}