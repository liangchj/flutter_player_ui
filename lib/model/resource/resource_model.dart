import 'api_model.dart';

class ResourceModel {
  // 资源id
  final String id;
  // 名称
  final String name;
  final String? enName;
  final String url;
  List<ApiModel>? apiList;

  ResourceModel({required this.id, required this.name, this.enName, required this.url, this.apiList});
}
