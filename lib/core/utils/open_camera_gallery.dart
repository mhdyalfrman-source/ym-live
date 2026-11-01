import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tom_chat/core/utils/functions.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/l10n/l10n.dart';

Future<String> openCamera() async {
  try {
    if (Platform.isWindows) {
      XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
      return xFile!.path;
    }

    await requestCameraPermission();
    if (await checkCameraPermission()) {
      XFile? xFile = await ImagePicker().pickImage(source: ImageSource.camera);
      return xFile!.path;
    } else {
      snakbarDialog(
        title: Get.context!.l10n.youShouldGivePremissionToTheApp,
        durationSecound: 5,
      );
      return "";
    }
  } catch (e) {
    return "";
  }
}

Future<String> openGallery() async {
  try {
    XFile? xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return xFile!.path;
  } catch (e) {
    return "";
  }
}
