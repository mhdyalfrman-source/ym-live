import 'package:flutter/material.dart';

const bool isSender = bool.fromEnvironment('ITS_SENDER', defaultValue: false);

void main() => runApp(const ItsApp());

class ItsApp extends StatelessWidget {
  const ItsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFB51F32);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: isSender ? 'ITS : MINE' : 'ITS : MY',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A0D),
        colorScheme: const ColorScheme.dark(
          primary: red,
          secondary: Color(0xFFC5C8CE),
          surface: Color(0xFF15171C),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: ItsHome(isSender: isSender),
    );
  }
}

class ItsHome extends StatelessWidget {
  const ItsHome({super.key, required this.isSender});
  final bool isSender;

  void _notConnected(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة تحتاج ربط الخادم وFirebase قبل تشغيلها.'),
        backgroundColor: Color(0xFF8E1B2B),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'صباح الخير يحليوه';
    if (hour < 18) return 'نهارك سعيد يحليوه';
    return 'مساء الخير يحليوه';
  }

  @override
  Widget build(BuildContext context) {
    final title = isSender ? '♛ 𝐈𝐓𝐒 : MINE ♛' : '#¹♥ 𝐈𝐓𝐒 : MY ♕︎.';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF090A0D),
        title: Text(title, style: const TextStyle(color: Color(0xFFD7D9DE), fontWeight: FontWeight.w700, letterSpacing: 1.1, fontSize: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(colors: [Color(0xFF252830), Color(0xFF111318)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                border: Border.all(color: const Color(0xFF555962).withOpacity(.55)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isSender ? 'مساحة الإرسال' : _greeting(), style: const TextStyle(fontSize: 22, color: Color(0xFFE2E3E7), fontWeight: FontWeight.bold)),
                const SizedBox(height: 9),
                Text(isSender ? 'أرسل رسالة أو وسائط بعد ربط الخادم.' : 'احبج', style: const TextStyle(fontSize: 17, color: Color(0xFFB7BBC3))),
                const SizedBox(height: 16),
                const Row(children: [Icon(Icons.circle, color: Color(0xFFB51F32), size: 9), SizedBox(width: 8), Text('بانتظار ربط الخادم', style: TextStyle(color: Color(0xFFB7BBC3), fontSize: 12))]),
              ]),
            ),
            const SizedBox(height: 22),
            if (isSender) ...[
              const _SectionTitle('إرسال'),
              const SizedBox(height: 12),
              _ActionTile(icon: Icons.chat_bubble_outline, title: 'رسالة', subtitle: 'إرسال رسالة نصية', onTap: () => _notConnected(context)),
              _ActionTile(icon: Icons.photo_outlined, title: 'صورة', subtitle: 'إرسال صورة', onTap: () => _notConnected(context)),
              _ActionTile(icon: Icons.videocam_outlined, title: 'فيديو', subtitle: 'إرسال مقطع فيديو', onTap: () => _notConnected(context)),
              _ActionTile(icon: Icons.music_note, title: 'أغنية', subtitle: 'إرسال ملف صوتي', onTap: () => _notConnected(context)),
            ] else ...[
              const _SectionTitle('الوارد'),
              const SizedBox(height: 12),
              const _EmptyState(),
            ],
            const SizedBox(height: 22),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _notConnected(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(color: const Color(0xFF17191F), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF9A2638), width: 1.1)),
                child: const Row(children: [
                  Icon(Icons.play_circle_outline, color: Color(0xFFCB3449), size: 34),
                  SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('11:11 💍', style: TextStyle(color: Color(0xFFE1E2E5), fontSize: 19, fontWeight: FontWeight.bold)), SizedBox(height: 4), Text('مشغل الموسيقى', style: TextStyle(color: Color(0xFF9DA1AA), fontSize: 12))])),
                  Icon(Icons.lock_outline, color: Color(0xFF777C86), size: 18),
                ]),
              ),
            ),
            const SizedBox(height: 18),
            const Center(child: Text('ITS  •  PRIVATE SPACE', style: TextStyle(color: Color(0xFF656A73), letterSpacing: 2, fontSize: 10))),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Color(0xFFC9CCD2), fontSize: 16, fontWeight: FontWeight.w700));
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      onTap: onTap,
      tileColor: const Color(0xFF15171C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF30343C))),
      leading: Icon(icon, color: const Color(0xFFBFC3CA), size: 25),
      title: Text(title, style: const TextStyle(color: Color(0xFFE0E2E6), fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF858A94), fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF777D87)),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: const Color(0xFF15171C), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF30343C))),
    child: const Column(children: [Icon(Icons.inbox_outlined, color: Color(0xFF777D87), size: 34), SizedBox(height: 10), Text('ماكو رسائل حالياً', style: TextStyle(color: Color(0xFFBEC2C9))), SizedBox(height: 5), Text('الرسائل والوسائط تظهر هنا بعد ربط الخادم', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF777D87), fontSize: 12))]),
  );
}
