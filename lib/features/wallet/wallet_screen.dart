import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/theme/color.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/core/widgets/dropdown_button.dart';
import 'package:tom_chat/core/widgets/input_field.dart';
import 'package:tom_chat/features/recharge_agency/models/recharge_agency_model.dart';
import 'package:tom_chat/features/home/main_screen.dart';
import 'package:tom_chat/features/home/search_screen.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/wallet/account_screen.dart';
import 'package:tom_chat/features/wallet/controllers/wallet_controller.dart';
import 'package:tom_chat/features/recharge_agency/withdraw_agency_screen.dart';
import 'package:tom_chat/features/wallet/withdraw_order_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  PageController pageController = PageController();
  late WalletController controller;

  GlobalKey<FormState> sendFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> withdrawFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = Get.put(WalletController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyData();
      controller.fetchAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.wallet,
      onBack: () {
        if (controller.pageIndex.value != 0) {
          animatedMovePageView(pageController, 0);
          return;
        }
        Get.back();
      },
      actions: [
        IconButton(
          onPressed: () {
            swipToPage(context, WithdrawOrderScreen(controller: controller));
          },
          icon: Icon(
            HugeIcons.strokeRoundedTransactionHistory,
            color: AppColors.primary,
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(10).r,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 120.h,
                child: CardWidget(
                  colorIndex: 1,
                  radius: 10.r,
                  child: Obx(() {
                    return Container(
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
                                Text(
                                  context.l10n.balance,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            Text(
                              "${controller.cashData.value?.total?.toStringAsFixed(1) ?? ""} \$",
                              style: Theme.of(context).textTheme.displayLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 10.h),
              TabWidget3(
                tabs: [context.l10n.withdraw, context.l10n.send1],
                onTap: (index) {},
              ),
              Expanded(
                child: Obx(() {
                  if (controller.cashData.value == null) {
                    return Center(
                      child: CupertinoActivityIndicator(
                        color: AppColors.primaryDark,
                        radius: 15.r,
                      ),
                    );
                  }
                  return TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            Padding(
                              padding: const EdgeInsets.all(10).r,
                              child: Form(
                                key: withdrawFormKey,
                                child: CardWidget(
                                  radius: 10.r,
                                  colorIndex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10).r,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 15.h),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: DropdownButtonWidget(
                                                selectedItem: controller
                                                    .selectedAccount
                                                    .value,
                                                title: context.l10n.account,
                                                items: controller.accounts.map((
                                                  a,
                                                ) {
                                                  return DropdownButtonModel(
                                                    dropValue: a.id,
                                                    dropName: a.name,
                                                    dropNetworkImage: controller
                                                        .cashData
                                                        .value!
                                                        .paymentTypes
                                                        ?.firstWhereOrNull(
                                                          (p) => p.id == a.type,
                                                        )
                                                        ?.icon,
                                                  );
                                                }).toList(),
                                                onChanged: (v) {
                                                  controller
                                                          .selectedAccount
                                                          .value =
                                                      v;
                                                },
                                              ),
                                            ),
                                            GeneralButton3(
                                              onPressed: () {
                                                swipToPage(
                                                  context,
                                                  AccountScreen(
                                                    controller: controller,
                                                  ),
                                                );
                                              },
                                              title: context.l10n.myAccounts,
                                              margin: 2,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15.h),
                                        InputField(
                                          keyboardType: TextInputType.number,
                                          isNumber: true,
                                          isRequired: true,
                                          maxLength: 10,
                                          aboveLabel: context.l10n.amount,
                                          controller: controller.withdrawAmount,
                                          hint: context.l10n.amount,
                                          validator: (v) {
                                            if (MyMath.toDouble(v) <
                                                controller
                                                    .cashData
                                                    .value!
                                                    .cashMin) {
                                              return context.l10n.minAmountis(
                                                controller
                                                    .cashData
                                                    .value!
                                                    .cashMin,
                                              );
                                            }
                                            return null;
                                          },
                                        ),
                                        SizedBox(height: 15.h),
                                        InputField(
                                          isRequired: false,
                                          keyboardType: TextInputType.number,
                                          isNumber: true,
                                          controller: controller.agecny,
                                          aboveLabel: context
                                              .l10n
                                              .withdrawalAgencyNumber,
                                          hint:
                                              context.l10n.withdrawalAgencyHint,
                                          onChanged: (_) =>
                                              controller.selectedAgency.value =
                                                  null,
                                          suffix: IconButtonWidget(
                                            icon: const Icon(Icons.search),
                                            onPressed: () async {
                                              final agency = await swipToPage(
                                                context,
                                                const WithdrawAgencyScreen(),
                                              );
                                              if (agency
                                                  is RechargeAgencyModel) {
                                                controller
                                                        .selectedAgency
                                                        .value =
                                                    agency.id;
                                                controller.agecny.text = agency
                                                    .id
                                                    .toString();
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 15.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 50.h),
                            SizedBox(
                              width: double.infinity,
                              child: GeneralButton3(
                                color: AppColors.primaryDark,
                                fontColor: Colors.white,
                                onPressed: () async {
                                  if (withdrawFormKey.currentState!
                                      .validate()) {
                                    await controller.withdrawMoney();
                                  }
                                },
                                title: context.l10n.withdraw1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 10.h),
                            Form(
                              key: sendFormKey,
                              child: Padding(
                                padding: const EdgeInsets.all(10).r,
                                child: CardWidget(
                                  radius: 10.r,
                                  colorIndex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10).r,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        SizedBox(height: 15.h),
                                        InputField(
                                          keyboardType: TextInputType.number,
                                          isRequired: true,
                                          aboveLabel: context.l10n.userID,
                                          controller: controller.userId,
                                          hint: context.l10n.userID,
                                          suffix: IconButton(
                                            icon: Icon(Icons.search),
                                            onPressed: () async {
                                              var res = await swipToPage(
                                                context,
                                                SearchScreen(
                                                  withButton: false,
                                                  initialIndex: 1,
                                                  withSelect: true,
                                                ),
                                              );
                                              if (res is UserModel) {
                                                controller.userId.text =
                                                    "${res.userId}";
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 15.h),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: InputField(
                                                keyboardType:
                                                    TextInputType.number,
                                                isNumber: true,
                                                isRequired: false,
                                                aboveLabel: context.l10n.coins,
                                                controller: controller.coins,
                                                hint: context.l10n.coins,
                                                maxLength: 10,
                                                onChanged: (v) {
                                                  controller
                                                      .coinsToUsd
                                                      .value = controller
                                                      .convertCoinsToUsd(
                                                        coins: MyMath.toInt(v),
                                                        cashRate: controller
                                                            .cashData
                                                            .value!
                                                            .exchangeRate,
                                                      );
                                                },
                                                suffix: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ).r,
                                                  child: Image.asset(
                                                    "assets/images/coin.png",
                                                    width: 15.r,
                                                    height: 15.r,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 5.w),
                                            Obx(() {
                                              return Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: 15.h,
                                                ),
                                                child: Text(
                                                  " = ${controller.coinsToUsd.value.toStringAsFixed(1)}\$",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelLarge!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              );
                                            }),
                                          ],
                                        ),
                                        SizedBox(height: 15.h),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 100.h),
                            SizedBox(
                              width: double.infinity,
                              child: Obx(() {
                                return GeneralButton3(
                                  color: AppColors.primaryDark,
                                  fontColor: Colors.white,
                                  onPressed: controller.coinsToUsd.value == 0
                                      ? null
                                      : () async {
                                          if (sendFormKey.currentState!
                                              .validate()) {
                                            await controller.sendMoney();
                                          }
                                        },
                                  title: context.l10n.send,
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
