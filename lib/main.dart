import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:timeago_flutter/timeago_flutter.dart' as timeago;

import 'package:tom_chat/controllers/firebase_controller.dart';
import 'package:tom_chat/controllers/general_controller.dart';
import 'package:tom_chat/controllers/socket_manager.dart';
import 'package:tom_chat/core/db/call_server_api.dart';
import 'package:tom_chat/core/helpers/secure_storage.dart';
import 'package:tom_chat/core/theme/theme.dart';
import 'package:tom_chat/core/utils/my_math.dart';
import 'package:tom_chat/core/utils/swip_page.dart';
import 'package:tom_chat/core/widgets/logo.dart';
import 'package:tom_chat/core/widgets/svga_viewer.dart';
import 'package:tom_chat/features/agency/models/agency_model.dart';
import 'package:tom_chat/features/entry/controllers/entry_controller.dart';
import 'package:tom_chat/features/entry/entry_screen.dart';
import 'package:tom_chat/features/entry/signup.dart';
import 'package:tom_chat/features/home/controllers/home_controller.dart';
import 'package:tom_chat/features/home/home_sceren.dart';
import 'package:tom_chat/features/rooms/gifts/all_app_gift.dart';
import 'package:tom_chat/features/rooms/keep_room.dart';
import 'package:tom_chat/firebase_options.dart';
import 'package:tom_chat/l10n/app_localizations.dart';
import 'package:tom_chat/l10n/l10n.dart';
import 'package:tom_chat/models/user/user_model.dart';
import 'package:tom_chat/statics_values.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class TextTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ar': {},
    'en': {},
    'es': {},
    'fr': {},
    'hi': {},
    'id': {},
    'tr': {},
    'ur': {},
    'de': {},
    'it': {},
    'ku': {},
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  final signIn = GoogleSignIn.instance;

  await signIn.initialize(
    serverClientId:
        "310234338475-ome2anq61qb8duqish6op85p0bh89brj.apps.googleusercontent.com",
  );

  MessagingConfig.initFirebaseMessaging();
  FirebaseMessaging.onBackgroundMessage(MessagingConfig.messageHandler);

  await GetStorage.init();
  GetStorage().writeIfNull('darkMode', false);

  timeago.setLocaleMessages('en', MyCustomMessages());
  timeago.setLocaleMessages('ar', MyCustomMessages());

  String lang =
      GetStorage().read("lang") ?? Get.deviceLocale?.languageCode ?? "en";
  if (!TextTranslations().keys.containsKey(lang)) {
    lang = "en";
  }
  // debugPaintSizeEnabled = true;
  runApp(TomChatApp(lang: lang));
  WakelockPlus.enable();
}

class TomChatApp extends StatelessWidget {
  final String lang;
  const TomChatApp({super.key, required this.lang});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 716),
      minTextAdapt: true,
      splitScreenMode: true,
      rebuildFactor: RebuildFactors.none, // ✅ مهم
      builder: (context, child) {
        return GetMaterialApp(
          translations: TextTranslations(),
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: "AppChat",
          locale: Locale(lang),
          themeMode: ThemeMode.dark,
          theme: AppTheme.darkTheme(),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            KurdishMaterialLocalizationsDelegate(),
          ],
          fallbackLocale: const Locale("ar"),
          supportedLocales: AppLocalizations.supportedLocales,
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
                if (locale != null) {
                  for (final supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale.languageCode) {
                      return supportedLocale;
                    }
                  }
                }
                return supportedLocales.first;
              },
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.0)),
              child: Stack(
                children: [
                  widget!,
                  IgnorePointer(ignoring: true, child: GeneralSvga()),

                  RoomDraggableWidget(),
                  AllAppGifts(),
                ],
              ),
            );
          },
          home: child,
        );
      },
      child: SplashScreen(fromSettings: false),
    );
  }
}

class GeneralSvga extends StatefulWidget {
  const GeneralSvga({super.key});

  @override
  State<GeneralSvga> createState() => _GeneralSvgaState();
}

class _GeneralSvgaState extends State<GeneralSvga> {
  HomeController controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.receivedGiftAnimation.value?.giftAnimation?.network ==
          null) {
        return const SizedBox.shrink();
      }
      return SafeArea(
        top: false,
        child: SvgaViwer(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          networkSvga:
              controller.receivedGiftAnimation.value!.giftAnimation!.network!,
          repeated: false,
          count: controller.receivedGiftAnimation.value!.count,
          onFinish: () async {
            await controller.removeCurrentGiftAnimation();
          },
        ),
      );
    });
  }
}

