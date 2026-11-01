import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tom_chat/l10n/app_localizations.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/features/recharge_agency/controllers/recharge_agency_controller.dart';
import 'package:tom_chat/features/recharge_agency/models/recharge_agency_model.dart';
import 'package:tom_chat/features/wallet/models/withdraw_order_model.dart';
import 'package:tom_chat/models/user/user_model.dart';

void main() {
  test('all agency strings and placeholders exist in all 11 languages', () {
    final english =
        jsonDecode(File('lib/l10n/arb/app_en.arb').readAsStringSync())
            as Map<String, dynamic>;
    final keys = english.keys
        .where(
          (key) =>
              key == 'rechargeAgencyTitle' ||
              key == 'rechargeViaAgency' ||
              key.startsWith('withdrawalAgency') ||
              (key.startsWith('agency') &&
                  !['agencyName', 'agencyId', 'agencyOwner'].contains(key)),
        )
        .toList();
    expect(keys.length, greaterThanOrEqualTo(31));
    for (final locale in AppLocalizations.supportedLocales) {
      final messages =
          jsonDecode(
                File(
                  'lib/l10n/arb/app_${locale.languageCode}.arb',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      for (final key in keys) {
        expect(
          messages[key],
          isA<String>(),
          reason: '${locale.languageCode}: $key',
        );
        final placeholders = RegExp(r'\{[a-zA-Z]+\}');
        expect(
          placeholders
              .allMatches(messages[key] as String)
              .map((m) => m.group(0))
              .toSet(),
          placeholders
              .allMatches(english[key] as String)
              .map((m) => m.group(0))
              .toSet(),
          reason: '${locale.languageCode}: $key',
        );
      }
    }
    expect(AppLocalizations.supportedLocales.length, 11);
  });

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets('agency errors are localized in ${locale.languageCode}', (
      tester,
    ) async {
      String? expected;
      await tester.pumpWidget(
        Localizations(
          locale: locale,
          delegates: const [
            AppLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: Builder(
            builder: (context) {
              expected = context.l10n.agencyInsufficientCoins;
              return Text(
                rechargeAgencyError(context, 'not_enough_agency_coins'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(expected!), findsOneWidget);
      expect(find.text('not_enough_agency_coins'), findsNothing);
    });
  }
  test('recharge opens WhatsApp with the stored country calling code', () {
    final agency = RechargeAgencyModel.fromMap({
      'id': '17',
      'name': 'Agency',
      'country_code': '+966',
      'phone': '512345678',
      'icon': 'https://example.com/agency.png',
    });
    expect(agency.whatsappUri.toString(), 'https://wa.me/966512345678');
    expect(agency.icon?.network, 'https://example.com/agency.png');
    expect(agency.id, 17);
    expect(RechargeAgencyModel.fromMap({'phone': 'bad'}).whatsappUri, isNull);
  });

  test(
    'cash owner link survives user serialization independently of families',
    () {
      final owner = UserModel.fromMap({'uid': 23, 'recharge_agency_id': '17'});
      expect(UserModel.fromMap(owner.toMap()).rechargeAgencyId, 17);
      expect(owner.agency, isNull);
      expect(UserModel.fromMap({'uid': 24}).rechargeAgencyId, 0);
    },
  );

  test('withdrawal history uses only the cash agency link', () {
    final order = WithdrawOrderModel.fromMap({
      'id': 3,
      'uid': 23,
      'status': 1,
      'agency_id': 999,
      'recharge_agency_id': 17,
      'recharge_agency': {'id': 17, 'name': 'Cash agency'},
    });
    expect(order.agencyId, 17);
    expect(order.agency?.name, 'Cash agency');
  });
}
