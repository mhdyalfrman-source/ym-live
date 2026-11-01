import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/widgets/card_widget.dart';
import 'package:tom_chat/features/page_templete.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/statics_values.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const List<_LanguageOption> _languages = [
    _LanguageOption(code: 'ar', name: 'العربية', englishName: 'Arabic'),
    _LanguageOption(code: 'en', name: 'English', englishName: 'English'),
    _LanguageOption(code: 'fr', name: 'Français', englishName: 'French'),
    _LanguageOption(code: 'es', name: 'Español', englishName: 'Spanish'),
    _LanguageOption(code: 'tr', name: 'Türkçe', englishName: 'Turkish'),
    _LanguageOption(
      code: 'id',
      name: 'Bahasa Indonesia',
      englishName: 'Indonesian',
    ),
    _LanguageOption(code: 'de', name: 'Deutsch', englishName: 'German'),
    _LanguageOption(code: 'it', name: 'Italiano', englishName: 'Italian'),
    _LanguageOption(code: 'ku', name: 'Kurdî', englishName: 'Kurdish'),
    _LanguageOption(code: 'hi', name: 'हिन्दी', englishName: 'Hindi'),
    _LanguageOption(code: 'ur', name: 'اردو', englishName: 'Urdu'),
  ];

  late String selectedCode;

  @override
  void initState() {
    super.initState();
    selectedCode =
        (Get.locale?.languageCode ?? GetStorage().read('lang') ?? 'ar')
            .toString();
  }

  Future<void> _selectLanguage(_LanguageOption language) async {
    if (selectedCode == language.code) {
      return;
    }

    final oldLanguage = selectedCode;
    setState(() => selectedCode = language.code);
    StaticValue.language = language.code;
    await GetStorage().write('lang', language.code);
    Get.updateLocale(Locale(language.code));

    CallServerAPI.post('auth/changlanguage', {
      'old_lang': oldLanguage,
      'lang': language.code,
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageTemplete(
      title: context.l10n.language,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        itemCount: _languages.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final language = _languages[index];
          final selected = selectedCode == language.code;
          return _LanguageTile(
            language: language,
            selected: selected,
            onTap: () => _selectLanguage(language),
          );
        },
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final _LanguageOption language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rtl = language.code == 'ar' || language.code == 'ur';
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        onTap: onTap,
        leading: CardWidget(
          shape: BoxShape.circle,
          colorIndex: selected ? 1 : 0,
          radius: 10,
          child: Padding(
            padding: EdgeInsets.all(8.r),
            child: Icon(
              HugeIcons.strokeRoundedLanguageCircle,
              color: Colors.white,
              size: 24.r,
            ),
          ),
        ),
        title: Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: Text(
            language.name,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Colors.black,
              fontFamily: 'cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        subtitle: Text(
          '${language.englishName} · ${language.code.toUpperCase()}',
          style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w100,
          ),
        ),
        trailing: Icon(
          selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded,
          color: selected
              ? Theme.of(context).primaryColorDark
              : Theme.of(context).dividerColor,
          size: 24.r,
        ),
      ),
    );
  }
}

class _LanguageOption {
  final String code;
  final String name;
  final String englishName;

  const _LanguageOption({
    required this.code,
    required this.name,
    required this.englishName,
  });
}
