import 'api_model.dart';

class ResourceModel {
  // 资源id
  final String id;
  // 名称
  final String name;
  final String? enName;
  String url;
  List<ApiModel>? apiList;

  ResourceModel({required this.id, required this.name, this.enName, required this.url, this.apiList});


  factory ResourceModel.fromJson(Map<dynamic, dynamic> json) {
    return ResourceModel(
      id: (json["id"] ?? "").toString(),
      name: (json["name"] ?? "").toString(),
      enName: (json["enName"] ?? "").toString(),
      url: (json["url"] ?? "").toString(),
    );
  }
}
