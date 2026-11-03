import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_service/audio_service.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:record/record.dart';

const bool isSender = bool.fromEnvironment('ITS_SENDER', defaultValue: false);
const String apiBase = 'https://104-207-90-135.sslip.io/api';
const String appVersion = '1.2.0';
const Color red = Color(0xFFD5B77A); // restrained champagne-gold accent
const Color silver = Color(0xFFE1E3E8);
const Color panel = Color(0xFF121316);
AudioPlayer? _itsSharedAudioPlayer;
AudioPlayer get itsSharedAudioPlayer => _itsSharedAudioPlayer ??= AudioPlayer();
String? itsLoadedAudioUrl;
bool firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  } catch (e, stack) {
    debugPrint('Firebase unavailable; opening app without push notifications: $e');
    debugPrintStack(stackTrace: stack);
  }
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.mahdi.nabdqalbi.audio',
      androidNotificationChannelName: 'ITS Music',
      androidNotificationOngoing: true,
    );
  } catch (e, stack) {
    debugPrint('Background audio initialization failed: $e');
    debugPrintStack(stackTrace: stack);
  }
  runApp(const ItsApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase background initialization failed: $e');
  }
}

class ItsApp extends StatelessWidget {
  const ItsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: isSender ? '♛ 𝐈𝐓𝐒 : MINE ♛' : '#¹♥ 𝐈𝐓𝐒 : MY ♕︎.',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF050506),
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
  bool _isRecordingVoice = false;
  final AudioRecorder _voiceRecorder = AudioRecorder();
  bool _paired = false;
  List<ItsMessage> _messages = [];
  Timer? _poller;
  Timer? _configPoller;
  StreamSubscription<String>? _fcmRefreshSub;
  int _lastMessageId = 0;
  String _openingMessage = 'احبج';
  String _morningGreeting = 'صباح الخير يحليوه ❤️';
  String _musicLabel = '11:11 💍';
  String _senderName = '♛ 𝐈𝐓𝐒 : MINE ♛';
  String _receiverName = '#¹♥ 𝐈𝐓𝐒 : MY ♕︎.';
  String _latestVersion = appVersion;
  String _downloadUrl = '';
  bool _updateDialogShown = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
    _loadRemoteConfig();
    _configPoller = Timer.periodic(const Duration(minutes: 5), (_) => _loadRemoteConfig());
  }

  Future<String> _getInstallationId(SharedPreferences prefs) async {
    var id = prefs.getString('its_installation_id');
    if (id != null && RegExp(r'^[a-f0-9]{64}$').hasMatch(id)) return id;
    final random = Random.secure();
    id = List.generate(32, (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    await prefs.setString('its_installation_id', id);
    return id;
  }

  Future<void> _loadRemoteConfig() async {
    try {
      final response = await http.get(Uri.parse('$apiBase/app-config')).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final c = (data['config'] as Map<String, dynamic>?) ?? {};
      if (!mounted) return;
      setState(() {
        _openingMessage = (c['openingMessage'] as String?)?.trim().isNotEmpty == true ? c['openingMessage'] as String : 'احبج';
        _morningGreeting = (c['morningGreeting'] as String?)?.trim().isNotEmpty == true ? c['morningGreeting'] as String : 'صباح الخير يحليوه ❤️';
        _musicLabel = (c['musicLabel'] as String?)?.trim().isNotEmpty == true ? c['musicLabel'] as String : '11:11 💍';
        _senderName = (c['senderName'] as String?)?.trim().isNotEmpty == true ? c['senderName'] as String : '♛ 𝐈𝐓𝐒 : MINE ♛';
        _receiverName = (c['receiverName'] as String?)?.trim().isNotEmpty == true ? c['receiverName'] as String : '#¹♥ 𝐈𝐓𝐒 : MY ♕︎.';
        _latestVersion = (c['latestVersion'] as String?) ?? appVersion;
        _downloadUrl = (c['downloadUrl'] as String?) ?? '';
      });
      _maybeShowUpdate();
    } catch (e) {
      debugPrint('Remote configuration unavailable: $e');
    }
  }

  bool _hasNewerVersion() {
    List<int> parts(String value) => value.split('.').map((x) => int.tryParse(x) ?? 0).toList();
    final current = parts(appVersion);
    final latest = parts(_latestVersion);
    for (var i = 0; i < (current.length > latest.length ? current.length : latest.length); i++) {
      final a = i < current.length ? current[i] : 0;
      final b = i < latest.length ? latest[i] : 0;
      if (b > a) return true;
      if (b < a) return false;
    }
    return false;
  }

  void _maybeShowUpdate() {
    if (_updateDialogShown || !_hasNewerVersion() || !_downloadUrl.startsWith('https://')) return;
    _updateDialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: panel,
          title: const Text('تحديث جديد متوفر'),
          content: Text('الإصدار $_latestVersion جاهز. افتح صفحة التحميل لتثبيته.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('لاحقاً')),
            FilledButton(onPressed: () async {
              Navigator.pop(dialogContext);
              final uri = Uri.tryParse(_downloadUrl);
              if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
            }, child: const Text('فتح التحديث')),
          ],
        ),
      );
    });
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
        if (ok) {
          _startPolling();
          await _registerFcmToken();
        } else {
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

  Future<void> _registerFcmToken() async {
    if (!firebaseReady || _token == null) return;
    try {
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) await _postFcmToken(fcmToken);
      _fcmRefreshSub ??= FirebaseMessaging.instance.onTokenRefresh.listen((value) => _postFcmToken(value));
    } catch (e) {
      debugPrint('FCM registration error: $e');
    }
  }

  Future<void> _postFcmToken(String value) async {
    if (_token == null) return;
    try {
      await http.post(
        Uri.parse('$apiBase/device-token'),
        headers: _headers,
        body: jsonEncode({'token': value}),
      ).timeout(const Duration(seconds: 12));
    } catch (e) {
      debugPrint('FCM token post failed: $e');
    }
  }

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
        if (data['error'] == 'wrong_passphrase') throw Exception('عبارة الدخول غير صحيحة.');
        throw Exception('تعذّر تسجيل الدخول (${response.statusCode}).');
      }
      _installationId = id;
      _token = data['token'] as String;
      await prefs.setString('its_session_token', _token!);
      _password.clear();
      await _registerFcmToken();
      _lastMessageId = 0;
      _messages.clear();
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
      final response = await http.get(Uri.parse('$apiBase/messages?after=$_lastMessageId'), headers: _headers).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        _paired = data['paired'] == true;
        final list = (data['messages'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
        for (final raw in list) {
          final message = ItsMessage.fromJson(raw);
          if (_messages.every((old) => old.id != message.id)) _messages.add(message);
          if (message.id > _lastMessageId) _lastMessageId = message.id;
        }
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

  Future<void> _sendMessageBody(String body, {bool lockAlreadyHeld = false}) async {
    if ((_sending && !lockAlreadyHeld) || !_paired || _token == null) return;
    if (!lockAlreadyHeld) setState(() { _sending = true; _error = null; });
    try {
      final response = await http.post(
        Uri.parse('$apiBase/messages'),
        headers: _headers,
        body: jsonEncode({'body': body}),
      ).timeout(const Duration(seconds: 30));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode != 201 || data['success'] != true) {
        if (data['error'] == 'receiver_not_connected') throw Exception('تطبيق الاستقبال غير متصل بعد.');
        throw Exception('تعذّر الإرسال (${response.statusCode}).');
      }
      _composer.clear();
      await _refresh();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!lockAlreadyHeld && mounted) setState(() => _sending = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _composer.text.trim();
    if (text.isNotEmpty) await _sendMessageBody(text);
  }

  String? _mimeFor(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg': case 'jpeg': return 'image/jpeg';
      case 'png': return 'image/png';
      case 'webp': return 'image/webp';
      case 'mp4': return 'video/mp4';
      case 'mov': return 'video/quicktime';
      case 'mp3': return 'audio/mpeg';
      case 'm4a': return 'audio/mp4';
      case 'aac': return 'audio/aac';
      case 'wav': return 'audio/wav';
      case 'ogg': return 'audio/ogg';
      default: return null;
    }
  }

  Future<void> _showAttachmentOptions() async {
    if (_sending || !_paired || !isSender) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111214),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(8))),
              const SizedBox(height: 18),
              const Text('إرسال مرفق', style: TextStyle(color: silver, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _attachmentChoice(sheetContext, Icons.image_outlined, 'صورة', const ['jpg', 'jpeg', 'png', 'webp'])),
                const SizedBox(width: 10),
                Expanded(child: _attachmentChoice(sheetContext, Icons.videocam_outlined, 'فيديو', const ['mp4', 'mov'])),
                const SizedBox(width: 10),
                Expanded(child: _attachmentChoice(sheetContext, Icons.music_note, 'أغنية', const ['mp3', 'm4a', 'aac', 'wav', 'ogg'])),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _attachmentChoice(BuildContext sheetContext, IconData icon, String label, List<String> extensions) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pop(sheetContext);
        _pickAndSendMedia(extensions: extensions);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 6),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: red.withOpacity(.65)),
        ),
        child: Column(children: [Icon(icon, color: silver, size: 28), const SizedBox(height: 8), Text(label, style: const TextStyle(color: silver, fontWeight: FontWeight.w600))]),
      ),
    );
  }

  Future<void> _pickAndSendMedia({required List<String> extensions}) async {
    if (_sending || !_paired || !isSender) return;
    try {
      final files = await FilePicker.pickFiles(type: FileType.custom, allowedExtensions: extensions);
      if (files.isEmpty) return;
      final file = files.single;
      final bytes = await file.readAsBytes();
      final ext = (file.extension ?? '').toLowerCase();
      final mime = _mimeFor(ext);
      if (bytes.isEmpty || mime == null) throw Exception('صيغة الملف غير مدعومة.');
      await _uploadAndSendMedia(bytes, file.name, ext, mime);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _uploadAndSendMedia(List<int> bytes, String name, String ext, String mime) async {
    if (_sending || !_paired || _token == null || !isSender) return;
    if (bytes.isEmpty) throw Exception('الملف فارغ.');
    if (bytes.length > 256 * 1024 * 1024) throw Exception('حجم الملف أكبر من 256 ميغابايت.');
    setState(() { _sending = true; _error = null; });
    try {
      final encodedName = base64Url.encode(utf8.encode(name));
      final upload = await http.post(
        Uri.parse('$apiBase/media'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': mime,
          'X-File-Name': encodedName,
        },
        body: bytes,
      ).timeout(const Duration(minutes: 5));
      final uploadData = jsonDecode(upload.body) as Map<String, dynamic>;
      if (upload.statusCode != 201 || uploadData['success'] != true) {
        throw Exception('فشل رفع الملف (${upload.statusCode}).');
      }
      final mediaUrl = uploadData['url'] as String;
      final kind = uploadData['kind'] as String;
      await _sendMessageBody('ITS_MEDIA:${jsonEncode({'kind': kind, 'url': mediaUrl, 'name': name})}', lockAlreadyHeld: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _toggleVoiceRecording() async {
    if (_sending || !_paired || !isSender) return;
    if (_isRecordingVoice) {
      try {
        final path = await _voiceRecorder.stop();
        if (mounted) setState(() => _isRecordingVoice = false);
        if (path == null) return;
        final recorded = File(path);
        final bytes = await recorded.readAsBytes();
        await _uploadAndSendMedia(bytes, 'بصمة صوت.m4a', 'm4a', 'audio/mp4');
        try { await recorded.delete(); } catch (_) {}
      } catch (e) {
        if (mounted) setState(() { _isRecordingVoice = false; _error = e.toString().replaceFirst('Exception: ', ''); });
      }
      return;
    }
    try {
      final permitted = await _voiceRecorder.hasPermission();
      if (!permitted) throw Exception('اسمح للتطبيق باستخدام المايك حتى تسجل بصمة صوت.');
      final path = '${Directory.systemTemp.path}/its-voice-${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _voiceRecorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      if (mounted) setState(() { _isRecordingVoice = true; _error = null; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showCallNotice() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text('المكالمة الصوتية', style: TextStyle(color: silver)),
        content: const Text('زر المكالمة مضاف للواجهة، لكن الاتصال الصوتي المباشر يحتاج خدمة مكالمات وإشارات WebRTC على السيرفر. هذه الخدمة غير موجودة حالياً، لذلك لن أظهرها على أنها تعمل قبل تجهيزها.', style: TextStyle(color: Colors.white70, height: 1.5)),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('حسناً'))],
      ),
    );
  }

  Future<void> _logoutLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('its_session_token');
    _poller?.cancel();
    setState(() { _token = null; _messages = []; _lastMessageId = 0; _paired = false; });
  }

  Widget _messageContent(ItsMessage message) {
    if (!message.body.startsWith('ITS_MEDIA:')) {
      return Text(message.body, style: const TextStyle(color: silver, fontSize: 15));
    }
    try {
      final data = jsonDecode(message.body.substring('ITS_MEDIA:'.length)) as Map<String, dynamic>;
      final kind = data['kind']?.toString() ?? '';
      final url = data['url']?.toString() ?? '';
      final name = data['name']?.toString() ?? 'ملف';
      if (url.isEmpty) throw const FormatException('Missing media URL');
      if (kind == 'image') {
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => FullImagePage(url: url))),
          child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(url, width: 230, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Text('تعذّر تحميل الصورة'))),
        );
      }
      if (kind == 'audio') return ItsAudioTile(url: url, name: name, label: _musicLabel);
      if (kind == 'video') {
        return InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItsVideoPage(url: url, name: name))),
          child: Container(width: 230, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF262932), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.play_circle_fill, color: red, size: 34), const SizedBox(width: 10), Expanded(child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: silver)))])),
        );
      }
    } catch (e) {
      debugPrint('Invalid media message: $e');
    }
    return const Text('مرفق غير صالح', style: TextStyle(color: Colors.white70));
  }

  @override
  void dispose() {
    _poller?.cancel();
    _configPoller?.cancel();
    _fcmRefreshSub?.cancel();
    _password.dispose();
    _composer.dispose();
    _scroll.dispose();
    if (_isRecordingVoice) { unawaited(_voiceRecorder.cancel()); }
    unawaited(_voiceRecorder.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isSender ? _senderName : _receiverName;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090A0D),
        centerTitle: true,
        title: Text(title, style: const TextStyle(color: silver, fontWeight: FontWeight.w700, letterSpacing: .4, fontSize: 16)),
        actions: [
          if (_token != null && isSender) IconButton(onPressed: _paired ? _showCallNotice : null, tooltip: 'مكالمة', icon: const Icon(Icons.call_outlined, color: silver)),
          if (_token != null) IconButton(onPressed: _logoutLocal, tooltip: 'خروج', icon: const Icon(Icons.logout, color: silver)),
        ],
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
        const Text('اتصال خاص عبر الإنترنت', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
      ]);

  Widget _chatView() => Column(children: [
        Container(
          width: double.infinity, margin: const EdgeInsets.fromLTRB(18, 14, 18, 12), padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF252830), Color(0xFF111318)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF555962).withOpacity(.55))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isSender ? 'مساحة الإرسال' : _openingMessage, style: const TextStyle(color: silver, fontSize: 21, fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            Text(isSender ? 'أرسل رسالة أو صورة أو فيديو أو بصمة صوت أو أغنية.' : 'مساحة الاستقبال الخاصة', style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 12),
            Row(children: [Icon(Icons.circle, color: _paired ? Colors.greenAccent : red, size: 9), const SizedBox(width: 8), Text(_paired ? 'متصل بالخادم' : 'بانتظار اتصال الطرف الآخر', style: const TextStyle(color: Colors.white70, fontSize: 12))]),
          ]),
        ),
        Expanded(child: !_paired
            ? Center(child: Padding(padding: const EdgeInsets.all(30), child: Text(isSender ? 'سجّل الدخول بتطبيق الاستقبال على الجهاز الآخر.' : 'سجّل الدخول بتطبيق الإرسال على الجهاز الآخر.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, height: 1.6))))
            : _messages.isEmpty
                ? const Center(child: Text('ماكو رسائل حالياً', style: TextStyle(color: Colors.white60)))
                : ListView.builder(controller: _scroll, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), itemCount: _messages.length, itemBuilder: (context, i) {
                    final m = _messages[i];
                    final mine = m.senderUid == _installationId;
                    return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft, child: Container(
                      constraints: const BoxConstraints(maxWidth: 310), margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
                      decoration: BoxDecoration(color: mine ? const Color(0xFF211D15) : panel, borderRadius: BorderRadius.circular(16), border: Border.all(color: mine ? red.withOpacity(.6) : const Color(0xFF343840))),
                      child: _messageContent(m),
                    ));
                  })),
        if (isSender) ...[
          if (_isRecordingVoice) Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('جارٍ تسجيل بصمة الصوت — اضغط المايك للإرسال', style: TextStyle(color: red, fontSize: 12))),
          Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 10), child: Row(children: [
            IconButton(onPressed: _sending || !_paired ? null : _showAttachmentOptions, tooltip: 'إرفاق صورة أو فيديو أو أغنية', icon: const Icon(Icons.add_circle_outline, color: silver, size: 27)),
            Expanded(child: TextField(controller: _composer, minLines: 1, maxLines: 4, textInputAction: TextInputAction.newline, decoration: InputDecoration(hintText: 'اكتب رسالة...', filled: true, fillColor: panel, border: OutlineInputBorder(borderRadius: BorderRadius.circular(18))))),
            const SizedBox(width: 3),
            IconButton(onPressed: _sending || !_paired ? null : _toggleVoiceRecording, tooltip: _isRecordingVoice ? 'إيقاف وإرسال البصمة' : 'تسجيل بصمة صوت', icon: Icon(_isRecordingVoice ? Icons.stop_circle_outlined : Icons.mic_none, color: _isRecordingVoice ? Colors.redAccent : silver, size: 27)),
            IconButton.filled(onPressed: _sending || !_paired ? null : _sendMessage, style: IconButton.styleFrom(backgroundColor: red), icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send)),
          ])),
        ],
        if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: Color(0xFFFF8794), fontSize: 12))),
        Padding(padding: const EdgeInsets.only(bottom: 12, top: 4), child: Text('ITS  •  PRIVATE SPACE', style: TextStyle(color: Colors.white.withOpacity(.35), letterSpacing: 2, fontSize: 10))),
      ]);
}

