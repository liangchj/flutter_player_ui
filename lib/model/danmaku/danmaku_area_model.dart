
class DanmakuAreaModel {
  final List<DanmakuAreaItemModel> danmakuAreaItemList;
  int _areaIndex = 0;
  int get areaIndex => _areaIndex;
  String name = "";

  DanmakuAreaModel({required this.danmakuAreaItemList, required int areaIndex}) {
    _areaIndex = areaIndex;
    name = danmakuAreaItemList.length > _areaIndex
        ? danmakuAreaItemList[_areaIndex].name
        : "";
  }

  DanmakuAreaModel copyWith({
    List<DanmakuAreaItemModel>? danmakuAreaItemList,
    int? areaIndex,
  }) {
    return DanmakuAreaModel(
      danmakuAreaItemList: danmakuAreaItemList ?? this.danmakuAreaItemList,
      areaIndex: areaIndex ?? _areaIndex,
    );
  }

  set areaIndex(int i) {
    _areaIndex = i;
    name = danmakuAreaItemList.length > _areaIndex
        ? danmakuAreaItemList[_areaIndex].name
        : "";
  }
}

// 弹幕显示区域
class DanmakuAreaItemModel {
  final double area;
  final String name;
  // 弹幕过多是否限制显示（自动过滤）
  bool filter;

  DanmakuAreaItemModel({required this.area, required this.name, this.filter = true});
}