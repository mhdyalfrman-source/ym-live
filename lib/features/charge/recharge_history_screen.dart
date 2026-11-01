import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/wallet/controllers/wallet_controller.dart';
import 'package:tom_chat/features/wallet/models/payment_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/helpers/image_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

class RechargeHistoryScreen extends StatefulWidget {
  const RechargeHistoryScreen({super.key});

  @override
  State<RechargeHistoryScreen> createState() => _RechargeHistoryScreenState();
}

class _RechargeHistoryScreenState extends State<RechargeHistoryScreen> {
  late WalletController controller;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(WalletController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.payments.clear();
      controller.paymentPage = 1;
      controller.hasMorePayments.value = true;
      controller.fetchPayments();
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        controller.fetchPayments();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.paymentsOrders,
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(10).r,
          child: ListView.separated(
            controller: scrollController,
            itemBuilder: (context, index) {
              PaymentModel a = controller.payments[index];
              return paymentItem(context, a);
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 5.h);
            },
            itemCount: controller.payments.length,
          ),
        );
      }),
    );
  }

  Widget paymentItem(BuildContext context, PaymentModel p) {
    return CardWidget(
      radius: 10.r,
      colorIndex: 1,
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: Column(
          children: [
            Row(
              children: [
                Row(
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
                      "${p.coins}",
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${p.money}",
                      style: Theme.of(context).textTheme.displaySmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "USD",
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                SizedBox(width: 10.w),
                Text(
                  p.type.getLabel(context),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.grey.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  p.status.getLabel(context),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: p.status == StateEnum.active
                        ? Colors.teal
                        : p.status == StateEnum.reject
                        ? AppColors.red
                        : Colors.white,
                  ),
                ),
                SizedBox(width: 10.w),
              ],
            ),
            SizedBox(height: 5.h),
            Divider(color: Colors.white70),
            Row(
              children: [
                SizedBox(width: 10.w),
                Text(
                  "${context.l10n.orderId}: ${p.id}",
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.grey.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 5.w),
                GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                      ClipboardData(text: p.id.toString()),
                    );
                    done();
                  },
                  child: Icon(Icons.copy, size: 15.r),
                ),
              ],
            ),
            SizedBox(height: 5.h),
            Row(
              children: [
                SizedBox(width: 10.w),
                Text(
                  DateFormat(
                    "yyyy-MM-dd HH:mm:ss",
                  ).format(p.date.toLocalDateTime()),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Colors.grey.shade200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
