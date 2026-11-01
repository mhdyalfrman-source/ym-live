import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Trans;
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/utils/wait_message.dart';
import 'package:tom_chat/statics_values.dart';

class SettingController extends GetxController {
  RxBool showResendButton = false.obs;
  RxInt remineTime = 0.obs;
  Timer? timer;

  // password
  RxBool showPassword = false.obs;
  RxBool showPassword1 = false.obs;
  RxBool showPassword2 = false.obs;
  TextEditingController oldPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  RxString newPasswordText = "".obs;
  RxString confirmPasswordText = "".obs;
  GlobalKey<FormState> formKey = GlobalKey();
  GlobalKey<FormState> passwordFormKey = GlobalKey();

  // settings
  RxBool themeMode = false.obs;

  // Rx<CompanyModel> company = CompanyModel.initialize(companyId: 0).obs;
  // TextEditingController userName1Controller = TextEditingController(text: StaticValue.userData.userName1);
  // TextEditingController userName2Controller = TextEditingController(text: StaticValue.userData.userName2);
  // TextEditingController userName3Controller = TextEditingController(text: StaticValue.userData.userName3);
  // TextEditingController userName4Controller = TextEditingController(text: StaticValue.userData.userName4);
  Rx<File> image = File("").obs;

  RxBool contactDataCame = false.obs;

  TextEditingController helpTitle = TextEditingController();
  TextEditingController helpDetails = TextEditingController();

  RxList<RxInt> userPerferences = <RxInt>[].obs;

  bool forAdmin;
  SettingController({required this.forAdmin});

  @override
  void onInit() {
    super.onInit();
    refershPersonalData();
  }

  refershPersonalData() {
    // user.value = UserModel().copyWith(user: StaticValue.userData);
    // userName1Controller.text =  StaticValue.userData.userName1??"";
    // userName2Controller.text =  StaticValue.userData.userName2??"";
    // userName3Controller.text =  StaticValue.userData.userName3??"";
    // userName4Controller.text =  StaticValue.userData.userName4??"";
    //  image.value = File("");
  }

  changeData() async {
    try {
      if (formKey.currentState!.validate()) {
        waitMessage();

        Get.back();
        if (!forAdmin) Get.back();
        done();
      }
    } catch (e) {}
  }

  changeImage() async {
    // if(image.value.path != ""){
    //   waitMessage();
    //   String userImagePath = await postRequestWithFile("user_photos", generatCodeForImage(""), image.value,user.value.userImagePath);

    //   StaticValue.userData.userImagePath = userImagePath;
    //   user.update((val){
    //     val!.userImagePath = userImagePath;
    //   });
    //   await saveData();
    //   Get.back();
    //   done();
    // }
  }
}

saveData() async {
  final storage = FlutterSecureStorage();
  String? user = await storage.read(key: "user");
  if (user != null) {
    await storage.write(
      key: "user",
      value: json.encode(StaticValue.userData.toMap()),
    );
  }
}
