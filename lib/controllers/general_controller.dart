import 'package:get/get.dart' hide Trans;
import 'package:unique_identifier/unique_identifier.dart';

typedef SocketCallback = void Function(dynamic data);

class GeneralController extends GetxService {
  String currentDialog = "";
}

getDeviceId() async {
  try {
    return await UniqueIdentifier.serial;
  } catch (e) {
    return "null";
  }
}
