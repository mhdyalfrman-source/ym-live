import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/utils/delete_dialog.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/buttons.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/features/recharge_agency/controllers/recharge_agency_controller.dart';
import 'package:tom_chat/features/recharge_agency/models/agency_withdrawal_model.dart';
import 'package:tom_chat/features/recharge_agency/send_agency_coins_screen.dart';
import 'package:tom_chat/l10n/l10n.dart';

class RechargeAgencyScreen extends StatefulWidget {
  const RechargeAgencyScreen({super.key});

  @override
  State<RechargeAgencyScreen> createState() => _RechargeAgencyScreenState();
}

class _RechargeAgencyScreenState extends State<RechargeAgencyScreen> {
  late final RechargeAgencyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RechargeAgencyController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.fetchDashboard();
    });
  }

  @override
  void dispose() {
    Get.delete<RechargeAgencyController>();
    super.dispose();
  }

  Future<void> _confirmDelivery(AgencyWithdrawalModel request) async {
    final confirmed = await deleteMessage(
      title: context.l10n.agencyConfirmDelivery,
      content: context.l10n.agencyConfirmPaid(request.amount, '${request.uid}'),
      deleteButton: context.l10n.agencyPaidDelivered,
      cancelButton: context.l10n.cancel,
      onWillPop: true,
      onDelete: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    if (confirmed == true && mounted) await controller.deliver(request);
  }

  @override
  Widget build(BuildContext context) => PageTemplete(
    title: context.l10n.rechargeAgencyTitle,
    actions: [
      Obx(
        () => IconButtonWidget(
          onPressed: controller.busy.value ? null : controller.fetchDashboard,
          icon: const Icon(Icons.refresh),
        ),
      ),
    ],
    child: RefreshIndicator(
      onRefresh: () async {
        await controller.fetchDashboard();
      },
      child: Obx(() {
        final agency = controller.agency.value;
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (controller.failed.value)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(context.l10n.agencyOperationFailed),
              ),
            if (agency != null) ...[
              Text(agency.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              CardWidget(
                radius: 10,
                colorIndex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.agencyCoinsBalance(
                          '${agency.coinsBalance}',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        context.l10n.agencyUsdBalance(
                          agency.usdBalance.toStringAsFixed(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GeneralButton3(
                onPressed: controller.busy.value
                    ? null
                    : () async {
                        await swipToPage(
                          context,
                          SendAgencyCoinsScreen(controller: controller),
                        );
                      },
                icon: const Icon(Icons.send),
                title: context.l10n.agencySendCoins,
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.withdrawOrders,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (controller.requests.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(context.l10n.agencyNoPending),
                ),
              for (final request in controller.requests)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: CardWidget(
                    radius: 10,
                    colorIndex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            context.l10n.agencyRequestSummary(
                              '${request.id}',
                              request.amount,
                            ),
                          ),
                          Text(
                            '${request.userName} · ${context.l10n.id('${request.uid}')}',
                          ),
                          Text(
                            context.l10n.agencyAccountHolder(
                              request.accountName,
                            ),
                          ),
                          SelectableText(
                            context.l10n.agencyAccountNumber(
                              request.accountNumber,
                            ),
                          ),
                          Text(
                            context.l10n.agencyAccountType(request.accountType),
                          ),
                          Text(request.createdAt),
                          const SizedBox(height: 12),
                          GeneralButton(
                            onPressed: controller.busy.value
                                ? null
                                : () => _confirmDelivery(request),
                            title: context.l10n.agencyMarkDelivered,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        );
      }),
    ),
  );
}