class ItsAudioTile extends StatefulWidget {
  const ItsAudioTile({super.key, required this.url, required this.name, required this.label});
  final String url;
  final String name;
  final String label;
  @override
  State<ItsAudioTile> createState() => _ItsAudioTileState();
}

class _ItsAudioTileState extends State<ItsAudioTile> {
  String? _failure;
  Future<void> _togglePlayback() async {
    try {
      if (itsLoadedAudioUrl != widget.url) {
        await itsSharedAudioPlayer.setAudioSource(AudioSource.uri(
          Uri.parse(widget.url),
          tag: MediaItem(id: widget.url, album: 'ITS', title: widget.name),
        ));
        itsLoadedAudioUrl = widget.url;
        await itsSharedAudioPlayer.play();
      } else if (itsSharedAudioPlayer.playing) {
        await itsSharedAudioPlayer.pause();
      } else {
        if (itsSharedAudioPlayer.processingState == ProcessingState.completed) {
          await itsSharedAudioPlayer.seek(Duration.zero);
        }
        await itsSharedAudioPlayer.play();
      }
    } catch (e) {
      if (mounted) setState(() => _failure = 'تعذّر تشغيل الصوت');
      debugPrint('Audio playback failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox(width: 250, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.music_note, color: red), const SizedBox(width: 8), Expanded(child: Text(widget.label, style: const TextStyle(color: silver, fontWeight: FontWeight.bold))), StreamBuilder<PlayerState>(stream: itsSharedAudioPlayer.playerStateStream, builder: (context, snap) {
          final playingThis = itsLoadedAudioUrl == widget.url && snap.data?.playing == true;
          return IconButton(onPressed: _failure != null ? null : _togglePlayback, icon: Icon(playingThis ? Icons.pause_circle_filled : Icons.play_circle_fill, color: red, size: 32));
        })]),
        Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        if (_failure != null) Text(_failure!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        StreamBuilder<Duration?>(stream: itsSharedAudioPlayer.durationStream, builder: (context, durationSnap) {
          final duration = durationSnap.data ?? Duration.zero;
          return StreamBuilder<Duration>(stream: itsSharedAudioPlayer.positionStream, builder: (context, positionSnap) {
            final position = positionSnap.data ?? Duration.zero;
            final active = itsLoadedAudioUrl == widget.url;
            final maxValue = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity).toDouble();
            final value = (active ? position.inMilliseconds.toDouble() : 0.0).clamp(0.0, maxValue).toDouble();
            return Slider(value: value, max: maxValue, onChanged: !active || duration == Duration.zero ? null : (v) => itsSharedAudioPlayer.seek(Duration(milliseconds: v.round())), activeColor: red);
          });
        }),
      ]));
}

class FullImagePage extends StatelessWidget {
  const FullImagePage({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: Colors.black, appBar: AppBar(backgroundColor: Colors.black), body: Center(child: InteractiveViewer(child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Text('تعذّر تحميل الصورة')))));
}

class ItsVideoPage extends StatefulWidget {
  const ItsVideoPage({super.key, required this.url, required this.name});
  final String url;
  final String name;
  @override
  State<ItsVideoPage> createState() => _ItsVideoPageState();
}

class _ItsVideoPageState extends State<ItsVideoPage> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialize;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _initialize = _controller.initialize();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: Text(widget.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
        body: Center(child: FutureBuilder<void>(future: _initialize, builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const CircularProgressIndicator(color: red);
          if (snapshot.hasError) return const Text('تعذّر تشغيل الفيديو');
          return AspectRatio(aspectRatio: _controller.value.aspectRatio, child: Stack(alignment: Alignment.center, children: [
            VideoPlayer(_controller),
            IconButton.filled(onPressed: () async { if (_controller.value.isPlaying) { await _controller.pause(); } else { await _controller.play(); } if (mounted) setState(() {}); }, iconSize: 42, icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow)),
          ]));
        })),
      );
}
