class ResourceStateModel {
  final int apiIndex; // 当前播放的API源索引
  final int apiGroupIndex; // 当前播放的API资源组索引
  final int chapterGroupIndex; // 当前播放的章节组索引
  final int chapterIndex;

  const ResourceStateModel({
    required this.apiIndex,
    required this.apiGroupIndex,
    required this.chapterGroupIndex,
    required this.chapterIndex,
  }); // 当前播放的章节索引

  // 复制方法（修改部分字段时生成新对象）
  ResourceStateModel copyWith({
    int? apiIndex,
    int? apiGroupIndex,
    int? chapterGroupIndex,
    int? chapterIndex,
  }) {
    return ResourceStateModel(
      apiIndex: apiIndex ?? this.apiIndex,
      apiGroupIndex: apiGroupIndex ?? this.apiGroupIndex,
      chapterGroupIndex: chapterGroupIndex ?? this.chapterGroupIndex,
      chapterIndex: chapterIndex ?? this.chapterIndex,
    );
  }

  // 重写equals和hashCode（确保对象变化可被GetX感知）
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResourceStateModel &&
          runtimeType == other.runtimeType &&
          apiIndex == other.apiIndex &&
          apiGroupIndex == other.apiGroupIndex &&
          chapterGroupIndex == other.chapterGroupIndex &&
          chapterIndex == other.chapterIndex;

  @override
  int get hashCode =>
      apiIndex.hashCode ^
      apiGroupIndex.hashCode ^
      chapterGroupIndex.hashCode ^
      chapterIndex.hashCode;
}
