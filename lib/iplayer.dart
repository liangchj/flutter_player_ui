import 'flutter_player_ui.dart';

abstract class IPlayer {
  PlayerViewModel? playerViewModel;

  IPlayer({this.playerViewModel});
  // 播放器初始化
  Future<void> onInitPlayer();

  // 销毁播放器
  Future<void> onDisposePlayer();

  // 播放
  Future<void> play();
  // 暂停
  Future<void> pause();
  Future<void> stop();
  Future<void> dispose();

  // 进度跳转
  Future<void> seekTo(Duration position);
  // 设置播放速度
  Future<void> setPlaySpeed(double speed);

  bool get playing;
  bool get buffering;
  bool get finished;

  /// 更新状态信息
  void updateState();

  void changeVideoUrl({bool autoPlay = true});

  IPlayer copyWith({PlayerViewModel? playerViewModel});

  bool disposed = false;

  bool get playerViewModelDisposed => playerViewModel?.disposed ?? true;
  bool get playerStateDisposed => playerViewModel?.playerState.disposed ?? true;
  bool get resourceDisposed => playerViewModel?.resourceState.disposed ?? true;

  bool get uiViewModelDisposed => playerViewModel?.uiViewModel.disposed ?? true;
  bool get uiStateDisposed =>
      playerViewModel?.uiViewModel.uiState.disposed ?? true;
}
