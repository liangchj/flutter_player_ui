
import 'package:flutter_player_ui/flutter_player_ui.dart';

class FileSourceModel {
  final FileSourceEnums sourceType;
  final String path;

  FileSourceModel({required this.sourceType, required this.path});

  factory FileSourceModel.fromJson(Map<dynamic, dynamic> json) {
    return FileSourceModel(
      sourceType: FileSourceEnums.values.firstWhere(
        (element) => element.toString() == json['sourceType'],
      ),
      path: json['path'],
    );
  }
  Map<String, dynamic> toJson() {
    return {'sourceType': sourceType.toString(), 'path': path};
  }
}
