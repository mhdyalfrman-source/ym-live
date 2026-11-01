import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Trans;
import 'package:google_sign_in/google_sign_in.dart';

import 'package:tom_chat/controllers/general_controller.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/helpers/device_info.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/rooms/controllers/room_seat_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/main.dart';
import 'package:tom_chat/models/device_module.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class EntryController extends GetxController {
  RxBool isGoogleLoading = false.obs;
  RxString gender = "".obs;
  int? birthDay;
  int? birthMonth;
  int? birthYear;
  RxString selectedCountry = "".obs;
  RxBool policyRead = false.obs;
  RxBool showPassword = false.obs;

  // SignUp
  Rx<UserModel> user = visitUser.obs;
  TextEditingController userName1Controller = TextEditingController();
  TextEditingController userId = TextEditingController();
  TextEditingController userPassword = TextEditingController();
  Rx<File> image = File("").obs;

  late GeneralController controller;
  @override
  void onInit() {
    super.onInit();
    controller = Get.put(GeneralController(), permanent: true);
  }

  Future<void> onSignInWithGoogle() async {
    if (!policyRead.value) {
      snakbarDialog(
        title: Get.context!.l10n.mustAcceptUsagePolicy,
        durationSecound: 3,
      );
      return;
    }
    try {
      final signIn = GoogleSignIn.instance;

      GoogleSignInAccount? account = await signIn.authenticate();

      if (account == null) {
        // _showErrorSnackBar('Cancelled', 'User cancelled sign-in');
        return;
      }

      final String? idToken = account.authentication.idToken;
      if (idToken == null) {
        snakbarDialog(
          durationSecound: 5,
          title:
              'No ID token from Google. Check SHA-1/SHA-256 & Web Client ID.',
        );
        return;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      if (userCredential.user == null) {
        snakbarDialog(
          durationSecound: 5,
          title: 'Unable to sign in with Google',
        );
        return;
      }

      DeviceInfoModule device = await getDeviceInfo();

      var res = await CallServerAPI.post("auth", {
        "googleid": account.id,
        "email": account.email,
        "name": account.displayName,
        "auth_token": userCredential.user?.uid,
        "authCode": account.authentication.idToken,
        "type": "register",
        "provider": "google",
        "dname": device.deviceName,
        "duname": device.userName,
        "brand": device.brand,
      });
      if (res.isNotEmpty && res["user"] != null) {
        StaticValue.userData = UserModel.fromMap(res["user"]);
        StaticValue.userData.userToken = res["token"];
        StaticValue.userData.appPrefix = res["appPrefix"];
        final storage = FlutterSecureStorage();
        await storage.write(key: "user", value: StaticValue.userData.toJson());
        getToken();
        await userFirstRoute(res);
      }
    } catch (e) {
      snakbarDialog(durationSecound: 5, title: Get.context!.l10n.loginFailed);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> onSignInWithId() async {
    if (!policyRead.value) {
      snakbarDialog(
        title: Get.context!.l10n.mustAcceptUsagePolicy,
        durationSecound: 3,
      );
      return;
    }
    try {
      var res = await CallServerAPI.post("auth/loginById", {
        "id": userId.text,
        "password": userPassword.text,
      }, withSnakbar: true);
      if (res.isNotEmpty && res["user"] != null) {
        StaticValue.userData = UserModel.fromMap(res["user"]);
        StaticValue.userData.userToken = res["token"];
        StaticValue.userData.appPrefix = res["appPrefix"];
        final storage = FlutterSecureStorage();
        await storage.write(key: "user", value: StaticValue.userData.toJson());
        getToken();
        await userFirstRoute(res);
      }
    } catch (e) {
      snakbarDialog(durationSecound: 5, title: Get.context!.l10n.loginFailed);
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> onCompleteAccount() async {
    // if (image.value.path.isEmpty) {
    //   snakbarDialog(title: Get.context!.l10n.plsChooseImage, durationSecound: 5);
    //   return;
    // }

    if (userName1Controller.text.trim().isEmpty) {
      userName1Controller.text = "user_${StaticValue.userData.userId}";
    }

    if (birthDay == null || birthMonth == null || birthYear == null) {
      snakbarDialog(
        title: Get.context!.l10n.plsSelectBirthDate,
        durationSecound: 5,
      );
      return;
    }

    if (gender.value.isEmpty) {
      snakbarDialog(
        title: Get.context!.l10n.plsSelectGender,
        durationSecound: 5,
      );
      return;
    }

    if (selectedCountry.value.isEmpty) {
      snakbarDialog(
        title: Get.context!.l10n.plsSelectCountry,
        durationSecound: 5,
      );
      return;
    }

    final String birthday =
        '${birthDay.toString().padLeft(2, '0')}-'
        '${birthMonth.toString().padLeft(2, '0')}-'
        '$birthYear';

    isGoogleLoading.value = true;

    try {
      String imageUrl = StaticValue.userData.avatar?.network ?? "";
      if (image.value.path != "") {
        imageUrl = await uplaudImage(image.value, ImageUploadType.profile);
      }
      var res = await CallServerAPI.post(
        "auth/update",
        {
          "name": userName1Controller.text,
          "avatar": imageUrl,
          "type": gender.value == "male" ? 1 : 0,
          "country": selectedCountry.value,
          "comment": "",
          "birthday": birthday,
        },
        // fileFieldName: "avatar",file: image.value,
        messageTime: 120,
      );
      if (res.isNotEmpty) {
        StaticValue.userData.pos = UserPosition.user;
        getToken();
        await loginByToken();
      }
      isGoogleLoading.value = false;
    } catch (_) {
      isGoogleLoading.value = false;
    }
  }

  Future<void> getToken() async {
    // try{
    //   await FirebaseMessaging.instance.deleteToken();
    // }catch(_){}
    await FirebaseMessaging.instance.getToken().then((value) {
      CallServerAPI.post("auth/updateFcmToken", {"fcm_token": value});
    });
  }
}
