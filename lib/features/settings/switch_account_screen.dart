import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/helpers/secure_storage.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/utils/wait_message.dart';
import 'package:tom_chat/core/widgets/profile_avatar.dart';
import 'package:tom_chat/features/entry/entry_screen.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/main.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';

class SwitchAccountScreen extends StatefulWidget {
  const SwitchAccountScreen({super.key});

  @override
  State<SwitchAccountScreen> createState() => _SwitchAccountScreenState();
}

class _SwitchAccountScreenState extends State<SwitchAccountScreen> {
  List<StoredUser> accounts = [];
  late HomeController controller;

  @override
  void initState() {
    super.initState();
    getAccounts();
    controller = Get.find();
  }

  getAccounts() {
    SecureUsersStore().getAllUsers().then((v) {
      accounts.assignAll(v);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTxt = context.l10n;

    return PageTemplete(
      title: context.l10n.switch_account,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // First account (null)
                ...accounts.map((a) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: buildAccountOption(
                      context,
                      trailing: a.isSelected
                          ? const Icon(
                              Icons.check,
                              color: AppColors.primaryDark,
                            )
                          : const SizedBox(),
                      avatar: ProfileAvatar(
                        radius: 26.r,
                        user: UserModel(
                          userId: 0,
                          name: "",
                          avatar: ImageModel(network: a.profilePic),
                        ),
                      ),
                      title: a.name!,
                      subtitle: a.id,
                      onLongPress: () {
                        if (a.isSelected) return;
                        opendDialogWithName(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              insetPadding: EdgeInsets.symmetric(
                                horizontal: Get.width / 4,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    onTap: () async {
                                      Get.back();
                                      SecureUsersStore secureUsersStore =
                                          SecureUsersStore();
                                      await secureUsersStore.deleteUserById(
                                        a.id,
                                      );
                                      await getAccounts();
                                    },
                                    title: Text(
                                      context.l10n.delete,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .copyWith(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          name: "MESSAGE",
                        );
                      },
                      onTap: () async {
                        if (a.isSelected) return;
                        waitMessage();
                        GetStorage().remove("cache_reels");
                        try {
                          await FirebaseMessaging.instance.deleteToken();
                          // await FcmTopicManager.unsubscribeFromAll();
                        } catch (_) {}
                        try {
                          SocketManager.instance.disconnect();
                          StaticValue.userData.userToken = a.token;
                          StaticValue.userData.deviceId = a.deviceID;
                          StaticValue.userData.userId = MyMath.toInt(a.id);
                          controller.resetAll();
                        } catch (_) {}
                        var res = await CallServerAPI.post(
                          "auth/tokenLogin",
                          {},
                          withMessage: false,
                        );
                        if (res.isNotEmpty && res["user"] != null) {
                          await Get.deleteAll();
                          StaticValue.userData = UserModel.fromMap(res["user"])
                              .copyWith(
                                userToken: StaticValue.userData.userToken,
                                appPrefix: StaticValue.userData.appPrefix,
                              );
                          await userFirstRoute(res);
                          return;
                        } else {
                          Get.back(closeOverlays: true);
                        }
                      },
                    ),
                  );
                }),
                SizedBox(height: 10.h),

                if (accounts.length < 3)
                  buildAccountOption(
                    context,
                    trailing: const SizedBox(),
                    avatar: Container(
                      width: 50.r,
                      height: 50.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: colors[1]),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 20.r),
                    ),
                    title: appTxt.add_account,
                    subtitle: '',
                    onLongPress: () {},
                    onTap: () async {
                      try {
                        SocketManager.instance.disconnect();
                        waitMessage();
                        GetStorage().remove("cache_reels");
                        try {
                          await FirebaseMessaging.instance.deleteToken();
                          // await FcmTopicManager.unsubscribeFromAll();
                        } catch (_) {}
                        final signIn = GoogleSignIn.instance;
                        await signIn.signOut();
                        controller.resetAll();
                        await Get.deleteAll();
                        Get.offAll(() => EntryScreen());
                      } catch (_) {
                        Get.back();
                      }
                    },
                  ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAccountOption(
    BuildContext context, {
    required Widget avatar,
    required Widget trailing,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          avatar,
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
