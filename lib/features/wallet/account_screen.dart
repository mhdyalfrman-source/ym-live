import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/wallet/add_account_screen.dart';
import 'package:tom_chat/features/wallet/controllers/wallet_controller.dart';
import 'package:tom_chat/features/wallet/models/my_account_model.dart';
import 'package:tom_chat/l10n/l10n.dart';

class AccountScreen extends StatelessWidget {
  final WalletController controller;
  const AccountScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.myAccounts,
      actions: [
        IconButton(
          onPressed: () {
            swipToPage(context, AddAccountScreen());
          },
          icon: Icon(Icons.add, color: AppColors.primary),
        ),
      ],
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(10).r,
          child: ListView.separated(
            itemBuilder: (context, index) {
              MyAccountModel a = controller.accounts[index];
              return accountItem(context, a);
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 5.h);
            },
            itemCount: controller.accounts.length,
          ),
        );
      }),
    );
  }

  Widget accountItem(BuildContext context, MyAccountModel a) {
    return CardWidget(
      radius: 10.r,
      colorIndex: 1,
      child: Row(
        children: [
          CachedImage(
            controller.cashData.value!.paymentTypes
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
                Text(
                  "${context.l10n.name} : ${a.name}",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.h),
                Text(
                  "${context.l10n.accountNumber} : ${a.account}",
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () async {
              deleteMessage(
                title: context.l10n.confirm,
                content: context.l10n.areYouSrueYouWantToDelteThisAccount,
                onDelete: () async {
                  Get.back();
                  await controller.deleteAccout(a);
                },
                onCancel: Get.back,
                onWillPop: true,
                cancelButton: context.l10n.cancel,
                deleteButton: context.l10n.delete,
              );
            },
          ),
        ],
      ),
    );
  }
}
