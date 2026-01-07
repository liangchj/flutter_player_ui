import 'model/storage/play_history_model.dart';

abstract class PlayerDataStorage {
  // 设置
  Future<bool> saveSetting<T>(
    String key,
    T value, {
    bool nullRemove = true,
    String Function(T)? toJson,
    String Function(List<T>)? listToJson,
  });
  Future getSetting<T>(String key);
  Future<void> deleteSetting(String key);

  // 播放历史
  Future<bool> savePlayHistory(String key, PlayHistoryModel historyModel);
  Future<PlayHistoryModel?> getPlayHistory(String key);
  Future<void> deletePlayHistory(String key);
}
