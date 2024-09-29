import 'package:clap_to_find/widgets/home/shakes/shakes_screen.dart';
import 'package:clap_to_find/widgets/home/touchmyphone/touch_phone_screen.dart';
import 'package:clap_to_find/widgets/home/voicepasscode/voice_passcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';
import 'package:clap_to_find/widgets/home/clap/clap_detection_screen.dart';
import 'package:clap_to_find/widgets/home/setting/setting_screen.dart';
import 'package:clap_to_find/utils/style_configs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateAndShowAd(BuildContext context, Widget screen) async {
    ZergAndroidPlugin.showIntersAd(
      onFinished: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 1));
    if (!Navigator.canPop(context)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 241, 241, 241),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hello".tr),
            Text("Have a nice day".tr),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingScreen()),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                  bottom: 60, left: 20, right: 20, top: 15),
              children: [
                _buildBoxDecoration(
                  context,
                  'Clap'.tr,
                  'Clap or whistle to find'.tr,
                  ClapDetectionScreen(),
                ),
                _buildBoxDecoration(
                  context,
                  'Voice passcode'.tr,
                  'Voice to find phone'.tr,
                  const VoicePasscodeScreen(
                    passcodeText: '',
                  ),
                ),
                _buildBoxDecoration(
                  context,
                  'Pocket Anti-Theft'.tr,
                  'Anti theft alarm'.tr,
                  ShakesScreen(),
                ),
                _buildBoxDecoration(
                  context,
                  'Do not touch my phone'.tr,
                  'Leave my phone alone'.tr,
                  TouchPhoneScreen(),
                ),
              ],
            ),
          ),
          ZergAndroidPlugin.getCollapsibleBannerView(
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }

  Widget _buildBoxDecoration(
    BuildContext context,
    String title,
    String description,
    Widget screen,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      width: double.infinity,
      height: 148,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: mainColor,
                          width: 4,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: mainColor,
                    ),
                    onPressed: () {
                      _navigateAndShowAd(context, screen);
                    },
                    child: Text('Open'.tr),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 100,
            top: MediaQuery.of(context).size.width / 7 - 100,
            bottom: 0,
            right: 0,
            child: ClipPath(
              clipper: QuarterCircleClipper(),
              child: Container(
                width: 200,
                color: mainColor,
                child: Transform.translate(
                  offset: const Offset(110, 110),
                  child: Image.asset('assets/votay.png'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuarterCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, size.height / 2);
    path.arcToPoint(
      Offset(size.width / 2, size.height),
      radius: Radius.circular(size.width / 2),
      clockwise: false,
    );
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
