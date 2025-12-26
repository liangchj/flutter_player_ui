import 'source_group_model.dart';

class ApiModel {
  final ApiInfoModel? api;

  // 当前api下有哪些资源列表
  final List<SourceGroupModel> sourceGroupList;

  ApiModel({
    this.api,
    required this.sourceGroupList,
  });
}

class ApiInfoModel {
  final String url;
  final String name;
  final String enName;

  ApiInfoModel({required this.url, required this.name, required this.enName});
}
