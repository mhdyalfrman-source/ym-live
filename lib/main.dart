import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const bool isSender = bool.fromEnvironment('ITS_SENDER', defaultValue: false);
const String apiBase = 'https://104-207-90-135.sslip.io/api';
const Color red = Color(0xFFB51F32);
const Color silver = Color(0xFFD7D9DE);
const Color panel = Color(0xFF15171C);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  runApp(const ItsApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class ItsApp extends StatelessWidget {
  const ItsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: isSender ? 'ITS : MINE' : 'ITS : MY',
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF090A0D),
      colorScheme: const ColorScheme.dark(primary: red, secondary: silver, surface: panel),
      useMaterial3: true,
    ),
    home: const ItsHome(),
  );
}

class ItsMessage {
  ItsMessage({required this.id, required this.senderUid, required this.body, required this.createdAt});
  final int id;
  final String senderUid;
  final String body;
  final String createdAt;
  factory ItsMessage.fromJson(Map<String, dynamic> j) => ItsMessage(
    id: (j['id'] as num).toInt(),
    senderUid: j['senderUid'] as String? ?? '',
    body: j['body'] as String? ?? '',
    createdAt: j['createdAt']?.toString() ?? '',
  );
}

class ItsHome extends StatefulWidget {
  const ItsHome({super.key});
  @override
  State<ItsHome> createState() => _ItsHomeState();
}

