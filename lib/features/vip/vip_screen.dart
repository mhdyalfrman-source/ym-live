import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/vip/components/confirm_order.dart';
import 'package:tom_chat/features/vip/components/send_dialog.dart';
import 'package:tom_chat/features/vip/controllers/vip_controller.dart';
import 'package:tom_chat/features/vip/models/vip_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  PageController pageController = PageController();
  late VipController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VipController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.vipList.isEmpty) {
        controller.fetchAllVip();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      withSafeArea: false,
      title: "",
      child: Obx(() {
        if (controller.currentIndex.value == -1) return SizedBox();
        VipModel vip = controller.vipList[controller.currentIndex.value];
        return Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.vipList.length,
                onPageChanged: (index) {
                  controller.currentIndex.value = index;
                },
                itemBuilder: (context, index) {
                  VipModel vip = controller.vipList[index];
                  return Stack(
                    children: [
                      SizedBox(
                        height: Get.height / 2.5,
                        width: Get.width,
                        child: AppImage(
                          progressIndicatorBuilder: (_, __, ___) {
                            return SizedBox();
                          },
                          image: ImageModel(network: vip.bg),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            whiteAppBar(
                              context: context,
                              title: context.l10n.vip,
                              actions: [
                                if ((vip.expireAt ?? 0) > 0)
                                  TextButton(
                                    onPressed: () async {
                                      controller.activeItem(
                                        vip,
                                        (vip.active ?? 0) == 0 ? 1 : 0,
                                      );
                                    },
                                    child: Text(
                                      (vip.active ?? 0) == 0
                                          ? context.l10n.active
                                          : context.l10n.unactive,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                              ],
                            ),

                            SizedBox(
                              height: Get.height / 4.5,
                              child: AppImage(
                                image: ImageModel(network: vip.icon),
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(height: 10),

                            /// رقم VIP و السعر
                            // Text(
                            //   "VIP ${vip.num}",
                            //   style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            //         color: Colors.black,
                            //         fontWeight: FontWeight.bold,
                            //         fontSize: 24.sp,
                            //       ),
                            // ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      Positioned(
                        top: Get.height / 2.5,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: double.infinity,
                          color: vip.color,
                        ),
                      ),
                      Positioned.fill(
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(vip.profileFrame),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                margin: EdgeInsets.only(top: Get.height / 5),
                                padding: EdgeInsets.only(
                                  top: Get.height / 4,
                                  left: 20.r,
                                  right: 20.r,
                                ),
                                child: GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        mainAxisExtent: 110.h,
                                      ),
                                  padding: EdgeInsets.only(top: 10),
                                  physics: BouncingScrollPhysics(),
                                  itemCount: vip.privileges.length,
                                  itemBuilder: (context, index) {
                                    final p = vip.privileges[index];

                                    return Column(
                                      children: [
                                        Container(
                                          height: 60.r,
                                          width: 60.r,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: 2,
                                            ),
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                p.icon,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Expanded(
                                          child: Text(
                                            p.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.labelLarge!,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "${vip.price}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .displaySmall!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Image.asset(
                                      "assets/images/coin.png",
                                      width: 20.r,
                                      height: 20.r,
                                    ),
                                  ],
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  "/ ${vip.days} ${context.l10n.day}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall!
                                      .copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 5.h),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            /// --- الأزرار الثابتة أسفل الشاشة ---
            CardWidget(
              colorIndex: 1,
              radius: 0,
              child: Container(
                padding: EdgeInsets.all(12),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      if ((vip.expireAt ?? 0) > 0) ...[
                        Text(
                          "${context.l10n.endAfter} ${Duration(seconds: vip.expireAt!).inDays} ${context.l10n.day}",
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        SizedBox(height: 5.h),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: GeneralButton3(
                              color: Colors.white,
                              onPressed: () {
                                showSendDialog(context, controller);
                              },
                              title: context.l10n.send,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: GeneralButton3(
                              onPressed: () {
                                showConfirmDialog(context, controller);
                              },
                              color: Colors.white,
                              title: context.l10n.purchase,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

AppBar whiteAppBar({
  required BuildContext context,
  required String title,
  Widget? child,
  Color? color,
  List<Widget>? actions,
}) {
  return AppBar(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ),
    forceMaterialTransparency: true,
    leading: IconButton(
      onPressed: Get.back,
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 20.r,
        color: color ?? Colors.white,
      ),
    ),
    actions: actions,
    flexibleSpace: child,
    title: Padding(
      padding: EdgeInsets.all(10).r,
      child: title != ""
          ? Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.displayLarge!.copyWith(fontWeight: FontWeight.bold),
            )
          : null,
    ),
    elevation: 0,
    centerTitle: true,
    automaticallyImplyLeading: false,
    backgroundColor: Colors.transparent,
  );
}
