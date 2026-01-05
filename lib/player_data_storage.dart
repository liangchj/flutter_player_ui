
import 'model/storage/play_history_model.dart';

abstract class PlayerDataStorage {
  Future<void> save(String key, dynamic value);
  Future<dynamic> get(String key);
  Future<void> delete(String key);


  // 播放历史
  Future<void> savePlayHistory(String videoId, PlayHistoryModel historyModel);
  Future<PlayHistoryModel> getPlayHistory(String videoId);
  Future<void> deletePlayHistory(String videoId);


  Future<void> saveSetting(String key, dynamic value);
  Future<dynamic> getSetting(String key);
  Future<void> deleteSetting(String key);
}