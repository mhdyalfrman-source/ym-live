import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/badges/badge_details_screen.dart';
import 'package:tom_chat/features/badges/badge_wear_bottom_sheet.dart';
import 'package:tom_chat/features/badges/components/wear_items_grid_view.dart';
import 'package:tom_chat/features/badges/controllers/badge_controller.dart';
import 'package:tom_chat/features/badges/models/medal_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  int selectedTab = 0;
  late BadgeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(BadgeController(), permanent: true);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (controller.medals.isEmpty) {
        await controller.fetchAllMedals();
      }
      controller.selectedMedal.value = controller.myMedals.firstOrNull;
    });
  }

  final tabs = ["إنجاز", "نشاط", "غرفة", "خاص"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F0E0E),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF40241E), // dark top
              Color(0xFF2A1815), // middle
              Color(0xFF1F0E0E), // bottom
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: Get.height * 0.45,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/badge_preview.png",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Column(
                    children: [
                      SafeArea(
                        bottom: false,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: Get.back,
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Text(
                                  context.l10n.medalsList,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // 🧭 Tabs Row
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 30.w),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: List.generate(tabs.length, (i) {
                      //       final isSelected = i == selectedTab;
                      //       return GestureDetector(
                      //         onTap: () => setState(() => selectedTab = i),
                      //         child: Column(
                      //           children: [
                      //             Text(
                      //               tabs[i],
                      //               style: TextStyle(
                      //                 color: isSelected ? Colors.amberAccent : Colors.white,
                      //                 fontSize: 18.sp,
                      //                 fontWeight: FontWeight.w600,
                      //               ),
                      //             ),
                      //             if (isSelected)
                      //               Container(
                      //                 margin: EdgeInsets.only(top: 4.h),
                      //                 height: 3.h,
                      //                 width: 35.w,
                      //                 decoration: BoxDecoration(
                      //                   borderRadius: BorderRadius.circular(10),
                      //                   gradient: const LinearGradient(
                      //                     colors: [Colors.amber, Colors.orangeAccent],
                      //                   ),
                      //                 ),
                      //               ),
                      //           ],
                      //         ),
                      //       );
                      //     }),
                      //   ),
                      // ),
                      SizedBox(height: 30.h),
                      Obx(() {
                        if (controller.selectedMedal.value != null) {
                          return AppImage(
                            image: ImageModel(
                              network: controller.selectedMedal.value!.icon,
                            ),
                            width: Get.width / 2,
                          );
                        }
                        return SizedBox();
                      }),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1916),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: const Color(0xFFFFB76B).withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // header row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() {
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${controller.myMedals.where((m) => m.isUsed).length}/12",
                                    style: TextStyle(
                                      color: const Color(0xFFFFD687),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                );
                              }),
                              GestureDetector(
                                onTap: () {
                                  BadgeWearBottomSheet.show(
                                    context,
                                    controller,
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFFD687),
                                        Color(0xFFCC7A1A),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18.w,
                                    vertical: 6.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        context.l10n.wear,
                                        style: TextStyle(
                                          color: Colors.brown.shade900,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.brown,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          MedalsGrid(
                            medals: controller.myMedals,
                            controller: controller,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 25.h),

                    Obx(() {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.w,
                          runSpacing: 10.h,
                          children: [
                            ...controller.medals.map(
                              (m) => _bottomMedalCard(m),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 60.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomMedalCard(MedalModel medal) {
    return GestureDetector(
      onTap: () {
        controller.selectedMedal.value = medal;
      },
      child: Container(
        width: Get.width / 2.3,
        height: Get.width / 2.3,
        decoration: BoxDecoration(
          color: const Color(0xFF3A201E),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.amber.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppImage(
              image: ImageModel(network: medal.icon),
              width: 120.w,
            ),
            // if(medal.levels.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () {
                  swipToPage(context, BadgeDetailsScreen(medal: medal));
                },
                icon: Icon(
                  Icons.open_in_full,
                  color: Colors.amber.shade200,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