class _ItsHomeState extends State<ItsHome> {
  final _password = TextEditingController();
  final _composer = TextEditingController();
  final _scroll = ScrollController();
  String? _token;
  String? _installationId;
  String? _error;
  bool _busy = true;
  bool _sending = false;
  bool _paired = false;
  List<ItsMessage> _messages = [];
  Timer? _poller;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير يحليوه';
    if (h < 18) return 'نهارك سعيد يحليوه';
    return 'مساء الخير يحليوه';
  }

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<String> _getInstallationId(SharedPreferences prefs) async {
    var id = prefs.getString('its_installation_id');
    if (id != null && RegExp(r'^[a-f0-9]{64}$').hasMatch(id)) return id;
    final random = Random.secure();
    id = List.generate(32, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await prefs.setString('its_installation_id', id);
    return id;
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final installationId = await _getInstallationId(prefs);
      final token = prefs.getString('its_session_token');
      if (token != null && token.isNotEmpty) {
        _installationId = installationId;
        _token = token;
        final ok = await _refresh();
        if (ok) _startPolling();
        else {
          await prefs.remove('its_session_token');
          _token = null;
        }
      }
    } catch (_) {
      _error = 'تعذّر فحص الاتصال. تأكد من الإنترنت.';
    }
    if (mounted) setState(() => _busy = false);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<void> _login() async {
    final phrase = _password.text;
    if (phrase.trim().isEmpty) {
      setState(() => _error = 'اكتب عبارة الدخول.');
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = await _getInstallationId(prefs);
      final response = await http.post(
        Uri.parse('$apiBase/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'passphrase': phrase, 'role': isSender ? 'sender' : 'receiver', 'installationId': id}),
      ).timeout(const Duration(seconds: 20));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 200 || data['success'] != true) {
        final code = data['error'];
        if (code == 'slot_already_claimed') {
          throw Exception('هذا الدور مربوط بجهاز آخر. يلزم تحرير الجهاز القديم من الخادم.');
        }
        if (code == 'wrong_passphrase') throw Exception('عبارة الدخول غير صحيحة.');
        throw Exception('تعذّر تسجيل الدخول (${response.statusCode}).');
      }
      _installationId = id;
      _token = data['token'] as String;
      await prefs.setString('its_session_token', _token!);
        try {
          await FirebaseMessaging.instance.requestPermission();
          final fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            final r = await http.post(
              Uri.parse('$apiBase/device-token'),
              headers: _headers,
              body: jsonEncode({'token': fcmToken}),
            );
            debugPrint('FCM registration: ${r.statusCode}');
          }
        } catch (e) {
          debugPrint('FCM error: $e');
        }
      _password.clear();
      await _refresh();
      _startPolling();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<bool> _refresh() async {
    if (_token == null) return false;
    try {
      final statusResponse = await http.get(Uri.parse('$apiBase/status'), headers: _headers).timeout(const Duration(seconds: 12));
      if (statusResponse.statusCode != 200) return false;
      final status = jsonDecode(statusResponse.body) as Map<String, dynamic>;
      _paired = status['paired'] == true;
      final response = await http.get(Uri.parse('$apiBase/messages?after=0'), headers: _headers).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _paired = data['paired'] == true;
        final list = (data['messages'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        _messages = list.map(ItsMessage.fromJson).toList();
      }
      if (mounted) setState(() {});
      return true;
    } catch (_) {
      return false;
    }
  }

  void _startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  Future<void> _sendMessage() async {
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() { _sending = true; _error = null; });
    try {
      final response = await http.post(Uri.parse('$apiBase/messages'), headers: _headers, body: jsonEncode({'body': text})).timeout(const Duration(seconds: 20));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201 || data['success'] != true) {
        if (data['error'] == 'receiver_not_connected') throw Exception('تطبيق الاستقبال لم يتصل بعد.');
        throw Exception('تعذّر إرسال الرسالة (${response.statusCode}).');
      }
      _composer.clear();
      await _refresh();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    if (mounted) setState(() => _sending = false);
  }

  Future<void> _logoutLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('its_session_token');
    _poller?.cancel();
    setState(() { _token = null; _messages = []; _paired = false; });
  }

  @override
  void dispose() {
    _poller?.cancel();
    _password.dispose();
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isSender ? '♛ 𝐈𝐓𝐒 : MINE ♛' : '#¹♥ 𝐈𝐓𝐒 : MY ♕︎.';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090A0D),
        centerTitle: true,
        title: Text(title, style: const TextStyle(color: silver, fontWeight: FontWeight.w700, letterSpacing: 1.0, fontSize: 17)),
        actions: [if (_token != null) IconButton(onPressed: _logoutLocal, tooltip: 'خروج من هذا الجهاز', icon: const Icon(Icons.logout, color: silver))],
      ),
      body: SafeArea(child: _busy
        ? const Center(child: CircularProgressIndicator(color: red))
        : _token == null ? _loginView() : _chatView()),
    );
  }

  Widget _loginView() => ListView(padding: const EdgeInsets.all(22), children: [
    const SizedBox(height: 50),
    const Icon(Icons.lock_outline, size: 54, color: red),
    const SizedBox(height: 20),
    const Text('مساحة خاصة', textAlign: TextAlign.center, style: TextStyle(color: silver, fontSize: 24, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(isSender ? 'تطبيق الإرسال' : 'تطبيق الاستقبال', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
    const SizedBox(height: 28),
    TextField(
      controller: _password, obscureText: true, autocorrect: false, enableSuggestions: false,
      decoration: InputDecoration(labelText: 'عبارة الدخول', hintText: 'اكتب عبارة الدخول', filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
      onSubmitted: (_) => _login(),
    ),
    const SizedBox(height: 16),
    FilledButton(onPressed: _busy ? null : _login, style: FilledButton.styleFrom(backgroundColor: red, padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('دخول')),
    if (_error != null) ...[const SizedBox(height: 14), Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFF8794)))],
    const SizedBox(height: 22),
    const Text('يُسمح بجهاز واحد للإرسال وجهاز واحد للاستقبال.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
  ]);

  Widget _chatView() => Column(children: [
    Container(
      width: double.infinity, margin: const EdgeInsets.fromLTRB(18, 14, 18, 12), padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF252830), Color(0xFF111318)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF555962).withOpacity(.55))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(isSender ? 'مساحة الإرسال' : _greeting, style: const TextStyle(color: silver, fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 7),
        Text(isSender ? 'أرسل رسالة نصية إلى جهاز الاستقبال.' : 'احبج', style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 12),
        Row(children: [Icon(Icons.circle, color: _paired ? Colors.greenAccent : red, size: 9), const SizedBox(width: 8), Text(_paired ? 'متصل بالجهاز الآخر' : 'بانتظار اتصال الجهاز الآخر', style: const TextStyle(color: Colors.white70, fontSize: 12))]),
      ]),
    ),
    Expanded(child: !_paired
      ? Center(child: Padding(padding: const EdgeInsets.all(30), child: Text(isSender ? 'افتح تطبيق ITS : MY وسجّل الدخول بعبارة الدخول نفسها.' : 'افتح تطبيق ITS : MINE وسجّل الدخول بعبارة الدخول نفسها.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, height: 1.6))))
      : _messages.isEmpty
        ? const Center(child: Text('ماكو رسائل حالياً', style: TextStyle(color: Colors.white60)))
        : ListView.builder(controller: _scroll, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), itemCount: _messages.length, itemBuilder: (context, i) {
            final m = _messages[i];
            final mine = m.senderUid == _installationId;
            return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: Container(
              constraints: const BoxConstraints(maxWidth: 310), margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
              decoration: BoxDecoration(color: mine ? const Color(0xFF3B1821) : panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: mine ? red.withOpacity(.6) : const Color(0xFF343840))),
              child: Text(m.body, style: const TextStyle(color: silver, fontSize: 15)),
            ));
          })),
    if (isSender) Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 10), child: Row(children: [
      Expanded(child: TextField(controller: _composer, minLines: 1, maxLines: 4, textInputAction: TextInputAction.newline, decoration: InputDecoration(hintText: 'اكتب رسالة...', filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18))))),
      const SizedBox(width: 8),
      IconButton.filled(onPressed: _sending || !_paired ? null : _sendMessage, style: IconButton.styleFrom(backgroundColor: red), icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send)),
    ])),
    if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8794), fontSize: 12))),
    Padding(padding: const EdgeInsets.only(bottom: 12, top: 4), child: Text('ITS  •  PRIVATE SPACE', style: TextStyle(color: Colors.white.withOpacity(.35), letterSpacing: 2, fontSize: 10))),
  ]);
}
