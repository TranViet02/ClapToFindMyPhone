import 'package:clap_to_find/Widgets/home/homeScreen.dart';
import 'package:clap_to_find/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:clap_to_find/widgets/home/setting/language/locale_controller.dart';
import 'package:clap_to_find/widgets/home/setting/language/mytranslations.dart';
import 'package:clap_to_find/widgets/home/clap/clap_detection_screen.dart';
import 'package:clap_to_find/widgets/home/shakes/shakes_screen.dart';
import 'package:clap_to_find/widgets/home/voicepasscode/voice_passcode_screen.dart';
import 'package:clap_to_find/widgets/slapscreen/splash_screen.dart';
import 'package:zerg_android_plugin/services/ad_manager.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHadesSDK();
  ZergAndroidPlugin.showAOAIfAvailable();
  runApp(MyApp());
}

Future<void> initHadesSDK() async {
  ZergAndroidPlugin.initialize(
    firebaseOptions: DefaultFirebaseOptions.currentPlatform,
    isTestingAd: false,
    isNoAdBuild: false,
    adMediationType: AdMediationType.admob,
    adIdConfigs: AdIdConfigs(
      interAdId: 'ca-app-pub-2391704542767260/1676722057',
      bannerAdId: 'ca-app-pub-2391704542767260/6793317363',
      appOpenAdId: 'ca-app-pub-2391704542767260/8050558715',
      rewardedAdId: 'ca-app-pub-2391704542767260/2850202921',
      nativeAdId: 'ca-app-pub-2391704542767260/6466680581',
      collapsibleBannerId: 'ca-app-pub-2391704542767260/5476366263',
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: MyTranslations(),
      fallbackLocale: const Locale('en'),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashScreen()),
        GetPage(name: '/clapDetection', page: () => ClapDetectionScreen()),
        GetPage(name: '/vibration', page: () => ShakesScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(
            name: '/voicePassCode',
            page: () => const VoicePasscodeScreen(
                  passcodeText: '',
                )),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(LocaleController());
      }),
    );
  }
}
