import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tom_chat/features/recharge_agency/controllers/recharge_agency_controller.dart';

Map<String, dynamic> dashboard({int coins = 500, String usd = '12.50'}) => {
  'agency': {
    'id': '17',
    'uid': '23',
    'name': 'Agency',
    'coins_balance': coins,
    'usd_balance': usd,
  },
  'requests': [
    {
      'id': '8',
      'uid': '42',
      'amount': '5.25',
      'user_name': 'Recipient',
      'account_name': 'Account holder',
      'account_number': '001234',
      'account_type': '2',
      'created_at': '2026-09-26 10:00:00',
    },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'dashboard exposes agency balances and typed withdrawal details',
    () async {
      final controller = RechargeAgencyController(
        post: (_, _) async => dashboard(),
      );
      addTearDown(() => controller.onDelete());
      expect(await controller.fetchDashboard(), isTrue);
      expect(controller.agency.value!.ownerUid, 23);
      expect(controller.agency.value!.coinsBalance, 500);
      expect(controller.agency.value!.usdBalance, 12.5);
      final request = controller.requests.single;
      expect(request.id, 8);
      expect(request.uid, 42);
      expect(request.amount, '5.25');
      expect(request.accountNumber, '001234');
      expect(request.accountName, 'Account holder');
      expect(controller.busy.value, isFalse);
      expect(controller.failed.value, isFalse);
    },
  );

  test('duplicate actions are blocked while a request is pending', () async {
    final response = Completer<Map<String, dynamic>>();
    var calls = 0;
    final controller = RechargeAgencyController(
      post: (_, _) {
        calls++;
        return response.future;
      },
    );
    addTearDown(() => controller.onDelete());
    final first = controller.fetchDashboard();
    expect(controller.busy.value, isTrue);
    expect(await controller.fetchDashboard(), isFalse);
    controller.recipient.text = '42';
    controller.coins.text = '10';
    expect(await controller.sendCoins(), isFalse);
    expect(calls, 1);
    response.complete(dashboard());
    expect(await first, isTrue);
    expect(controller.busy.value, isFalse);
  });

  test(
    'transfer retries reuse the key; a confirmed new transfer gets a new key',
    () async {
      final calls = <Map<String, dynamic>>[];
      final controller = RechargeAgencyController(
        post: (path, input) async {
          expect(path, 'cash/agency_send_coins');
          calls.add(Map.of(input));
          if (calls.length == 1) throw Exception('Response lost');
          return dashboard(coins: 490);
        },
      );
      addTearDown(() => controller.onDelete());
      controller.recipient.text = '42';
      controller.coins.text = '10';
      expect(await controller.sendCoins(), isFalse);
      expect(controller.failed.value, isTrue);
      expect(controller.recipient.text, '42');
      expect(await controller.sendCoins(), isTrue);
      expect(calls[0]['operation_key'], calls[1]['operation_key']);
      expect(calls[1]['recipient_id'], '42');
      expect(calls[1]['coins'], '10');
      expect(controller.agency.value!.coinsBalance, 490);
      expect(controller.recipient.text, isEmpty);
      expect(controller.coins.text, isEmpty);
      controller.recipient.text = '42';
      controller.coins.text = '10';
      expect(await controller.sendCoins(), isTrue);
      expect(calls[2]['operation_key'], isNot(calls[1]['operation_key']));
    },
  );

  test('changing a failed transfer changes its operation key', () async {
    final keys = <String>[];
    final controller = RechargeAgencyController(
      post: (_, input) async {
        keys.add(input['operation_key'] as String);
        return {};
      },
    );
    addTearDown(() => controller.onDelete());
    controller.recipient.text = '42';
    controller.coins.text = '10';
    await controller.sendCoins();
    controller.coins.text = '20';
    await controller.sendCoins();
    expect(keys[0], isNot(keys[1]));
    expect(controller.busy.value, isFalse);
  });

  test('invalid transfers do not call the API', () async {
    var calls = 0;
    final controller = RechargeAgencyController(
      post: (_, _) async {
        calls++;
        return dashboard();
      },
    );
    addTearDown(() => controller.onDelete());
    controller.recipient.text = '42';
    for (final invalid in [
      '',
      '0',
      '-1',
      '1.5',
      '1e2',
      ' 10',
      '1000000000000000',
    ]) {
      controller.coins.text = invalid;
      expect(await controller.sendCoins(), isFalse);
    }
    controller.recipient.text = 'bad';
    controller.coins.text = '10';
    expect(await controller.sendCoins(), isFalse);
    expect(calls, 0);
  });

  test(
    'delivery applies the server balance and removes the completed request',
    () async {
      final controller = RechargeAgencyController(
        post: (path, input) async {
          if (path == 'cash/agency_deliver') {
            expect(input, {'request_id': 8});
            return {...dashboard(usd: '17.75'), 'requests': []};
          }
          return dashboard();
        },
      );
      addTearDown(() => controller.onDelete());
      await controller.fetchDashboard();
      expect(await controller.deliver(controller.requests.single), isTrue);
      expect(controller.requests, isEmpty);
      expect(controller.agency.value!.usdBalance, 17.75);
      expect(controller.agency.value!.coinsBalance, 500);
    },
  );

  test(
    'the agency selector loads independently of the wallet controller',
    () async {
      final controller = RechargeAgencyController(
        post: (path, _) async {
          expect(path, 'cash/charge_agency');
          return {
            'list': [
              {
                'id': '17',
                'name': 'Agency',
                'country_code': '966',
                'phone': '512345678',
              },
            ],
          };
        },
      );
      addTearDown(() => controller.onDelete());
      expect(await controller.fetchAgencies(), isTrue);
      expect(
        controller.agencies.single.whatsappUri.toString(),
        'https://wa.me/966512345678',
      );
      expect(controller.agency.value, isNull);
      expect(controller.requests, isEmpty);
    },
  );

  test('closing the feature ignores a late response', () async {
    final response = Completer<Map<String, dynamic>>();
    final controller = RechargeAgencyController(
      post: (_, _) => response.future,
    );
    final pending = controller.fetchDashboard();
    controller.onDelete();
    response.complete(dashboard());
    expect(await pending, isFalse);
    expect(controller.agency.value, isNull);
    expect(await controller.fetchDashboard(), isFalse);
  });
}
