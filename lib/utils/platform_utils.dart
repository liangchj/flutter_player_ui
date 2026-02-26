import 'package:flutter/foundation.dart';

class PlatformUtils {
  // 检测是否为移动端平台（包括鸿蒙）
  static bool get isMobile {
    // 标准移动平台
    final standardMobile = [
      TargetPlatform.iOS,
      TargetPlatform.android,
    ].contains(defaultTargetPlatform);

    // 鸿蒙平台检测
    final isHarmony = _isHarmonyOS();

    return standardMobile || isHarmony;
  }

  // 检测是否为鸿蒙系统
  static bool _isHarmonyOS() {
    try {
      // 方法1: 通过系统属性检测（需要鸿蒙SDK支持）
      // return foundation.defaultTargetPlatform == TargetPlatform.harmony;

      // 方法2: 通过设备信息检测
      // final deviceInfo = await DeviceInfoPlugin().deviceInfo;
      // if (deviceInfo is AndroidDeviceInfo) {
      //   return deviceInfo.brand.toLowerCase().contains('harmony');
      // }

      // 方法3: 通过环境变量或特定API检测
      // 这需要根据具体的鸿蒙Flutter SDK来实现

      return false; // 鸿蒙版本需要重写此方法
    } catch (e) {
      return false;
    }
  }

  // 获取平台名称（用于调试）
  static String get platformName {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'iOS';
    if (defaultTargetPlatform == TargetPlatform.android) return 'Android';
    if (_isHarmonyOS()) return 'HarmonyOS';
    return defaultTargetPlatform.toString();
  }
}
