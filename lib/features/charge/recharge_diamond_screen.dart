import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/wallet/controllers/wallet_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/statics_values.dart';

class RechargeDiamondScreen extends StatefulWidget {
  const RechargeDiamondScreen({super.key});

  @override
  State<RechargeDiamondScreen> createState() => _RechargeDiamondScreenState();
}

class _RechargeDiamondScreenState extends State<RechargeDiamondScreen> {
  late WalletController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(WalletController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.rechargeDiamond,
      // actions: [
      //   IconButton(onPressed: (){
      //     swipToPage(context, RechargeDiamondHistoryScreen());
      //   }, icon: Icon(HugeIcons.strokeRoundedTransactionHistory,color: AppColors.primary,))
      // ],
      child: Padding(
        padding: const EdgeInsets.all(10).copyWith(top: 0).r,
        child: Obx(() {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 150.h,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/daimond_bg.png"),
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
                            // IconButton(icon:Icon(HugeIcons.strokeRoundedRefresh,color:Colors.white),onPressed:(){

                            // }),
                            Text(
                              context.l10n.diamond,
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        Text(
                          StaticValue.diamond.value.toString(),
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
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    spacing: 10.h,
                    children: [
                      if (controller.cashData.value != null) ...[
                        rechargeItem(1000),
                        rechargeItem(5000),
                        rechargeItem(10000),
                        rechargeItem(20000),
                        // rechargeItem(50000),
                      ],
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xffFFDDBC),
                          borderRadius: BorderRadius.circular(10).r,
                        ),
                        margin: EdgeInsets.all(1).r,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 10.w),
                                  AppImage(
                                    width: 20.r,
                                    image: ImageModel(
                                      asset: "assets/images/coin.png",
                                      type: "asset",
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    "${controller.diamondToCoins.value}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall!
                                        .copyWith(
                                          color: Color(0xffFD8203),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "${context.l10n.coins} =",
                              style: Theme.of(context).textTheme.displaySmall!
                                  .copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InputField(
                                  isRequired: true,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(color: Colors.black),
                                  suffix: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: AppImage(
                                      width: 10.r,
                                      image: ImageModel(
                                        asset: "assets/images/daimond.png",
                                        type: "asset",
                                      ),
                                    ),
                                  ),
                                  onChanged: (v) {
                                    controller.diamondToCoins.value = controller
                                        .convertUsdToCoins(
                                          totalUsd: MyMath.toInt(v).toDouble(),
                                          cashRate: controller
                                              .cashData
                                              .value!
                                              .diamondRate,
                                        );
                                  },
                                  keyboardType: TextInputType.number,
                                  controller: controller.diamond,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  return GeneralButton(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colorIndex: 3,
                    onPressed: controller.diamondToCoins.value == 0
                        ? null
                        : () async {
                            await controller.exchangeDiamond(
                              controller.diamond.text,
                            );
                          },
                    title: context.l10n.exchange,
                  );
                }),
              ),
              SizedBox(height: 10.h),
            ],
          );
        }),
      ),
    );
  }

  Widget rechargeItem(int coins) {
    int diamods = controller.convertUsdToCoins(
      totalUsd: coins.toDouble(),
      cashRate: controller.cashData.value!.diamondRate,
    );
    return GestureDetector(
      onTap: () {
        controller.diamondToCoins.value = diamods;
        controller.diamond.text = "$coins";
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardWidget(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            enable: controller.diamondToCoins.value == diamods,
            colorIndex: 3,
            radius: 10.r,
            height: 45.h,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xffFFDDBC),
                borderRadius: BorderRadius.circular(10).r,
              ),
              margin: EdgeInsets.all(1).r,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 10.w),
                        AppImage(
                          width: 20.r,
                          image: ImageModel(
                            asset: "assets/images/coin.png",
                            type: "asset",
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          diamods.toString(),
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(
                                color: Color(0xffFD8203),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.diamondToCoins.value = coins;
                    },
                    icon: Image.asset("assets/images/swip.png", width: 20.r),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          coins.toString(),
                          style: Theme.of(context).textTheme.displaySmall!
                              .copyWith(
                                color: Color(0xffFD8203),
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(width: 5.w),
                        AppImage(
                          width: 20.r,
                          image: ImageModel(
                            asset: "assets/images/daimond.png",
                            type: "asset",
                          ),
                        ),
                        SizedBox(width: 10.w),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
