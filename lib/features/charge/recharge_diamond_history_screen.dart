import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/features/charge/controllers/charge_controller.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/models/helpers/image_model.dart';

class RechargeDiamondHistoryScreen extends StatefulWidget {
  const RechargeDiamondHistoryScreen({super.key});

  @override
  State<RechargeDiamondHistoryScreen> createState() =>
      _RechargeDiamondHistoryScreenState();
}

class _RechargeDiamondHistoryScreenState
    extends State<RechargeDiamondHistoryScreen> {
  ChargeController controller = Get.put(ChargeController());
  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: "Exchange History",
      child: Padding(
        padding: const EdgeInsets.all(10).copyWith(top: 0).r,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 10.h,
                  children: [
                    rechargeItem(1000, DateTime.now(), 1000),
                    rechargeItem(5000, DateTime.now(), 1000),
                    rechargeItem(10000, DateTime.now(), 1000),
                    rechargeItem(20000, DateTime.now(), 1000),
                    rechargeItem(50000, DateTime.now(), 1000),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rechargeItem(double coins, DateTime date, double diamond) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xffFFDDBC),
        borderRadius: BorderRadius.circular(10).r,
      ),
      padding: EdgeInsets.all(10).r,
      child: Column(
        children: [
          Text(
            "Exchange",
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Color(0xffFD8203),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5.h),
          Row(
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
                      coins.toString(),
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Color(0xffFD8203),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.selectedDiamond.value = coins;
                },
                icon: Image.asset("assets/images/swip.png", width: 20.r),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      diamond.toString(),
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
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
          Text(
            date.toString(),
            style: Theme.of(
              context,
            ).textTheme.labelLarge!.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
