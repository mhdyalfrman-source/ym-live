import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/widgets/app_image.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/recharge_agency/models/recharge_agency_model.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/recharge_agency/controllers/recharge_agency_controller.dart';
import 'package:tom_chat/l10n/l10n.dart';

class WithdrawAgencyScreen extends StatefulWidget {
  final bool forRecharge;
  const WithdrawAgencyScreen({super.key, this.forRecharge = false});

  @override
  State<WithdrawAgencyScreen> createState() => _WithdrawAgencyScreenState();
}

class _WithdrawAgencyScreenState extends State<WithdrawAgencyScreen> {
  late final RechargeAgencyController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.put(RechargeAgencyController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.fetchAgencies();
    });
  }

  @override
  void dispose() {
    Get.delete<RechargeAgencyController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.withdrawAgencyies,
      child: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(10).r,
          child: ListView.separated(
            itemBuilder: (context, index) {
              RechargeAgencyModel a = controller.agencies[index];
              return agencyItem(context, a);
            },
            separatorBuilder: (context, index) {
              return SizedBox(height: 5.h);
            },
            itemCount: controller.agencies.length,
          ),
        );
      }),
    );
  }

  Future<void> selectAgency(RechargeAgencyModel agency) =>
      controller.selectAgency(agency, forRecharge: widget.forRecharge);

  Widget agencyItem(BuildContext context, RechargeAgencyModel a) {
    return GestureDetector(
      onTap: () {
        selectAgency(a);
      },
      child: CardWidget(
        radius: 10.r,
        colorIndex: 1,
        child: Row(
          children: [
            AppImage(image: a.icon, width: 70.r, height: 70.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  Text(
                    context.l10n.id(a.id),
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    "${context.l10n.name} : ${a.name}",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    a.description,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5.h),
                ],
              ),
            ),
            IconButtonWidget(
              icon: Icon(Icons.check, color: Colors.white),
              onPressed: () async {
                await selectAgency(a);
              },
            ),
          ],
        ),
      ),
    );
  }
}
