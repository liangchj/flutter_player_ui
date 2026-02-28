import 'package:signals/signals.dart';

import '../constant/style_constant.dart';
import '../model/file_source_model.dart';
import '../model/resource/api_model.dart';
import '../model/resource/chapter_group_model.dart';
import '../model/resource/chapter_model.dart';
import '../model/resource/resource_model.dart';
import '../model/resource/resource_state_model.dart';
import '../model/resource/source_group_model.dart';
import 'base_state.dart';

class ResourceState extends BaseState {
  ResourceState() {
    _init();
  }

  // 章节排序
  final Signal<bool> chapterAsc = signal(true);

  final Signal<bool> chapterListLoaded = signal(false);

  ResourceStateModel prevResourceState = ResourceStateModel(
    apiIndex: -1,
    apiGroupIndex: -1,
    chapterGroupIndex: -1,
    chapterIndex: -1,
  );

  // 激活状态（当前展示的索引，用于UI高亮）
  final Signal<int> apiActivatedIndex = signal(-1);
  final Signal<int> apiGroupActivatedIndex = signal(-1);
  final Signal<int> chapterGroupActivatedIndex = signal(-1);
  final Signal<int> chapterActivatedIndex = signal(-1);

  // 播放状态（复合对象，决定当前播放的内容）
  final Signal<ResourceStateModel> resourcePlayingState = signal(
    ResourceStateModel(
      apiIndex: -1,
      apiGroupIndex: -1,
      chapterGroupIndex: -1,
      chapterIndex: -1,
    ),
  );

  // 多级缓存：记录每个上级分组对应的下级激活索引
  // 1. api索引 → 该api下最后激活的apiGroup索引
  final Map<int, int> _apiToApiGroupCache = {};

  // 2. "api索引+apiGroup索引" → 该组合下最后激活的chapterGroup索引
  final Map<String, int> _apiGroupToChapterGroupCache = {};

  // 3. "api索引+apiGroup索引+chapterGroup索引" → 该组合下最后激活的chapter索引
  final Map<String, int> _chapterGroupToChapterCache = {};

  List<EffectCleanup> _effectCleanupList = [];

  bool isAppendResourceAndUpdateLoadingState = false;

  // 弹幕文件路径
  // final Signal<String> danmakuFilePath = signal("");
  final Signal<FileSourceModel?> danmakuSource = signal(null);

