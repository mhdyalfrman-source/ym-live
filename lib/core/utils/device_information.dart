import 'package:device_info_plus/device_info_plus.dart';

class DeviceInformationHelper {
  static getAndroidVersion() async {
    try {
      AndroidDeviceInfo deviceInfo = await DeviceInfoPlugin().androidInfo;
      return deviceInfo.version.sdkInt;
    } catch (exception) {
      return "";
    }
  }
}
