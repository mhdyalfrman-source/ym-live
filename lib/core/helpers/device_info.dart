import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/platform/platform.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:tom_chat/models/device_module.dart';

Future<DeviceInfoModule> getDeviceInfo() async {
  final deviceInfo = DeviceInfoModule();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String? deviceUUID; //await PlatformDeviceId.getDeviceId;

  try {
    if (GetPlatform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;

      deviceUUID = [
        info.brand,
        info.device,
        info.model,
        info.product,
        info.hardware,
        info.manufacturer,
        info.fingerprint,
      ].join('|');
    } else if (GetPlatform.isIOS) {
      IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;

      deviceInfo.buildID = iosInfo.identifierForVendor;
      deviceInfo.brand = iosInfo.utsname.machine;
      deviceInfo.deviceName = iosInfo.name;
      deviceInfo.model = iosInfo.model;
      deviceInfo.serialNumber = iosInfo.systemName;
      deviceInfo.systemVersion = iosInfo.systemVersion;
      deviceInfo.productId = iosInfo.utsname.machine;
      deviceInfo.userName = iosInfo.utsname.nodename;
      deviceInfo.platform = "ios";

      deviceUUID = iosInfo.identifierForVendor;
    } else if (GetPlatform.isWindows) {
      WindowsDeviceInfo windoInfo = await DeviceInfoPlugin().windowsInfo;

      deviceInfo.buildID = windoInfo.deviceId;
      deviceInfo.brand = "windows";
      deviceInfo.platform = "windows";
      deviceInfo.deviceName = windoInfo.computerName;
      deviceInfo.model = windoInfo.productName;
      deviceInfo.systemVersion = windoInfo.majorVersion.toString();
      deviceInfo.productId = windoInfo.productId;
      deviceInfo.userName = windoInfo.userName;
    }
  } on PlatformException {
    return deviceInfo;
  }

  deviceInfo.deviceUUID = deviceUUID;
  deviceInfo.packageVersion = packageInfo.version;
  deviceInfo.buildNumber = packageInfo.buildNumber;
  return deviceInfo;
}

/// Check if running on iOS Simulator
/// FURenderKit and some frameworks don't support simulator
Future<bool> isIOSSimulator() async {
  if (!GetPlatform.isIOS) return false;
  try {
    final iosInfo = await DeviceInfoPlugin().iosInfo;
    // Simulator devices have "Simulator" in the model name
    return iosInfo.model.toLowerCase().contains('simulator') ||
        iosInfo.name.toLowerCase().contains('simulator');
  } catch (e) {
    return false;
  }
}