  void _init() {
    _effectCleanupList.addAll([
      // 监听资源和章节列表变化
      effect(() {
        // 追踪 resourceModel 和 chapterList 的变化
        final resource = resourceModel.value;
        final chapters = chapterList.value;
        if (resource == null && chapters == null) {
          return;
        }

        ResourceStateModel firstState = ResourceStateModel(
          apiIndex: -1,
          apiGroupIndex: -1,
          chapterGroupIndex: -1,
          chapterIndex: -1,
        );
        ResourceStateModel activeState = ResourceStateModel(
          apiIndex: -1,
          apiGroupIndex: -1,
          chapterGroupIndex: -1,
          chapterIndex: -1,
        );
        if (resource != null &&
            resource.apiList != null &&
            resource.apiList!.isNotEmpty) {
          var apiList = resource.apiList;
          if (apiList == null || apiList.isEmpty) {
            return;
          }

          for (int apiIndex = 0; apiIndex < apiList.length; apiIndex++) {
            var item = apiList[apiIndex];
            var sourceGroupList = item.sourceGroupList;
            if (sourceGroupList.isEmpty) {
              continue;
            }

            if (firstState.apiIndex < 0) {
              firstState = firstState.copyWith(
                apiIndex: apiIndex,
                apiGroupIndex: -1,
                chapterGroupIndex: -1,
                chapterIndex: -1,
              );
            }

            for (
              int apiGroupIndex = 0;
              apiGroupIndex < sourceGroupList.length;
              apiGroupIndex++
            ) {
              var sourceGroup = sourceGroupList[apiGroupIndex];
              if (sourceGroup.chapterList.isEmpty) {
                continue;
              }
              if (firstState.apiGroupIndex < 0) {
                firstState = firstState.copyWith(
                  apiIndex: apiIndex,
                  apiGroupIndex: apiGroupIndex,
                  chapterGroupIndex: -1,
                  chapterIndex: -1,
                );
              }
              for (
                int chapterIndex = 0;
                chapterIndex < sourceGroup.chapterList.length;
                chapterIndex++
              ) {
                if (firstState.chapterIndex < 0) {
                  firstState = firstState.copyWith(
                    apiIndex: apiIndex,
                    apiGroupIndex: apiGroupIndex,
                    chapterGroupIndex: 0,
                    chapterIndex: chapterIndex,
                  );
                }
                if (sourceGroup.chapterList[chapterIndex].activated) {
                  // 激活的章节
                  activeState = activeState.copyWith(
                    apiIndex: apiIndex,
                    apiGroupIndex: apiGroupIndex,
                    chapterGroupIndex: chapterGroupIndex(
                      chapterIndex,
                      sourceGroup.chapterList,
                    ),
                    chapterIndex: chapterIndex,
                  );
                  break;
                }
              }
              if (activeState.chapterIndex >= 0) {
                break;
              }
            }
            if (activeState.chapterIndex >= 0) {
              break;
            }
          }
        } else {
          int index = -1;
          if (chapters != null) {
            for (int i = 0; i < chapters.length; i++) {
              var item = chapters[i];
              if (item.activated) {
                index = i;
                break;
              }
            }
          }
          activeState = activeState.copyWith(
            apiIndex: -1,
            apiGroupIndex: -1,
            chapterGroupIndex: -1,
            chapterIndex: index,
          );
        }
        // 没有激活的章节就默认第一个
        if (activeState.chapterIndex < 0) {
          activeState = firstState;
        }
        if (isAppendResourceAndUpdateLoadingState) {
          prevResourceState = activeState.copyWith();
          isAppendResourceAndUpdateLoadingState = false;
        }
        untracked(() {
          apiActivatedIndex.value = activeState.apiIndex;
          apiGroupActivatedIndex.value = activeState.apiGroupIndex;
          chapterGroupActivatedIndex.value = activeState.chapterGroupIndex;
          chapterActivatedIndex.value = activeState.chapterIndex;
        });
      }),
      // 监听api激活情况
      effect(() {
        final index = apiActivatedIndex.value;
        untracked(() {
          int apiGroupCacheActivatedIndex = index >= 0
              ? _apiToApiGroupCache[index] ?? -1
              : -1;
          if (chapterGroupActivatedIndex.value >= 0 && index >= 0) {
            _apiToApiGroupCache[index] = apiGroupActivatedIndex.value;
          }
          apiGroupActivatedIndex.value = apiGroupCacheActivatedIndex;
        });
      }),
      // 监听api下的资源组激活情况
      effect(() {
        final index = apiGroupActivatedIndex.value;
        untracked(() {
          int chapterGroupCacheActivatedIndex = index >= 0
              ? _apiGroupToChapterGroupCache["${apiActivatedIndex.value}-$index"] ??
                    -1
              : -1;
          if (chapterGroupActivatedIndex.value >= 0 && index >= 0) {
            _apiGroupToChapterGroupCache["${apiActivatedIndex.value}-$index"] =
                chapterGroupActivatedIndex.value;
          }

          chapterGroupActivatedIndex.value = chapterGroupCacheActivatedIndex;
        });
      }),
      // 监听api下的资源组下的章节组激活情况
      effect(() {
        final index = chapterGroupActivatedIndex.value;
        untracked(() {
          int chapterCacheActivatedIndex = index >= 0
              ? _chapterGroupToChapterCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}-$index"] ??
                    -1
              : -1;
          if (chapterActivatedIndex.value >= 0 && index >= 0) {
            _chapterGroupToChapterCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}-$index"] =
                chapterCacheActivatedIndex;
          }
          chapterActivatedIndex.value = chapterCacheActivatedIndex;
        });
      }),
      // 监听具体章节激活情况
      effect(() {
        final index = chapterActivatedIndex.value;
        if (index >= 0) {
          untracked(() {
            // 更新选中的章节组
            // 获取当前章节下标所属章节组
            int chapterGroupIndex = (index / StyleConstant.chapterGroupCount).floor();
            chapterGroupActivatedIndex.value = chapterGroupIndex;

            // 激活的章节触发其他具体内容
            onChapterTapped();
          });
        }
      }),
    ]);
  }

  @override
  void dispose() {
    for (var e in _effectCleanupList) {
      e.call();
    }
    apiActivatedIndex.dispose();
    apiGroupActivatedIndex.dispose();
    chapterGroupActivatedIndex.dispose();
    chapterActivatedIndex.dispose();
    resourcePlayingState.dispose();
    resourceModel.dispose();
    chapterList.dispose();
    danmakuSource.dispose();
    disposed = true;
  }

  // 点击章节时：将激活状态同步到播放状态
  void onChapterTapped() {
    untracked(() {
      resourcePlayingState.value = ResourceStateModel(
        apiIndex: apiActivatedIndex.value,
        apiGroupIndex: apiGroupActivatedIndex.value,
        chapterGroupIndex: chapterGroupActivatedIndex.value,
        chapterIndex: chapterActivatedIndex.value,
      );
      _apiToApiGroupCache.clear();
      _apiToApiGroupCache[apiActivatedIndex.value] =
          apiGroupActivatedIndex.value;
      _apiGroupToChapterGroupCache.clear();
      _apiGroupToChapterGroupCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}"] =
          chapterGroupActivatedIndex.value;
      _chapterGroupToChapterCache.clear();
      _chapterGroupToChapterCache["${apiActivatedIndex.value}-${apiGroupActivatedIndex.value}-${chapterGroupActivatedIndex.value}"] =
          chapterActivatedIndex.value;
      // 改为播放器解析完成后再赋值
      // danmakuFilePath.value = playingChapter?.danmakuPath ?? "";
      danmakuSource.value = null;
    });
  }

  // 资源
  final Signal<ResourceModel?> resourceModel = signal(null);

  // 播放列表
  final Signal<List<ChapterModel>?> chapterList = signal(null);

  // 资源api列表
  List<ApiModel>? get apiList => resourceModel.value?.apiList;

  // 资源api数量
  int get apiCount => apiList?.length ?? 0;

  // 当前播放的api
  ApiModel? get playingApi {
    return apiCount <= 0 || resourcePlayingState.value.apiIndex < 0
        ? null
        : apiList![resourcePlayingState.value.apiIndex];
  }

  // 当前选中显示的 api
  ApiModel? get activatedApi {
    return apiCount <= 0 ||
            apiActivatedIndex.value < 0 ||
            apiList == null ||
            apiList!.length < apiActivatedIndex.value
        ? null
        : apiList![apiActivatedIndex.value];
  }

  // 资源组
  // 播放api下的资源组
  List<SourceGroupModel>? get playingApiSourceGroupList =>
      playingApi?.sourceGroupList;
  // 播放api下的资源组数量
  int get playingApiSourceGroupCount => playingApiSourceGroupList?.length ?? 0;
  // 选中api下的资源组
  List<SourceGroupModel>? get activatedApiSourceGroupList =>
      activatedApi?.sourceGroupList;
  // 激活api下的资源组数量
  int get activatedApiSourceGroupCount =>
      activatedApiSourceGroupList?.length ?? 0;
  // 当前播放的资源组
  SourceGroupModel? get playingSourceGroup {
    return playingApiSourceGroupCount <= 0 ||
            resourcePlayingState.value.apiGroupIndex < 0
        ? null
        : playingApiSourceGroupList![resourcePlayingState.value.apiGroupIndex];
  }

  // 当前选中显示的资源组
  SourceGroupModel? get activatedSourceGroup {
    return activatedApiSourceGroupCount <= 0 || apiGroupActivatedIndex.value < 0
        ? null
        : activatedApiSourceGroupList![apiGroupActivatedIndex.value];
  }

  bool get haveApiAndSource => apiCount > 0 || activatedApiSourceGroupCount > 0;

  // 章节
  // 章节列表
  // 播放api和资源组下的章节列表
  List<ChapterModel> get playingChapterList =>
      (haveApiAndSource
          ? playingSourceGroup?.chapterList
          : chapterList.value) ??
      [];

  // 播放api和资源组下的章节数量
  int get playingChapterCount => playingChapterList.length;
  // 选中api和资源组下的章节列表
  List<ChapterModel> get activatedChapterList =>
      (haveApiAndSource
          ? activatedSourceGroup?.chapterList
          : chapterList.value) ??
      [];

  // 激活api和资源组下的章节数量
  int get activatedChapterCount => activatedChapterList.length;

  List<ChapterGroupModel> chapterGroupList(List<ChapterModel> chapters) {
    List<ChapterGroupModel> list = [];
    int groupCount = (chapters.length / StyleConstant.chapterGroupCount).ceil();
    for (int i = 0; i < groupCount; i++) {
      int start = i * StyleConstant.chapterGroupCount + 1;
      int end = start + StyleConstant.chapterGroupCount - 1;
      if (end > chapters.length) {
        end = chapters.length;
      }
      String name = "${start.toString()}至${end.toString()}";
      list.add(
        ChapterGroupModel(
          id: i.toString(),
          name: name,
          chapterList: chapters.sublist(start - 1, end),
        ),
      );
    }
    return list;
  }

  // 根据章节下标和章节列表获取章节组下标
  int chapterGroupIndex(int chapterIndex, List<ChapterModel> chapterList) {
    // 验证输入参数
    if (chapterList.isEmpty ||
        chapterIndex < 0 ||
        chapterIndex >= chapterList.length) {
      return -1;
    }
    // 直接计算章节组索引
    return (chapterIndex / StyleConstant.chapterGroupCount).floor();
  }

  // 章节组
  // 播放api和资源组下的章节组
  List<ChapterGroupModel> get playingChapterGroupList {
    if (playingChapterCount <= 0) {
      return [];
    }
    List<ChapterModel> chapters = playingChapterList;
    return chapterGroupList(chapters);
  }

  // 播放api和资源组下的章节组数量
  int get playingChapterGroupCount => playingChapterGroupList.length;

  // 选中api和资源组下的章节组
  List<ChapterGroupModel> get activatedChapterGroupList {
    if (activatedChapterCount <= 0) {
      return [];
    }
    List<ChapterModel> chapters = activatedChapterList;
    return chapterGroupList(chapters);
  }

  // 激活api和资源组下的章节组数量
  int get activatedChapterGroupCount => activatedChapterGroupList.length;

  // 当前播放的章节组
  ChapterGroupModel? get playingChapterGroup {
    return playingChapterGroupList.isEmpty ||
            resourcePlayingState.value.chapterGroupIndex < 0
        ? null
        : playingChapterGroupList[resourcePlayingState.value.chapterGroupIndex];
  }

  // 当前选中显示的章节组
  ChapterGroupModel? get activatedChapterGroup {
    return activatedChapterGroupList.isEmpty ||
            chapterGroupActivatedIndex.value < 0
        ? null
        : activatedChapterGroupList[chapterGroupActivatedIndex.value];
  }

  List<ChapterModel> get chapterGroupChapterList {
    if (activatedChapterGroup == null) {
      if (activatedChapterGroupList.isNotEmpty &&
          chapterGroupActivatedIndex.value < 0 &&
          activatedChapterGroupCount > 0) {
        return activatedChapterGroupList[0].chapterList;
      }
      return [];
    }
    return activatedChapterGroup!.chapterList;
  }

  // 当前播放的章节
  ChapterModel? get playingChapter {
    return playingChapterCount <= 0 ||
            resourcePlayingState.value.chapterIndex < 0
        ? null
        : playingChapterList[resourcePlayingState.value.chapterIndex];
  }

  // 章节标题最大长度
  int get maxChapterTitleLen {
    int max = 0;
    for (var value in activatedChapterList) {
      var length = value.name.length;
      if (length > max) {
        max = length;
      }
    }
    return max;
  }

  String get playChapterTitle {
    String title = playingChapter?.name ?? "";
    if (resourceModel.value != null) {
      String name = resourceModel.value!.name;
      if (name.isEmpty) {
        name = resourceModel.value!.enName ?? "";
      }
      if (name.isNotEmpty) {
        title = "$name${title.isEmpty ? "" : " [$title]"}";
      }
    }
    return title;
  }

  // 当前激活的章节中对应激活的章节下标（本组下标，不是全章节下标）
  int get playingChapterGroupToChapterIndex {
    var chapterIndex = resourcePlayingState.value.chapterIndex;
    if (chapterIndex < 0) {
      return -1;
    }
    if (resourcePlayingState.value.chapterGroupIndex < 0) {
      return chapterIndex;
    }
    // 因为chapterGroupIndex从0开始，因此不需要先减1再计算
    return chapterIndex -
        (resourcePlayingState.value.chapterGroupIndex *
            StyleConstant.chapterGroupCount);
  }

  // 当前激活的章节中对应激活的章节下标（本组下标，不是全章节下标）
  int get activatedChapterGroupToChapterIndex {
    var chapterIndex = chapterActivatedIndex.value;
    if (chapterIndex < 0) {
      return -1;
    }
    if (resourcePlayingState.value.chapterGroupIndex < 0) {
      return chapterIndex;
    }
    // 因为chapterGroupIndex从0开始，因此不需要先减1再计算
    return chapterIndex -
        (resourcePlayingState.value.chapterGroupIndex *
            StyleConstant.chapterGroupCount);
  }

  bool get haveNext {
    List<ChapterModel> chapters = activatedChapterList;
    return resourcePlayingState.value.chapterIndex < chapters.length - 1;
  }

  void jumpToPlay() {
    apiActivatedIndex.value = resourcePlayingState.value.apiIndex;
    apiGroupActivatedIndex.value = resourcePlayingState.value.apiGroupIndex;
    chapterGroupActivatedIndex.value =
        resourcePlayingState.value.chapterGroupIndex;
  }

  void appendResourceAndUpdateLoadingState(
    bool loaded, {
    ResourceModel? resourceModel,
    List<ChapterModel>? chapterList,
  }) {
    isAppendResourceAndUpdateLoadingState = true;
    if (resourceModel != null) {
      this.resourceModel.value = resourceModel;
    }
    if (chapterList != null) {
      this.chapterList.value = chapterList;
    }
    chapterListLoaded.value = true;
  }
}
