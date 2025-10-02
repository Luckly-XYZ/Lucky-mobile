import 'package:audioplayers/audioplayers.dart';

/// 音频播放器工具类
class AudioPlayerUtil {
  // 单例模式：私有构造函数
  AudioPlayerUtil._internal();

  // 单例实例
  static final AudioPlayerUtil _instance = AudioPlayerUtil._internal();

  // 工厂构造函数，返回单例实例
  factory AudioPlayerUtil() => _instance;

  // audioplayers插件的AudioPlayer实例
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 上次播放时间，用于限制播放频率
  DateTime? _lastPlayTime;

  // 是否正在循环播放
  bool _isLooping = false;

  /// 设置音频上下文，控制音量类型
  /// [useMediaVolume] 为true时使用媒体音量，为false时使用系统音量
  Future<void> setAudioContext({required bool useMediaVolume}) async {
    if (useMediaVolume) {
      // 使用媒体音量
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            //options: AVAudioSessionOptions.mixWithOthers,
          ),
        ),
      );
    } else {
      // 使用系统音量
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.notification,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.ambient,
            //options: AVAudioSessionOptions.mixWithOthers,
          ),
        ),
      );
    }
  }

  /// 播放本地资源音频
  /// [assetPath] 本地音频文件的路径
  /// [useMediaVolume] 是否使用媒体音量
  Future<void> play(String assetPath, {bool useMediaVolume = true}) async {
    // 设置音频上下文
    await setAudioContext(useMediaVolume: useMediaVolume);

    // 获取当前时间
    final now = DateTime.now();

    // 如果上次播放时间存在且距离现在不足1秒，则不播放
    if (_lastPlayTime != null &&
        now.difference(_lastPlayTime!).inMilliseconds < 1000) {
      print('播放频率过高，已跳过此次播放');
      return;
    }

    // 更新上次播放时间
    _lastPlayTime = now;

    try {
      // 播放音频
      await _audioPlayer.play(AssetSource(assetPath));
      print('音频播放成功：$assetPath');
    } catch (e) {
      print('音频播放失败：$e');
    }
  }

  /// 开始循环播放本地资源音频
  /// [assetPath] 本地音频文件的路径
  /// [duration] 循环播放的时长，单位为毫秒；如果为null，则无限循环，直到调用stopLoop
  /// [useMediaVolume] 是否使用媒体音量
  Future<void> playLoop(String assetPath,
      {int? duration, bool useMediaVolume = true}) async {
    if (_isLooping) {
      print('音频已在循环播放中');
      return;
    }

    // 设置音频上下文
    await setAudioContext(useMediaVolume: useMediaVolume);

    try {
      // 设置为循环播放
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      // 播放音频
      await _audioPlayer.play(AssetSource(assetPath));
      _isLooping = true;
      print('开始循环播放音频：$assetPath');

      // 如果指定了循环时长，则在指定时间后停止播放
      if (duration != null) {
        Future.delayed(Duration(milliseconds: duration), () {
          stopLoop();
        });
      }
    } catch (e) {
      print('循环播放音频失败：$e');
    }
  }

  /// 停止循环播放
  Future<void> stopLoop() async {
    if (_isLooping) {
      await _audioPlayer.stop();
      _isLooping = false;
      print('已停止循环播放');
    } else {
      print('当前没有音频在循环播放');
    }
  }
}
