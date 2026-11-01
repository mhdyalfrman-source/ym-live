import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/utils/snakbar_dialog.dart';
import 'package:tom_chat/features/recharge_agency/models/agency_withdrawal_model.dart';
import 'package:tom_chat/features/recharge_agency/models/recharge_agency_model.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class RechargeAgencyController extends GetxController {
  RechargeAgencyController({
    Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)? post,
  }) : _post = post ?? _postRequest;

  final Future<Map<String, dynamic>> Function(String, Map<String, dynamic>)
  _post;
  final agency = Rxn<RechargeAgencyModel>();
  final agencies = <RechargeAgencyModel>[].obs;
  final requests = <AgencyWithdrawalModel>[].obs;
  final busy = false.obs;
  final failed = false.obs;
  final recipient = TextEditingController();
  final coins = TextEditingController();
  final transferForm = GlobalKey<FormState>();
  String? _operationKey;
  String? _transferIntent;

  static Future<Map<String, dynamic>> _postRequest(
    String path,
    Map<String, dynamic> input,
  ) => CallServerAPI.post(
    path,
    input,
    withMessage: true,
    withSnakbar: true,
    errorText: (error) => rechargeAgencyError(Get.context!, error),
  );

  Future<bool> _load(String action, Map<String, dynamic> input) async {
    if (busy.value || isClosed) return false;
    busy.value = true;
    try {
      final response = await _post('cash/$action', input);
      if (isClosed) return false;
      final success = action == 'charge_agency'
          ? response['list'] is List
          : response['agency'] is Map;
      failed.value = !success;
      if (!success) return false;
      if (action == 'charge_agency') {
        agencies.assignAll(
          (response['list'] as List).map(
            (row) =>
                RechargeAgencyModel.fromMap(Map<String, dynamic>.from(row)),
          ),
        );
      } else {
        agency.value = RechargeAgencyModel.fromMap(
          Map<String, dynamic>.from(response['agency']),
        );
        if (response['requests'] is List) {
          requests.assignAll(
            (response['requests'] as List).map(
              (row) =>
                  AgencyWithdrawalModel.fromMap(Map<String, dynamic>.from(row)),
            ),
          );
        }
      }
      return true;
    } catch (_) {
      if (!isClosed) failed.value = true;
      return false;
    } finally {
      if (!isClosed) busy.value = false;
    }
  }

  Future<bool> fetchDashboard() => _load('agency_dashboard', {});

  Future<bool> fetchAgencies() => _load('charge_agency', {});

  Future<bool> deliver(AgencyWithdrawalModel request) =>
      _load('agency_deliver', {'request_id': request.id});

  bool isPositiveInteger(String value) =>
      RegExp(r'^[1-9][0-9]{0,14}$').hasMatch(value);

  Future<bool> sendCoins() async {
    if (busy.value ||
        isClosed ||
        !isPositiveInteger(recipient.text) ||
        !isPositiveInteger(coins.text)) {
      return false;
    }
    final intent = '${recipient.text}:${coins.text}';
    if (_transferIntent != intent) {
      _transferIntent = intent;
      final random = Random.secure();
      _operationKey = List.generate(
        24,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
    }
    final sent = await _load('agency_send_coins', {
      'recipient_id': recipient.text,
      'coins': coins.text,
      'operation_key': _operationKey,
    });
    if (sent && !isClosed) {
      recipient.clear();
      coins.clear();
      _transferIntent = null;
      _operationKey = null;
    }
    return sent;
  }

  Future<void> selectAgency(
    RechargeAgencyModel selected, {
    required bool forRecharge,
  }) async {
    if (!forRecharge) {
      Get.back(result: selected);
      return;
    }
    var opened = false;
    try {
      final uri = selected.whatsappUri;
      opened =
          uri != null &&
          await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && !isClosed) {
      snakbarDialog(
        title: Get.context!.l10n.agencyWhatsAppError,
        durationSecound: 4,
      );
    }
  }

  @override
  void onClose() {
    recipient.dispose();
    coins.dispose();
    super.onClose();
  }
}

String rechargeAgencyError(BuildContext context, String code) {
  final l10n = context.l10n;
  return switch (code) {
    'invalid_amount' => l10n.agencyPositiveInteger,
    'agency_not_owned' => l10n.agencyAccessDenied,
    'agency_not_found' => l10n.agencyNotFound,
    'invalid_account' => l10n.agencyInvalidAccount,
    'no_user' => l10n.thisUserNotExis,
    'not_enough_agency_coins' => l10n.agencyInsufficientCoins,
    'not_enough_money' => l10n.agencyInsufficientWithdrawal,
    'withdrawal_not_found' => l10n.agencyWithdrawalUnavailable,
    'withdrawal_already_processed' => l10n.agencyWithdrawalProcessed,
    'operation_conflict' => l10n.agencyTransferConflict,
    _ => l10n.agencyOperationFailed,
  };
}
