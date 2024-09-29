import 'package:clap_to_find/widgets/home/setting/feedback/feedback_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:clap_to_find/widgets/home/setting/language/language_screen.dart';
import 'package:clap_to_find/widgets/home/setting/language/locale_controller.dart';
import 'package:launch_app_store/launch_app_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _currentVolume = 15000;
  final LocaleController localeController = Get.put(LocaleController());
  MethodChannel _channel = MethodChannel('clap_to_find');

  @override
  void initState() {
    super.initState();
    _loadClapDetectionThreshold();
  }

  Future<void> _loadClapDetectionThreshold() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedThreshold = prefs.getInt('clapDetectionThreshold') ?? 15000;
    setState(() {
      _currentVolume = savedThreshold.toInt();
    });
  }

  Future<void> _updateClapDetectionThreshold(int threshold) async {
    await _channel
        .invokeMethod('updateClapDetectionThreshold', {'threshold': threshold});

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('clapDetectionThreshold', threshold);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(253, 245, 243, 243),
      appBar: AppBar(
        title: Text('Setting'.tr),
        backgroundColor: const Color.fromARGB(253, 245, 243, 243),
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sensitive'.tr,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                            Slider(
                              value: _currentVolume.toDouble(),
                              min: 15000,
                              max: 15000 + 6000 * 4,
                              label: '${_currentVolume.round()}',
                              divisions: 3,
                              onChanged: (double value) {
                                setState(() {
                                  _currentVolume = value.toInt();
                                });
                                _updateClapDetectionThreshold(_currentVolume);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.translate),
                              title: Text(
                                'Language'.tr,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Get.to(LanguageScreen());
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.feedback_outlined),
                              title: Text(
                                'Feedback'.tr,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                Get.to(const FeedbackScreen());
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.star),
                              title: Text(
                                'Rate US'.tr,
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                CustomRatingBottomSheet.showFeedBackBottomSheet(
                                    context: context);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ZergAndroidPlugin.getNativeAdView(
              adWidth: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomRatingBottomSheet {
  CustomRatingBottomSheet._();
  static Future<void> showFeedBackBottomSheet({
    required BuildContext context,
  }) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return showModalBottomSheet<void>(
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              width: width,
              height: height * 0.55,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Image.network(
                    "https://iconape.com/wp-content/png_logo_vector/flutter-logo.png",
                    width: width,
                    height: height * 0.1,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    child: Text(
                      "How do you like app",
                      maxLines: 4,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  RatingBar.builder(
                    glow: false,
                    allowHalfRating: true,
                    unratedColor: Colors.grey[400],
                    itemSize: 50,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      if (rating.toInt() < 3) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pop(context);
                        LaunchReview.launch(
                            androidAppId: "com.rockstargames.gtasa");
                      }
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Tap the start",
                    textAlign: TextAlign.center,
                    maxLines: 4,
                  )
                ],
              ),
            ),
          );
        });
  }
}
