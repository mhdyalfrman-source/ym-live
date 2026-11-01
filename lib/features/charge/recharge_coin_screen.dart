import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/charge/controllers/payment_controller.dart';
import 'package:tom_chat/features/charge/recharge_history_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/recharge_agency/withdraw_agency_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/statics_values.dart';

class RechargeCoinScreen extends StatefulWidget {
  const RechargeCoinScreen({super.key});

  @override
  State<RechargeCoinScreen> createState() => _RechargeCoinScreenState();
}

class _RechargeCoinScreenState extends State<RechargeCoinScreen> {
  final PageController pageController = PageController();
  late PaymentController controller;

  @override
  void initState() {
    controller = Get.put(PaymentController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCoinPlans();
      // controller.loadProfileData();
      // controller.fetchExchangePlans();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.recharge,
      onBack: () {
        if ((pageController.page ?? 0) == 1) {
          animatedMovePageView(pageController, 0);
        } else {
          Get.back();
        }
      },
      actions: [
        IconButton(
          onPressed: () {
            swipToPage(context, RechargeHistoryScreen());
          },
          icon: Icon(
            HugeIcons.strokeRoundedTransactionHistory,
            color: AppColors.primary,
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(10).copyWith(top: 0).r,
        child: Obx(() {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 150.h,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/coin_bg.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  padding: const EdgeInsets.all(20).r,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                HugeIcons.strokeRoundedRefresh,
                                color: Colors.white,
                              ),
                              onPressed: () async {},
                            ),
                            Text(
                              context.l10n.coins_balance,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          StaticValue.coins.value.toString(),
                          style: Theme.of(context).textTheme.displayLarge!
                              .copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Obx(() {
              //   return AvailableBalanceWidget(
              //     profileData: controller.profileData.value,
              //   );
              // }),
              SizedBox(height: 20.h),

              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // ===================== Step 1: Plans =====================
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: _plansSection(context),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // زر Pay (ينقل للطرق)
                        SizedBox(
                          width: double.infinity,
                          child: GeneralButton(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colorIndex: 3,
                            onPressed: controller.selectedPlan == null
                                ? null
                                : () async {
                                    await controller.purchaseProduct();
                                    // animatedMovePageView(pageController, 1);
                                  },
                            title: context.l10n.pay,
                          ),
                        ),

                        SizedBox(height: 10.h),
                        CardWidget(
                          colorIndex: 1,
                          radius: 10.r,
                          child: ListTile(
                            title: Text(context.l10n.rechargeViaAgency,style: Theme.of(context).textTheme.displayMedium),
                            trailing: Text(context.l10n.agencyDiscount('20'),style: Theme.of(context).textTheme.labelMedium,),
                            leading: const Icon(Icons.storefront,color: Colors.white,),
                            onTap: () => swipToPage(
                              context,
                              WithdrawAgencyScreen(forRecharge: true),
                            ),
                          ),
                        ),
                        SizedBox(height: 15.h),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ====== Plans Section (منقولة من RechargeScreen لكن بنفس شكل الصفحة الثانية) ======
  Widget _plansSection(BuildContext context) {
    // نفس متغيرات التحميل من PaymentController
    if (controller.isLoading.value) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: CupertinoActivityIndicator(radius: 20),
      );
    }

    if (controller.coinPlans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(50),
        child: Center(
          child: Text(
            context.l10n.noCointPlansAvailable,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      primary: false,
      itemCount: controller.coinPlans.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 5.r,
        mainAxisSpacing: 5.r,
        crossAxisCount: 2,
        mainAxisExtent: 50.h,
      ),
      itemBuilder: (context, index) {
        final plan = controller.coinPlans[index];

        final isSelected = controller.selectedPlanIndex.value == index;

        return GestureDetector(
          onTap: () => controller.selectPlan(index),
          child: _rechargeItemUi(
            context: context,
            coins: (plan.coin).toDouble(),
            money: (plan.money).toDouble(),
            selected: isSelected,
          ),
        );
      },
    );
  }

  // ====== نفس شكل عنصر الباقة في الصفحة الثانية ======
  Widget _rechargeItemUi({
    required BuildContext context,
    required double coins,
    required double money,
    required bool selected,
  }) {
    return CardWidget(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      enable: selected,
      colorIndex: 3,
      radius: 10.r,
      height: 45.h,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffFFDDBC),
          borderRadius: BorderRadius.circular(10).r,
        ),
        margin: EdgeInsets.all(1).r,
        child: Row(
          children: [
            SizedBox(width: 5.w),
            AppImage(
              width: 20.r,
              image: ImageModel(asset: "assets/images/coin.png", type: "asset"),
            ),
            SizedBox(width: 5.w),
            Text(
              coins.toStringAsFixed(0),
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                color: const Color(0xffFD8203),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            CardWidget(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              radius: 20.r,
              colorIndex: 3,
              child: Padding(
                padding: const EdgeInsets.all(3).r,
                child: Text(
                  "\$${money.toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 5.w),
          ],
        ),
      ),
    );
  }
}
