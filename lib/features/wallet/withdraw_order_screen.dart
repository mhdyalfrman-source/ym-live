import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/wallet/controllers/wallet_controller.dart';
import 'package:tom_chat/features/wallet/models/withdraw_order_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class WithdrawOrderScreen extends StatefulWidget {
  final WalletController controller;
  const WithdrawOrderScreen({super.key, required this.controller});

  @override
  State<WithdrawOrderScreen> createState() => _WithdrawOrderScreenState();
}

class _WithdrawOrderScreenState extends State<WithdrawOrderScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.orders.clear();
      widget.controller.orderPage = 1;
      widget.controller.hasMoreOrders.value = true;
      widget.controller.fetchOrders();
    });
    scrollController.addListener(() async {
      if (scrollController.position.maxScrollExtent <=
              scrollController.offset &&
          scrollController.offset > 0) {
        widget.controller.fetchOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.withdrawOrders,
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(10).r,
          child: ListView.separated(
            controller: scrollController,
            itemBuilder: (context, index) {
              WithdrawOrderModel a = widget.controller.orders[index];
              return agencyItem(context, a);
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 5.h);
            },
            itemCount: widget.controller.orders.length,
          ),
        );
      }),
    );
  }

  Widget agencyItem(BuildContext context, WithdrawOrderModel a) {
    return CardWidget(
      radius: 10.r,
      colorIndex: 1,
      child: Row(
        children: [
          CachedImage(
            widget.controller.cashData.value!.paymentTypes
                    ?.firstWhereOrNull((p) => p.id == a.type)
                    ?.icon ??
                "",
            type: ImageType.general,
            width: 70.r,
            height: 70.r,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.h),
                Text(
                  "${context.l10n.orderNumber} ${a.id}",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  "${context.l10n.amount} : ${a.money}\$",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  "${context.l10n.account} : ${a.account}",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  "${context.l10n.name} : ${a.name}",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                if (a.agency != null) ...[
                  Text(
                    "${context.l10n.agencyName} : ${a.agency?.name}",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                ],
              ],
            ),
          ),
          SizedBox(width: 7.w),
          Text(
            a.status.getLabel(context),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: a.status == StateEnum.active
                  ? Colors.teal
                  : a.status == StateEnum.reject
                  ? AppColors.red
                  : Colors.white,
            ),
          ),
          SizedBox(width: 7.w),
        ],
      ),
    );
  }
}
