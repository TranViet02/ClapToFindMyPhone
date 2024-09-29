import 'dart:async';
import 'package:clap_to_find/widgets/home/clap/clap_detection_screen.dart';
import 'package:clap_to_find/widgets/home/homeScreen.dart';
import 'package:clap_to_find/widgets/home/setting/language/locale_controller.dart';
import 'package:clap_to_find/widgets/home/shakes/shakes_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zerg_android_plugin/zerg_android_plugin.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Completer<void> _completer = Completer<void>();
  bool _notificationGranted = false;
  bool _microphoneGranted = false;
  final LocaleController _localeController = Get.find<LocaleController>();

  @override
  void initState() {
    super.initState();
    _initUserDataAndNavigate();
  }

  Future<void> _initUserDataAndNavigate() async {
    await _requestPermissions();
    if (_notificationGranted && _microphoneGranted) {
      await _localeController.loadSavedLocale();
      // await initHadesSDK();
      await showAOAAd();
      _startRoute();
      _completer.complete();
    }
  }

  Future<void> _requestPermissions() async {
    await notificationPermission();
    if (_notificationGranted) {
      await microphonePermission();
    }
  }

  Future<void> notificationPermission() async {
    var notificationStatus = await Permission.notification.request();
    if (notificationStatus.isGranted) {
      print('Đã cấp quyền thông báo.');
      _notificationGranted = true;
    } else if (notificationStatus.isDenied ||
        notificationStatus.isPermanentlyDenied) {
      print('Quyền thông báo bị từ chối.');
      _notificationGranted = false;
      _showPermissionDeniedDialog('Notification');
    }
  }

  Future<void> microphonePermission() async {
    var microphoneStatus = await Permission.microphone.request();
    if (microphoneStatus.isGranted) {
      print('Đã cấp quyền sử dụng microphone.');
      _microphoneGranted = true;
    } else if (microphoneStatus.isDenied ||
        microphoneStatus.isPermanentlyDenied) {
      print('Quyền sử dụng microphone bị từ chối.');
      _microphoneGranted = false;
      _showPermissionDeniedDialog('Microphone');
    }
  }

  Future<void> showAOAAd() async {
    await Future.delayed(const Duration(seconds: 2));
    Completer<void> adCompleter = Completer<void>();
    ZergAndroidPlugin.showAOAIfAvailable(
      onFinished: () {
        adCompleter.complete();
      },
    );
    return adCompleter.future;
  }

  void _startRoute() {
    final String? route = Get.parameters['route'];
    if (route == '/clapDetection') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ClapDetectionScreen()),
      );
    } else if (route == '/vibration') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShakesScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  void _showPermissionDeniedDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permission Required'),
        content: Text(
            'Ứng dụng này yêu cầu quyền $permissionType để hoạt động bình thường.'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);
              if (permissionType == 'Notification') {
                notificationPermission().then((_) {
                  _initUserDataAndNavigate();
                });
              } else if (permissionType == 'Microphone') {
                microphonePermission().then((_) {
                  _initUserDataAndNavigate();
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _completer.future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingAnimation();
          } else {
            return loadingAnimation();
          }
        },
      ),
    );
  }

  Widget loadingAnimation() {
    return Stack(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: SizedBox(
              height: 140,
              width: 140,
              child: Image.asset('assets/logo.png'),
            ),
          ),
        ),
        const Positioned(
          bottom: 40,
          left: 15,
          right: 15,
          child: Column(
            children: [
              LinearProgressIndicator(),
              SizedBox(height: 18),
              Text(
                'This action can contain ads',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