class SplashScreen extends StatefulWidget {
  final bool fromSettings;
  const SplashScreen({super.key, required this.fromSettings});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future? myFun;

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) {
    //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //       systemNavigationBarDividerColor: Theme.of(Get.context!).primaryColor,
    //       systemNavigationBarColor: Theme.of(Get.context!).primaryColor,
    //       systemNavigationBarIconBrightness: Brightness.light));
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      myFun = initialize();
    });
  }

  Future? initialize() async {
    final storage = FlutterSecureStorage();
    try {
      Get.put(GeneralController(), permanent: true);

      String? value = await storage.read(key: "user");
      Map<String, dynamic>? u = value == null ? null : json.decode(value);

      if (widget.fromSettings) {
        Get.deleteAll();
      }

      if (u != null) {
        StaticValue.userData = UserModel.fromMap(u);
        StaticValue.userData.deviceId = await getDeviceId();

        if(await loginByToken()){
          return;
        }
      }
    } catch (_) {
      storage.delete(key: "user");
    }
    Get.offAll(() => EntryScreen());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: myFun,
      builder: (context, snapshot) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            titleSpacing: 0,
            toolbarHeight: 0,
            elevation: 0,
            primary: false,
            // forceMaterialTransparency: true,
            systemOverlayStyle: SystemUiOverlayStyle(
              // statusBarColor: Colors.red,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.light,
            ),
          ),
          body: Stack(
            children: [Logo(isExpanded: false, height: double.infinity)],
          ),
        );
      },
    );
  }
}

// my_custom_messages.dart
class MyCustomMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) {
    if (seconds < 0) {
      double minutes = (seconds * -1) / 60;
      if (minutes < 180) {
        return "${Get.context!.l10n.after} ${minutes.toStringAsFixed(0)} ${Get.context!.l10n.minte}";
      }
      double hours = (seconds * -1) / 60 / 60;
      if (hours < 24) {
        return "${Get.context!.l10n.after} ${hours.toStringAsFixed(0)} ${Get.context!.l10n.hour}";
      }
      double days = (seconds * -1) / 60 / 60 / 24;
      return "${Get.context!.l10n.after} ${days.toStringAsFixed(0)} ${Get.context!.l10n.day}";
    }

    return "${Get.context!.l10n.before} ${Get.context!.l10n.now}";
  }

  @override
  String aboutAMinute(int minutes) =>
      "${Get.context!.l10n.before} ${Get.context!.l10n.minte}";
  @override
  String minutes(int minutes) =>
      '${Get.context!.l10n.before}  $minutes ${Get.context!.l10n.minutes}';
  @override
  String aboutAnHour(int minutes) =>
      "${Get.context!.l10n.before} ${Get.context!.l10n.hour}";
  @override
  String hours(int hours) =>
      '${Get.context!.l10n.before}  $hours ${Get.context!.l10n.hours}';
  @override
  String aDay(int hours) =>
      "${Get.context!.l10n.before} ${Get.context!.l10n.day}";
  @override
  String days(int days) =>
      '${Get.context!.l10n.before}  $days ${Get.context!.l10n.day}';
  @override
  String aboutAMonth(int days) =>
      "${Get.context!.l10n.before} ${Get.context!.l10n.month}";
  @override
  String months(int months) =>
      '${Get.context!.l10n.before}  $months ${Get.context!.l10n.month}';
  @override
  String aboutAYear(int year) =>
      "${Get.context!.l10n.before} ${Get.context!.l10n.year}";
  @override
  String years(int years) =>
      '${Get.context!.l10n.before} $years ${Get.context!.l10n.years}';
  @override
  String wordSeparator() => ' ';
}

userFirstRoute(Map<String, dynamic> res) async {
  if (StaticValue.userData.pos == UserPosition.notCompleted) {
    Get.put(EntryController());
    swipReplacementPage(Get.context!, SignupScreen());
  } else {
    try {
      StaticValue.webToken = StaticValue.userData.webToken;
      if (res.isNotEmpty) {
        if (res["user"]?["guild"] != null) {
          StaticValue.agency = AgencyModel.fromMap(res["user"]?["guild"]);
        }
        if (res["user"]?["guildRequest"]?["guild"] != null) {
          StaticValue.agencyRequest = AgencyModel.fromMap(
            res["user"]?["guildRequest"]["guild"],
          );
        }
      }
    } catch (e) {}
    SocketManager.instance.init(
      res["socket_ip"] ?? "104.207.90.135",
      MyMath.toInt(res["socket_port"], defaultVal: 65535),
    );
    final storage = FlutterSecureStorage();
    await storage.write(key: "user", value: StaticValue.userData.toJson());
    await saveCurrentLocalUserToList();
    Get.offAll(() => HomeSceren(comeFromEntry: true));
  }
}

saveCurrentLocalUserToList() async {
  SecureUsersStore secureUsersStore = SecureUsersStore();
  await secureUsersStore.upsertUser(
    StoredUser(
      deviceID: StaticValue.userData.deviceId ?? "",
      id: StaticValue.userData.userId.toString(),
      token: StaticValue.userData.userToken!,
      profilePic: StaticValue.userData.avatar?.network,
      name: StaticValue.userData.name,
    ),
  );
  await secureUsersStore.setActiveUser(StaticValue.userData.userId.toString());
}

class KurdishMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const KurdishMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return GlobalMaterialLocalizations.delegate.load(const Locale('tr'));
  }

  @override
  bool shouldReload(KurdishMaterialLocalizationsDelegate old) => false;
}

Future<bool> loginByToken() async{
  var res = await CallServerAPI.post(
    "auth/tokenLogin",
    {},
    withMessage: false,
  );
  if (res.isNotEmpty && res["user"] != null) {
    StaticValue.userData = UserModel.fromMap(res["user"]).copyWith(
      userToken: StaticValue.userData.userToken,
      appPrefix: StaticValue.userData.appPrefix,
    );
    await userFirstRoute(res);
    return true;
  }
  return false;
}